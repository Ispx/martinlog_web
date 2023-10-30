import 'package:martinlog_web/enums/dock_type_enum.dart';
import 'package:martinlog_web/models/dock_model.dart';
import 'package:martinlog_web/repositories/create_dock_repositoy.dart';
import 'package:martinlog_web/repositories/get_docks_repository.dart';
import 'package:martinlog_web/state/app_state.dart';

abstract interface class IDockViewModel {
  Future<void> create({required String code, required DockType dockType});
  Future<void> getAll();
}

class DockViewModel implements IDockViewModel {
  List<DockModel> docks = [];
  AppState appState = AppStateEmpity();
  final IGetDocksRepository getDocksRepository;
  final ICreateDockRepository createDockRepository;
  DockViewModel({
    required this.getDocksRepository,
    required this.createDockRepository,
  });
  @override
  Future<void> create(
      {required String code, required DockType dockType}) async {
    try {
      appState = AppStateEmpity();
      final dockModel =
          await createDockRepository(code: code, dockType: dockType);
      docks.add(dockModel);
      appState = AppStateDone();
    } catch (e) {
      appState = AppStateError(e.toString());
    }
  }

  @override
  Future<void> getAll() async {
    try {
      appState = AppStateEmpity();
      docks = await getDocksRepository();
      appState = AppStateDone();
    } catch (e) {
      appState = AppStateError(e.toString());
    }
  }
}
