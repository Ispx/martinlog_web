import 'package:flutter_excel/excel.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/enums/dock_type_enum.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
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
  Future<void> downloadFile();
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

  List<DockModel> getDocksByDockType(DockType? dockType) {
    final docksFilted = docks
        .where((e) =>
            dockType == null ? true : e.idDockType == dockType.idDockType)
        .toList();
    docksFilted
        .sort((a, b) => a.code.trimRight().compareTo(b.code.trimRight()));
    return docksFilted;
  }

  List<DockType> get docksType => DockType.values;

  @override
  Future<void> create({
    required String code,
    required DockType dockType,
  }) async {
    try {
      changeState(AppStateLoading());
      await upsertDockRepository(
        code: code,
        dockType: dockType,
        isActive: true,
      );
      _internalGetAll();
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
      this.docks.value = docks;
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  Future<void> _internalGetAll() async {
    final docks = await getDocksRepository();
    this.docks.value = docks;
  }

  void changeState(AppState appState) {
    this.appState.value = appState;
  }

  @override
  Future<void> downloadFile() async {
    changeState(AppStateLoading());
    final excel = Excel.createExcel();
    const sheetName = "Docas";
    excel.updateCell(sheetName, CellIndex.indexByString("A1"), "Tipo");
    excel.updateCell(sheetName, CellIndex.indexByString("B1"), "Código");
    excel.updateCell(sheetName, CellIndex.indexByString("C1"), "Status");
    excel.updateCell(
        sheetName, CellIndex.indexByString("D1"), "Data de criação");
    for (int i = 0; i < docks.length; i++) {
      var index = i + 2;
      final dockModel = docks[i];
      excel.updateCell(sheetName, CellIndex.indexByString("A$index"),
          dockModel.idDockType.getDockType().description);
      excel.updateCell(
          sheetName, CellIndex.indexByString("B$index"), dockModel.code);
      excel.updateCell(
        sheetName,
        CellIndex.indexByString("C$index"),
        dockModel.isActive ? 'Ativado' : 'Desativado',
      );
      excel.updateCell(sheetName, CellIndex.indexByString("D$index"),
          dockModel.createdAt.ddMMyyyy);
    }

    excel.setDefaultSheet(sheetName);
    excel.save(fileName: "relatório_das_docas.xlsx");
    changeState(AppStateDone());
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
