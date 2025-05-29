import 'package:get/get.dart';
import 'package:martinlog_web/models/dashboard_model.dart';
import 'package:martinlog_web/models/operation_model.dart';
import 'package:martinlog_web/repositories/dashboard_repository.dart';
import 'package:martinlog_web/repositories/get_operations_repository.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/view_models/branch_office_view_model.dart';

abstract interface class IDashboardViewModel {
  Future<void> fetchDashboard();
  DashboardModel? getDashboard({
    required int idDockType,
  });
}

final class DashboardViewModel extends GetxController
    implements IDashboardViewModel {
  final IGetOperationsRepository getOperationsRepository;
  final BranchOfficeViewModel branchOfficeViewModel;
  final IDashboardRepository dashboardRepository;
  var operations = <OperationModel>[].obs;
  var dashboardResults = <DashboardModel>[].obs;

  var appState = AppState().obs;

  DashboardViewModel({
    required this.getOperationsRepository,
    required this.dashboardRepository,
    required this.branchOfficeViewModel,
  });

  void changeState(AppState appState) {
    this.appState.value = appState;
  }

  @override
  Future<void> fetchDashboard() async {
    try {
      changeState(AppStateLoading());
      if (branchOfficeViewModel.idBranchOfficeActivated?.isNegative ?? true) {
        await branchOfficeViewModel.getAll();
        await branchOfficeViewModel
            .switchBranchOffice(branchOfficeViewModel.branchs.first);
      }
      dashboardResults.value = await dashboardRepository();
      operations.value = await getOperationsRepository(limit: 5);
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  DashboardModel? getDashboard({
    required int idDockType,
  }) {
    return dashboardResults.where((e) => e.idDockTpe == idDockType).firstOrNull;
  }
}
