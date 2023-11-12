import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/enums/operation_status_enum.dart';
import 'package:martinlog_web/extensions/operation_status_extension.dart';
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
}

class OperationViewModel extends GetxController implements IOperationViewModel {
  var appState = AppState().obs;
  OperationModel? _operationModel;
  var operations = <OperationModel>[].obs;
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

  List<OperationModel> filterByStatus(
          OperationStatusEnum? operationStatusEnum) =>
      operations
          .where((element) => operationStatusEnum == null
              ? true
              : element.idOperationStatus ==
                  operationStatusEnum.idOperationStatus)
          .toList();

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
      required String liscensePlate,
      required String description}) async {
    try {
      changeState(AppStateLoading());
      final operationModel = await createOperationRepository(
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
}
