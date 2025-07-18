import 'package:get/get.dart';
import 'package:martinlog_web/models/branch_office_model.dart';
import 'package:martinlog_web/models/dock_type_model.dart';
import 'package:martinlog_web/repositories/create_dock_type_repository.dart';
import 'package:martinlog_web/repositories/get_dock_type_repository.dart';
import 'package:martinlog_web/state/app_state.dart';

abstract interface class IDockTypeViewModel {
  Future<void> create({
    required String name,
    required BranchOfficeModel branchOffice,
  });
  Future<void> getAll();
}

class DockTypeViewModel extends GetxController implements IDockTypeViewModel {
  var appState = AppState().obs;
  final ICreateDockTypeRepository createDockTypeRepository;
  final IGetDockTypeRepository getDockTypeRepository;
  var dockTypes = <DockTypeModel>[].obs;

  DockTypeViewModel({
    required this.createDockTypeRepository,
    required this.getDockTypeRepository,
  });

  @override
  Future<void> create({
    required String name,
    required BranchOfficeModel branchOffice,
  }) async {
    try {
      changeState(AppStateLoading());
      final dockTypeModel = await createDockTypeRepository(
        name: name,
        branchOffice: branchOffice,
      );
      dockTypes.add(dockTypeModel);
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> getAll() async {
    try {
      if (appState is AppStateLoading) return;

      changeState(AppStateLoading());
      final dockTypes = await getDockTypeRepository();
      this.dockTypes.value = dockTypes;
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  void changeState(AppState appState) {
    this.appState.value = appState;
  }
}
