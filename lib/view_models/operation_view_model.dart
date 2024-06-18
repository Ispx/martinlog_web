import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_excel/excel.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/dock_type_enum.dart';
import 'package:martinlog_web/enums/event_type_enum.dart';
import 'package:martinlog_web/enums/operation_status_enum.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
import 'package:martinlog_web/extensions/dock_type_extension.dart';
import 'package:martinlog_web/extensions/event_type_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/extensions/operation_status_extension.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/models/operation_model.dart';
import 'package:martinlog_web/repositories/cancel_operation_repository.dart';
import 'package:martinlog_web/repositories/create_operation_repository.dart';
import 'package:martinlog_web/repositories/get_operation_repository.dart';
import 'package:martinlog_web/repositories/get_operations_repository.dart';
import 'package:martinlog_web/repositories/update_progress_operation_repository.dart';
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
  });
  Future<void> updateOperation({
    required OperationModel operationModel,
    required int progress,
    required String? additionalData,
  });

  Future<void> cancel({required OperationModel operationModel});

  Future<void> getAll(
      {DateTime? dateFrom, DateTime? dateUntil, List<int>? status});

  Future<void> getOperation({
    required String operationKey,
  });

  Future<void> downloadFile(List<OperationModel> operations);
  Future<void> uploadFile({
    required OperationModel operationModel,
    required String filename,
    required Uint8List imageBytes,
  });

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
  final IUpdateOperationRepository updateOperationRepository;
  final IUploadFileOperationRepository uploadFileOperationRepository;
  final _bucket = 'operations-file';

  OperationViewModel({
    required this.cancelOperationRepository,
    required this.createOperationRepository,
    required this.getOperationRepository,
    required this.getOperationsRepository,
    required this.updateOperationRepository,
    required this.uploadFileOperationRepository,
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
      await FirebaseFirestore.instance.collection('operation_events').add({
        'data': operationModel.toJson(),
        'event_type': EventTypeEnum.OPERATION_CANCELED.description,
        'idUser': simple.get<AuthViewModel>().authModel!.idUser,
      });
      await _internalGetAll();
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
      await FirebaseFirestore.instance.collection('operation_events').add({
        'data': operationModel.toJson(),
        'event_type': EventTypeEnum.OPERATION_CREATED.description,
        'idUser': simple.get<AuthViewModel>().authModel!.idUser,
      });
      List<OperationModel> operations = <OperationModel>[];
      operations.addAll(this.operations);
      operations.insert(0, operationModel);
      operationsFilted.value = operations;
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
      final result = await getOperationsRepository(
          dateFrom: dateFrom, dateUntil: dateUntil, status: status);
      operations.value = result;
      operationsFilted.value = result;
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  void sort() {
    List<OperationModel> operations = <OperationModel>[];
    operations.addAll(this.operations);
    operations.sort((a, b) => a.createdAt.isAfter(b.createdAt) ? 1 : 0);
    this.operations.value = operations;
  }

  Future<void> _internalGetAll() async {
    final result = await getOperationsRepository();
    operations.value = result;
    operationsFilted.value = result;
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
    required int progress,
    required String? additionalData,
  }) async {
    try {
      changeState(AppStateLoading());
      await updateOperationRepository(
        operationKey: operationModel.operationKey,
        progress: progress,
        additionalData: additionalData,
        urlImage: null,
      );
      List<OperationModel> operations = <OperationModel>[];
      operations.addAll(this.operations);
      operations.removeWhere(
          (element) => element.operationKey == operationModel.operationKey);
      operations.add(
        operationModel.copyWith(
          progress: progress,
          additionalData: additionalData,
        ),
      );
      this.operations.value = operations;
      sort();
      await FirebaseFirestore.instance.collection('operation_events').add({
        'data': operationModel.toJson(),
        'event_type': progress == 100
            ? EventTypeEnum.OPERATION_FINISHED.description
            : EventTypeEnum.OPERATION_UPDATED.description,
        'idUser': simple.get<AuthViewModel>().authModel!.idUser,
      });
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
    if (operationsFilted.isNotEmpty) {
      operationsFilted.value = operationsFilted
          .where((p0) => p0.dockModel!.idDockType == dockType.idDockType)
          .toList();
    } else {
      operationsFilted.value = operations
          .where((p0) => p0.dockModel!.idDockType == dockType.idDockType)
          .toList();
    }
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

      operationsFilted.value = operations
          .where((p0) =>
              p0.companyModel.fantasyName
                  .toString()
                  .toLowerCase()
                  .startsWith(text.toLowerCase()) ||
              p0.dockModel!.code.compareTo(text) == 0)
          .toList();
    } catch (e) {
      operationsFilted.value = [];
    }
  }

  @override
  Future<void> filterByStatus(OperationStatusEnum statusEnum) async {
    if (statusEnum.idOperationStatus == -1) {
      operationsFilted.value = operations;
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
  Future<void> filterByDate(DateTime start, DateTime end) async {
    try {
      if (appState is AppStateLoading) return;
      changeState(AppStateLoading());
      final operations = await getOperationsRepository(
          dateFrom: start.toUtc(),
          dateUntil: DateTime(end.year, end.month, end.day, 23, 59, 59).toUtc(),
          status: null);
      operations.sort((a, b) => a.createdAt.isAfter(b.createdAt) ? 0 : 1);
      operationsFilted.value = operations;
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> uploadFile({
    required OperationModel operationModel,
    required String filename,
    required Uint8List imageBytes,
  }) async {
    try {
      if (appState is AppStateLoading) return;
      changeState(AppStateLoading());
      final reference = FirebaseStorage.instance
          .ref()
          .child('images/${operationModel.operationKey}');
      await reference.putData(
        imageBytes,
        SettableMetadata(
          contentType: "image/${Path.extension(filename).replaceAll(".", "")}",
        ),
      );
      final url = await reference.getDownloadURL();
      await updateOperationRepository(
        operationKey: operationModel.operationKey,
        progress: operationModel.progress,
        additionalData: null,
        urlImage: url,
      );
      await _internalGetAll();
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }
}
