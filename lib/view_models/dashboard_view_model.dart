import 'package:get/get.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/models/dashboard_model.dart';
import 'package:martinlog_web/models/dock_model.dart';
import 'package:martinlog_web/models/operation_model.dart';
import 'package:martinlog_web/repositories/dashboard_repository.dart';
import 'package:martinlog_web/repositories/get_operations_repository.dart';
import 'package:martinlog_web/state/app_state.dart';

abstract interface class IDashboardViewModel {
  Future<void> getAllOperations();
  Future<void> dashboard();

  int filterDashboard({
    required int idDockType,
  });

  List<OperationModel> getLastsOperations(int qtd);
}

final class DashboardViewModel extends GetxController
    implements IDashboardViewModel {
  final IGetOperationsRepository getOperationsRepository;
  final IDashboardRepository dashboardRepository;
  var companies = <CompanyModel>[].obs;
  var operations = <OperationModel>[].obs;
  var dashboardResults = <DashboardModel>[].obs;

  var docks = <DockModel>[].obs;
  var appState = AppState().obs;

  DashboardViewModel({
    required this.getOperationsRepository,
    required this.dashboardRepository,
  });

  void changeState(AppState appState) {
    this.appState.value = appState;
  }

  @override
  Future<void> getAllOperations() async {
    try {
      changeState(AppStateLoading());
      operations.value = await getOperationsRepository();
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> dashboard() async {
    try {
      changeState(AppStateLoading());
      dashboardResults.value = await dashboardRepository();
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  int filterDashboard({
    required int idDockType,
  }) {
    return dashboardResults
            .where((e) => e.idDockType == idDockType)
            .firstOrNull
            ?.total ??
        0;
  }

  @override
  List<OperationModel> getLastsOperations(int qtd) {
    if (operations.length < qtd) {
      return operations.toList();
    }

    return operations.sublist(0, qtd - 1);
  }
}
