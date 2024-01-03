import 'package:get/state_manager.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/models/dock_model.dart';
import 'package:martinlog_web/models/operation_model.dart';
import 'package:martinlog_web/repositories/get_companies_repository.dart';
import 'package:martinlog_web/repositories/get_docks_repository.dart';
import 'package:martinlog_web/repositories/get_operations_repository.dart';
import 'package:martinlog_web/state/app_state.dart';

abstract interface class IDashboardViewModel {
  Future<List<OperationModel>> getOperations({
    DateTime? dateFrom,
    DateTime? dateUntil,
    List<int>? status,
    int? idDockType,
  });

  Future<void> getCompanies();
  Future<void> getDocks();
}

final class DashboardViewModel extends GetxController
    implements IDashboardViewModel {
  final IGetOperationsRepository getOperationsRepository;
  final IGetCompaniesRepository getCompaniesRepository;
  final IGetDocksRepository getDocksRepository;
  var companies = <CompanyModel>[].obs;
  var docks = <DockModel>[].obs;
  var appState = AppState().obs;

  DashboardViewModel({
    required this.getCompaniesRepository,
    required this.getDocksRepository,
    required this.getOperationsRepository,
  });

  @override
  Future<void> getCompanies() async {
    try {
      changeState(AppStateLoading());
      companies.value = await getCompaniesRepository();
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> getDocks() async {
    try {
      changeState(AppStateLoading());
      docks.value = await getDocksRepository();
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  void changeState(AppState appState) {
    this.appState.value = appState;
  }

  @override
  Future<List<OperationModel>> getOperations(
      {DateTime? dateFrom,
      DateTime? dateUntil,
      List<int>? status,
      int? idDockType}) async {
    try {
      changeState(AppStateLoading());
      final operations = await getOperationsRepository(
        dateFrom: dateFrom,
        dateUntil: dateUntil,
        status: status,
      );
      changeState(AppStateDone());
      return operations
          .where((element) => element.dockModel?.idDockType == idDockType)
          .toList();
    } catch (e) {
      changeState(AppStateError(e.toString()));
      return [];
    }
  }
}
