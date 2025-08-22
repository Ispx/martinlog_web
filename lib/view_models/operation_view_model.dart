import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_excel/excel.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/event_type_enum.dart';
import 'package:martinlog_web/enums/operation_status_enum.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
import 'package:martinlog_web/extensions/event_type_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/extensions/operation_status_extension.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/models/dock_model.dart';
import 'package:martinlog_web/models/dock_type_model.dart';
import 'package:martinlog_web/models/operation_model.dart';
import 'package:martinlog_web/repositories/cancel_operation_repository.dart';
import 'package:martinlog_web/repositories/create_operation_repository.dart';
import 'package:martinlog_web/repositories/get_operation_repository.dart';
import 'package:martinlog_web/repositories/get_operations_pending_repository.dart';
import 'package:martinlog_web/repositories/get_operations_repository.dart';
import 'package:martinlog_web/repositories/update_operation_repository.dart';
import 'package:martinlog_web/repositories/upload_file_operation_repository.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:path/path.dart' as Path;

abstract interface class IOperationViewModel {
  Future<void> create({
    required String dockCode,
    required CompanyModel companyModel,
    required String liscensePlate,
    required String description,
    required String? route,
    required String? place,
  });
  Future<void> updateOperation({
    required OperationModel operationModel,
    int? progress,
    DockModel? dockModel,
    CompanyModel? companyModel,
    String? additionalData,
    String? liscensePlate,
    String? description,
  });

  Future<void> cancel({required OperationModel operationModel});

  Future<void> getAll(
      {DateTime? dateFrom, DateTime? dateUntil, List<int>? status});
  Future<void> nextPage();
  Future<void> peviousPage();
  Future<void> getOperation({
    required String operationKey,
  });

  Future<void> downloadFile({
    DateTime? dateFrom,
    DateTime? dateUntil,
    List<int>? status,
    List<OperationModel>? values,
  });

  Future<void> uploadFile({
    required OperationModel operationModel,
    required String filename,
    required Uint8List imageBytes,
  });

  Future<void> filterByStatus(OperationStatusEnum statusEnum);
  Future<void> filterByDock(DockTypeModel dockTypeModel);
  Future<void> getPending();

  Future<void> search(String text);
  Future<void> onRefresh();
  Future<void> getItensByPageIndex(int index,
      {DateTime? dateFrom, DateTime? dateUntil});
  void resetFilter();
  void clear();
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
  final IUpdateOperationRepository updateOperationRepository;
  final IUploadFileOperationRepository uploadFileOperationRepository;
  final IGetOperationsPedingRepository getOperationsPedingRepository;
  final limitPaginationOffset = 10;
  var isEnableLoadMoreItens = true.obs;
  OperationViewModel({
    required this.cancelOperationRepository,
    required this.createOperationRepository,
    required this.getOperationRepository,
    required this.getOperationsRepository,
    required this.updateOperationRepository,
    required this.uploadFileOperationRepository,
    required this.getOperationsPedingRepository,
  });
  OperationModel? get operationModel => _operationModel;
  List<OperationStatusEnum> get operationStatus => OperationStatusEnum.values;

  @override
  Future<void> cancel({
    required OperationModel operationModel,
  }) async {
    try {
      changeState(AppStateLoading());
      await cancelOperationRepository(operationModel.operationKey);
      _notify(operationModel, EventTypeEnum.OPERATION_CANCELED);
      final index = operations.indexWhere(
          (element) => element.operationKey == operationModel.operationKey);
      operations.replaceRange(
        index,
        index + 1,
        [
          operationModel.copyWith(
            idOperationStatus: OperationStatusEnum.CANCELED.idOperationStatus,
          ),
        ],
      );
      operationsFilted.value = operations;
      changeState(AppStateDone("Operação cancelada com sucesso!"));
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> create({
    required String dockCode,
    required CompanyModel companyModel,
    required String liscensePlate,
    required String description,
    required String? route,
    required String? place,
  }) async {
    try {
      changeState(AppStateLoading());
      final operationModel = await createOperationRepository(
        companyModel: companyModel,
        dockCode: dockCode,
        liscensePlate: liscensePlate,
        description: description,
        route: route,
        place: place,
      );
      _notify(operationModel, EventTypeEnum.OPERATION_CREATED);
      operations.value = [operationModel, ...operations.value];
      operationsFilted.value = List.from(operations.value);
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
  Future<void> getAll({
    DateTime? dateFrom,
    DateTime? dateUntil,
    List<int>? status,
  }) async {
    try {
      if (appState is AppStateLoading || appState is AppStateLoadingMore) {
        return;
      }
      dateFrom = dateFrom != null
          ? DateTime(dateFrom.year, dateFrom.month, dateFrom.day, 00, 00, 00)
              .toUtc()
          : null;
      dateUntil = dateUntil != null
          ? DateTime(dateUntil.year, dateUntil.month, dateUntil.day, 23, 59, 59)
              .toUtc()
          : null;
      changeState(AppStateLoadingMore());
      final result = await getOperationsRepository(
        dateFrom: dateFrom,
        dateUntil: dateUntil,
        status: status,
        limit: limitPaginationOffset,
        skip: operations.length < limitPaginationOffset
            ? null
            : operations.length,
      );

      if (result.isEmpty) {
        isEnableLoadMoreItens.value = false;
        changeState(AppStateEmpity());
        return;
      }
      operations.addAll(result);
      operationsFilted.value = operations;
      isEnableLoadMoreItens.value = true;
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
  Future<void> updateOperation({
    required OperationModel operationModel,
    int? progress,
    DockModel? dockModel,
    CompanyModel? companyModel,
    String? additionalData,
    String? liscensePlate,
    String? description,
    String? route,
    String? place,
  }) async {
    try {
      changeState(AppStateLoading());
      await updateOperationRepository(
        operationKey: operationModel.operationKey,
        progress: progress,
        additionalData: additionalData,
        urlImage: operationModel.urlImage,
        idCompany: companyModel?.idCompany,
        dockCode: dockModel?.code,
        description: description,
        liscensePlate: liscensePlate,
        route: route,
        place: place,
      );
      final index = operations.indexWhere(
          (element) => element.operationKey == operationModel.operationKey);
      operations.replaceRange(
        index,
        index + 1,
        [
          operationModel.copyWith(
            progress: progress,
            companyModel: companyModel,
            dockModel: dockModel,
            description: description,
            liscensePlate: liscensePlate,
            additionalData: additionalData,
            idOperationStatus: progress == 100
                ? OperationStatusEnum.FINISHED.idOperationStatus
                : null,
            route: route,
            place: place,
            urlImage: operationModel.urlImage,
          ),
        ],
      );
      _notify(
          operationModel,
          progress == 100
              ? EventTypeEnum.OPERATION_FINISHED
              : EventTypeEnum.OPERATION_UPDATED);
      operationsFilted.value = operations;

      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  Future<void> _notify(
      OperationModel operationModel, EventTypeEnum eventType) async {
    try {
      FirebaseFirestore.instance.collection('operation_events').add({
        'data': operationModel.toJson(),
        'event_type': eventType.description,
        'idUser': simple.get<AuthViewModel>().authModel!.idUser,
      });
    } catch (_) {}
  }

  void changeState(AppState appState) {
    this.appState.value = appState;
  }

  @override
  Future<void> downloadFile({
    DateTime? dateFrom,
    DateTime? dateUntil,
    List<int>? status,
    List<OperationModel>? values,
  }) async {
    if (appState is AppStateLoading || appState is AppStateLoadingMore) {
      return;
    }
    changeState(AppStateLoading());
    dateFrom = dateFrom != null
        ? DateTime(dateFrom.year, dateFrom.month, dateFrom.day, 00, 00, 00)
            .toUtc()
        : null;
    dateUntil = dateUntil != null
        ? DateTime(dateUntil.year, dateUntil.month, dateUntil.day, 23, 59, 59)
            .toUtc()
        : null;
    values = values ??
        await getOperationsRepository(
          dateFrom: dateFrom,
          dateUntil: dateUntil,
          status: status,
          limit: 100000,
          skip: 0,
        );

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
    excel.updateCell(sheetName, CellIndex.indexByString("K1"), "Rota");
    excel.updateCell(sheetName, CellIndex.indexByString("L1"), "Loja");
    excel.updateCell(
        sheetName, CellIndex.indexByString("M1"), "Dados adicionais");
    excel.updateCell(sheetName, CellIndex.indexByString("N1"), "Link");

    for (int i = 0; i < values.length; i++) {
      var index = i + 2;
      final operationModel = values[i];

      excel.updateCell(sheetName, CellIndex.indexByString("A$index"),
          operationModel.companyModel.fantasyName);

      excel.updateCell(sheetName, CellIndex.indexByString("B$index"),
          operationModel.companyModel.cnpj);
      excel.updateCell(sheetName, CellIndex.indexByString("C$index"),
          operationModel.dockModel?.code);
      excel.updateCell(sheetName, CellIndex.indexByString("D$index"),
          operationModel.dockModel?.dockTypeModel?.name);
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
      excel.updateCell(sheetName, CellIndex.indexByString("K$index"),
          operationModel.route ?? '');
      excel.updateCell(sheetName, CellIndex.indexByString("L$index"),
          operationModel.place ?? '');
      excel.updateCell(sheetName, CellIndex.indexByString("M$index"),
          operationModel.additionalData ?? '');
      excel.updateCell(sheetName, CellIndex.indexByString("N$index"),
          operationModel.urlImage ?? '');
    }

    excel.setDefaultSheet(sheetName);
    excel.save(fileName: "relatório_de_operações.xlsx");
    changeState(AppStateDone());
  }

  @override
  Future<void> filterByDock(DockTypeModel dockTypeModel) async {
    if (dockTypeModel.idDockType == -1) {
      operationsFilted.value = operations;
      return;
    }
    operationsFilted.value = operations
        .where((p0) => p0.dockModel!.idDockType == dockTypeModel.idDockType)
        .toList();
  }

  @override
  Future<void> search(String text) async {
    try {
      List<OperationModel> operations = <OperationModel>[];
      operations.addAll(this.operations);
      if (text.isEmpty) {
        resetFilter();
        return;
      }
      final regex = RegExp(text.toLowerCase());
      operationsFilted.value = operations
          .where(
            (p0) =>
                regex.hasMatch(p0.companyModel.fantasyName.toLowerCase()) ||
                regex.hasMatch(p0.dockModel!.code.toLowerCase()) ||
                regex.hasMatch(
                    p0.dockModel!.dockTypeModel?.name.toLowerCase() ?? '') ||
                regex.hasMatch(p0.idOperationStatus
                    .getOperationStatus()
                    .description
                    .toLowerCase()),
          )
          .toList();
    } catch (e) {
      operationsFilted.value = [];
    }
  }

  @override
  Future<void> filterByStatus(OperationStatusEnum? statusEnum) async {
    if (statusEnum == null || statusEnum.idOperationStatus == -1) {
      await onRefresh();
      return;
    }

    if (statusEnum == OperationStatusEnum.IN_PROGRESS) {
      await getPending();

      return;
    }
    if (operationsFilted.isNotEmpty) {
      operationsFilted.value = operationsFilted
          .where((p0) => p0.idOperationStatus == statusEnum.idOperationStatus)
          .toList();
    } else {
      operationsFilted.value = operations
          .where((p0) => p0.idOperationStatus == statusEnum.idOperationStatus)
          .toList();
    }
  }

  @override
  void resetFilter() {
    operationsFilted.value = operations;
  }

  @override
  Future<void> uploadFile({
    required OperationModel operationModel,
    required String filename,
    required Uint8List imageBytes,
  }) async {
    try {
      if (appState is AppStateLoading) return;
      final url = await uploadFileOperationRepository(
        operationKey: operationModel.operationKey,
        filename: filename,
        imageBytes: imageBytes,
      );

      final index = operations.indexWhere(
          (element) => element.operationKey == operationModel.operationKey);
      operations.replaceRange(
        index,
        index + 1,
        [
          operationModel.copyWith(
            progress: operationModel.progress,
            additionalData: operationModel.additionalData,
            urlImage: url,
          ),
        ],
      );

      operationsFilted.value = operations;

      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> nextPage() async {}

  @override
  Future<void> peviousPage() async {}

  @override
  Future<void> onRefresh() async {
    operations.clear();
    operationsFilted.clear();
    isEnableLoadMoreItens.value = true;

    await getAll();
  }

  @override
  Future<void> getPending() async {
    try {
      if (appState is AppStateLoading || appState is AppStateLoadingMore) {
        return;
      }
      changeState(AppStateLoadingMore());
      isEnableLoadMoreItens.value = false;
      final operations = await getOperationsRepository(status: [
        OperationStatusEnum.IN_PROGRESS.idOperationStatus,
      ]);
      operationsFilted.value = operations;
      this.operations.value = operations;
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> getItensByPageIndex(int index,
      {DateTime? dateFrom, DateTime? dateUntil}) async {
    index++;
    final endIndexPage = index * limitPaginationOffset;
    final beginIndexPage = endIndexPage - limitPaginationOffset;
    if (endIndexPage > operations.length) {
      await getAll(
        dateFrom: dateFrom,
        dateUntil: dateUntil,
      );
      operationsFilted.value =
          operations.sublist(beginIndexPage, operations.length);
      changeState(AppStateDone());
      return;
    }
    operationsFilted.value = operations.sublist(beginIndexPage, endIndexPage);
    if (isEnableLoadMoreItens.value == false) {
      isEnableLoadMoreItens.value = true;
    }
    changeState(AppStateDone());
  }

  @override
  void clear() {
    operations.clear();
    operationsFilted.clear();
  }
}
