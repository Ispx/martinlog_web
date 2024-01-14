import 'package:flutter/material.dart';
import 'package:flutter_excel/excel.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/enums/dock_type_enum.dart';
import 'package:martinlog_web/enums/operation_status_enum.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
import 'package:martinlog_web/extensions/dock_type_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/extensions/operation_status_extension.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/models/operation_model.dart';
import 'package:martinlog_web/repositories/cancel_operation_repository.dart';
import 'package:martinlog_web/repositories/create_operation_repository.dart';
import 'package:martinlog_web/repositories/get_operation_repository.dart';
import 'package:martinlog_web/repositories/get_operations_repository.dart';
import 'package:martinlog_web/repositories/update_progress_operation_repository.dart';
import 'package:martinlog_web/state/app_state.dart';

abstract interface class IOperationViewModel {
  Future<void> create({
    required String dockCode,
    required CompanyModel companyModel,
    required String liscensePlate,
    required String description,
  });
  Future<void> updateProgress({
    required String operationKey,
    required int progress,
  });

  Future<void> cancel({
    required String operationKey,
  });

  Future<void> getAll(
      {DateTime? dateFrom, DateTime? dateUntil, List<int>? status});

  Future<void> getOperation({
    required String operationKey,
  });

  Future<void> downloadFile(List<OperationModel> operations);
  Future<void> filterByStatus(OperationStatusEnum statusEnum);
  Future<void> filterByDock(DockType dockType);
  Future<void> filterByDate(DateTime start, DateTime end);

  Future<void> search(String text);
  void resetFilter();
}

class OperationViewModel extends GetxController implements IOperationViewModel {
  var appState = AppState().obs;
  OperationModel? _operationModel;
  var operations = <OperationModel>[].obs;
  var operationsFilted = <OperationModel>[].obs;
  var searchText = ''.obs;
  final ICancelOperationRepository cancelOperationRepository;
  final ICreateOperationRepository createOperationRepository;
  final IGetOperationsRepository getOperationsRepository;
  final IGetOperationRepository getOperationRepository;
  final IUpdateProgressOperationRepository updateProgressOperationRepository;
  OperationViewModel({
    required this.cancelOperationRepository,
    required this.createOperationRepository,
    required this.getOperationRepository,
    required this.getOperationsRepository,
    required this.updateProgressOperationRepository,
  });
  OperationModel? get operationModel => _operationModel;
  List<OperationStatusEnum> get operationStatus => OperationStatusEnum.values;

  @override
  Future<void> cancel({required operationKey}) async {
    try {
      changeState(AppStateLoading());
      await cancelOperationRepository(operationKey);
      changeState(AppStateDone("Operação cancelada com sucesso!"));
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> create(
      {required String dockCode,
      required CompanyModel companyModel,
      required String liscensePlate,
      required String description}) async {
    try {
      changeState(AppStateLoading());
      final operationModel = await createOperationRepository(
          companyModel: companyModel,
          dockCode: dockCode,
          liscensePlate: liscensePlate,
          description: description);
      operations.add(operationModel);
      await getAll();
      BannerComponent(
        message: "Operação criada com sucesso",
        backgroundColor: Colors.green,
      );
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> getAll(
      {DateTime? dateFrom, DateTime? dateUntil, List<int>? status}) async {
    try {
      if (appState is AppStateLoading) return;
      changeState(AppStateLoading());
      final operations = await getOperationsRepository(
          dateFrom: dateFrom, dateUntil: dateUntil, status: status);
      this.operations.value = operations
        ..sort((a, b) => a.createdAt.isAfter(b.createdAt) ? 0 : 1);
      operationsFilted.value = operations;
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> getOperation({required operationKey}) async {
    try {
      changeState(AppStateLoading());
      _operationModel = await getOperationRepository(operationKey);
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> updateProgress(
      {required String operationKey, required int progress}) async {
    try {
      changeState(AppStateLoading());
      await updateProgressOperationRepository(
          operationKey: operationKey, progress: progress);
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  void changeState(AppState appState) {
    this.appState.value = appState;
  }

  @override
  Future<void> downloadFile(List<OperationModel> operations) async {
    changeState(AppStateLoading());
    final excel = Excel.createExcel();
    const sheetName = "Operações";
    excel.updateCell(
        sheetName, CellIndex.indexByString("A1"), "TRANSPORTADORA");
    excel.updateCell(sheetName, CellIndex.indexByString("B1"), "CNPJ");
    excel.updateCell(sheetName, CellIndex.indexByString("C1"), "DOCA");
    excel.updateCell(sheetName, CellIndex.indexByString("D1"), "Tipo");
    excel.updateCell(sheetName, CellIndex.indexByString("E1"), "Status");
    excel.updateCell(
        sheetName, CellIndex.indexByString("F1"), "Data de início");
    excel.updateCell(
        sheetName, CellIndex.indexByString("G1"), "Data de finalização");
    excel.updateCell(sheetName, CellIndex.indexByString("H1"), "Placa");
    excel.updateCell(sheetName, CellIndex.indexByString("I1"), "Descrição");
    excel.updateCell(
        sheetName, CellIndex.indexByString("J1"), "Chave da operação");
    for (int i = 0; i < operationsFilted.length; i++) {
      var index = i + 2;
      final operationModel = operationsFilted[i];

      excel.updateCell(sheetName, CellIndex.indexByString("A$index"),
          operationModel.companyModel.fantasyName);

      excel.updateCell(sheetName, CellIndex.indexByString("B$index"),
          operationModel.companyModel.cnpj);
      excel.updateCell(sheetName, CellIndex.indexByString("C$index"),
          operationModel.dockModel?.code);
      excel.updateCell(sheetName, CellIndex.indexByString("D$index"),
          operationModel.dockModel?.idDockType.getDockType().description);
      excel.updateCell(sheetName, CellIndex.indexByString("E$index"),
          operationModel.idOperationStatus.getOperationStatus().description);

      excel.updateCell(sheetName, CellIndex.indexByString("F$index"),
          operationModel.createdAt.ddMMyyyyHHmmss);

      excel.updateCell(sheetName, CellIndex.indexByString("G$index"),
          operationModel.finishedAt?.ddMMyyyyHHmmss ?? '');
      excel.updateCell(sheetName, CellIndex.indexByString("H$index"),
          operationModel.liscensePlate);
      excel.updateCell(sheetName, CellIndex.indexByString("I$index"),
          operationModel.description);
      excel.updateCell(sheetName, CellIndex.indexByString("J$index"),
          operationModel.operationKey);
    }

    excel.setDefaultSheet(sheetName);
    excel.save(fileName: "relatório_de_operações.xlsx");
    changeState(AppStateDone());
  }

  @override
  Future<void> filterByDock(DockType dockType) async {
    if (dockType.idDockType == -1) {
      operationsFilted.value = operations;
      return;
    }
    operationsFilted.value = operations
        .where((p0) => p0.dockModel!.idDockType == dockType.idDockType)
        .toList();
  }

  @override
  Future<void> search(String text) async {
    operationsFilted.value = operations
        .where((p0) =>
            p0.companyModel.fantasyName.contains(text) ||
            p0.dockModel!.code.contains(text))
        .toList();
  }

  @override
  Future<void> filterByStatus(OperationStatusEnum statusEnum) async {
    if (statusEnum.idOperationStatus == -1) {
      operationsFilted.value = operations;
      return;
    }
    operationsFilted.value = operations
        .where((p0) => p0.idOperationStatus == statusEnum.idOperationStatus)
        .toList();
  }

  @override
  void resetFilter() {
    operationsFilted.value = operations;
  }

  @override
  Future<void> filterByDate(DateTime start, DateTime end) async {
    try {
      if (appState is AppStateLoading) return;
      changeState(AppStateLoading());
      final operations = await getOperationsRepository(
          dateFrom: start,
          dateUntil: DateTime(end.year, end.month, end.day, 23, 59, 59),
          status: null);
      operationsFilted.value = operations
        ..sort((a, b) => a.createdAt.isAfter(b.createdAt) ? 0 : 1);
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }
}
