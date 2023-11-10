import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/enums/dock_type_enum.dart';
import 'package:martinlog_web/extensions/dock_type_extension.dart';
import 'package:martinlog_web/models/dock_model.dart';
import 'package:martinlog_web/repositories/create_dock_repositoy.dart';
import 'package:martinlog_web/repositories/get_docks_repository.dart';
import 'package:martinlog_web/state/app_state.dart';

abstract interface class IDockViewModel {
  Future<void> create({required String code, required DockType dockType});
  Future<void> getAll();
}

class DockViewModel extends GetxController implements IDockViewModel {
  List<DockModel> _docks = [];
  var appState = AppState().obs;
  final IGetDocksRepository getDocksRepository;
  final ICreateDockRepository createDockRepository;
  DockViewModel({
    required this.getDocksRepository,
    required this.createDockRepository,
  });

  List<DockModel> get docks => _docks;

  List<DockModel> getDocksByDockType(DockType? dockType) => _docks
      .where(
          (e) => dockType == null ? true : e.idDockType == dockType.idDockType)
      .toList();

  List<DockType> get docksType => DockType.values;

  @override
  Future<void> create(
      {required String code, required DockType dockType}) async {
    try {
      changeState(AppStateLoading());
      final dockModel =
          await createDockRepository(code: code, dockType: dockType);
      _docks.add(dockModel);
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
      _docks = await getDocksRepository();
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  void changeState(AppState appState) {
    this.appState.value = appState;
  }
}
