import 'package:get/get.dart';
import 'package:martinlog_web/enums/dock_type_enum.dart';
import 'package:martinlog_web/extensions/dock_type_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/models/dock_model.dart';
import 'package:martinlog_web/repositories/upsert_dock_repositoy.dart';
import 'package:martinlog_web/repositories/get_docks_repository.dart';
import 'package:martinlog_web/state/app_state.dart';

abstract interface class IDockViewModel {
  Future<void> create({
    required String code,
    required DockType dockType,
  });
  Future<void> getAll();
  Future<void> updateDock(DockModel dockModel);
}

class DockViewModel extends GetxController implements IDockViewModel {
  var docks = <DockModel>[].obs;
  var appState = AppState().obs;
  final IGetDocksRepository getDocksRepository;
  final IUpsertDockRepository upsertDockRepository;
  DockViewModel({
    required this.getDocksRepository,
    required this.upsertDockRepository,
  });

  List<DockModel> getDocksByDockType(DockType? dockType) => docks
      .where(
          (e) => dockType == null ? true : e.idDockType == dockType.idDockType)
      .toList();

  List<DockType> get docksType => DockType.values;

  @override
  Future<void> create({
    required String code,
    required DockType dockType,
  }) async {
    try {
      changeState(AppStateLoading());
      final dockModel = await upsertDockRepository(
        code: code,
        dockType: dockType,
        isActive: true,
      );
      docks.add(dockModel);
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
      final docks = await getDocksRepository();
      this.docks.value = docks
        ..sort((a, b) => a.createdAt.isAfter(b.createdAt) ? 0 : 1);
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  void changeState(AppState appState) {
    this.appState.value = appState;
  }

  @override
  Future<void> updateDock(DockModel dockModel) async {
    try {
      changeState(AppStateLoading());
      await upsertDockRepository(
        code: dockModel.code,
        dockType: dockModel.idDockType.getDockType(),
        isActive: dockModel.isActive,
      );
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }
}
