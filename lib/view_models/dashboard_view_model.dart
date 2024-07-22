import 'package:get/get.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/models/dock_model.dart';
import 'package:martinlog_web/models/operation_model.dart';
import 'package:martinlog_web/repositories/get_operations_repository.dart';
import 'package:martinlog_web/state/app_state.dart';

abstract interface class IDashboardViewModel {
  Future<void> getAllOperations();
  List<OperationModel> filterOperations({
    DateTime? dateFrom,
    DateTime? dateUntil,
    List<int>? status,
    int? idDockType,
  });

  List<OperationModel> getLastsOperations(int qtd);
}

final class DashboardViewModel extends GetxController
    implements IDashboardViewModel {
  final IGetOperationsRepository getOperationsRepository;
  var companies = <CompanyModel>[].obs;
  var operations = <OperationModel>[].obs;
  var docks = <DockModel>[].obs;
  var appState = AppState().obs;

  DashboardViewModel({
    required this.getOperationsRepository,
  });

  void changeState(AppState appState) {
    this.appState.value = appState;
  }

  @override
  Future<void> getAllOperations() async {
    try {
      changeState(AppStateLoading());
      operations.value = await getOperationsRepository(
        dateFrom: DateTime.now().subtract(16.days).toUtc(),
        dateUntil: DateTime.now().toUtc(),
      );
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  List<OperationModel> filterOperations({
    DateTime? dateFrom,
    DateTime? dateUntil,
    List<int>? status,
    int? idDockType,
  }) {
    return operations.where((element) {
      if (element.dockModel?.idDockType != idDockType && idDockType != null) {
        return false;
      }
      if (dateFrom != null && dateUntil != null) {
        if (element.createdAt.isAfter(dateFrom) &&
            element.createdAt.isBefore(dateUntil)) {
          if (status != null) {
            return status.contains(element.idOperationStatus);
          }
          return true;
        } else {
          return false;
        }
      }
      if (status != null) {
        return status.contains(element.idOperationStatus);
      }
      return true;
    }).toList();
  }

  @override
  List<OperationModel> getLastsOperations(int qtd) {
    if (operations.length < qtd) {
      return operations.toList();
    }

    return operations.sublist(0, qtd - 1);
  }
}
