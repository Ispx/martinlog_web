import 'package:flutter/material.dart';
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
    required operationKey,
  });

  Future<void> getAll(
      {DateTime? dateFrom, DateTime? dateUntil, List<int>? status});

  Future<void> getOperation({
    required operationKey,
  });
}

class OperationViewModel extends ChangeNotifier implements IOperationViewModel {
  AppState appState = AppStateEmpity();
  OperationModel? operationModel;
  List<OperationModel> operations = [];
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
  @override
  Future<void> cancel({required operationKey}) async {
    try {
      changeState(AppStateLoading());
      await cancelOperationRepository(operationKey);
      changeState(AppStateDone());
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
      await createOperationRepository(
          dockCode: dockCode,
          liscensePlate: liscensePlate,
          description: description);
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> getAll(
      {DateTime? dateFrom, DateTime? dateUntil, List<int>? status}) async {
    try {
      changeState(AppStateLoading());
      operations = await getOperationsRepository(
          dateFrom: dateFrom, dateUntil: dateUntil, status: status);
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> getOperation({required operationKey}) async {
    try {
      changeState(AppStateLoading());
      operationModel = await getOperationRepository(operationKey);
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
    this.appState = appState;
    notifyListeners();
  }
}
