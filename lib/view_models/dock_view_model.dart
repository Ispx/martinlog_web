import 'package:flutter_excel/excel.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
import 'package:martinlog_web/models/branch_office_model.dart';
import 'package:martinlog_web/models/dock_model.dart';
import 'package:martinlog_web/repositories/upsert_dock_repositoy.dart';
import 'package:martinlog_web/repositories/get_docks_repository.dart';
import 'package:martinlog_web/state/app_state.dart';

abstract interface class IDockViewModel {
  Future<void> create({
    required String code,
    required int idDockType,
    required BranchOfficeModel branchOffice,
  });
  Future<void> bindBranchOffice(
      BranchOfficeModel branchOffice, DockModel dockModel);
  Future<void> getAll();
  Future<void> updateDock(DockModel dockModel);
  Future<void> downloadFile();
  Future<void> search(String src);
  void resetFilter();
}

class DockViewModel extends GetxController implements IDockViewModel {
  var docks = <DockModel>[].obs;
  var appState = AppState().obs;
  final IGetDocksRepository getDocksRepository;
  final IUpsertDockRepository upsertDockRepository;
  var docksSearched = <DockModel>[].obs;

  DockViewModel({
    required this.getDocksRepository,
    required this.upsertDockRepository,
  });

  @override
  Future<void> create({
    required String code,
    required int idDockType,
    required BranchOfficeModel branchOffice,
  }) async {
    try {
      changeState(AppStateLoading());
      await upsertDockRepository(
        code: code,
        idDockType: idDockType,
        isActive: true,
        idBranchOffice: branchOffice.idBranchOffice,
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
          dockModel.dockTypeModel?.name);
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
        idDockType: dockModel.idDockType,
        isActive: dockModel.isActive,
        idBranchOffice: dockModel.branchOfficeModel?.idBranchOffice,
      );
      final index = docks.indexWhere(
        (element) =>
            element.code == dockModel.code &&
            dockModel.idDockType == element.idDockType &&
            dockModel.branchOfficeModel?.idBranchOffice ==
                element.branchOfficeModel?.idBranchOffice,
      );
      docks.replaceRange(
        index,
        index + 1,
        [
          dockModel,
        ],
      );
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> bindBranchOffice(
      BranchOfficeModel branchOffice, DockModel dockModel) async {
    try {
      changeState(AppStateLoading());
      await upsertDockRepository(
        code: dockModel.code,
        idDockType: dockModel.idDockType,
        isActive: dockModel.isActive,
        idBranchOffice: branchOffice.idBranchOffice,
      );

      final index = docks.indexWhere(
        (element) =>
            element.code == dockModel.code &&
            dockModel.idDockType == element.idDockType &&
            dockModel.branchOfficeModel?.idBranchOffice ==
                element.branchOfficeModel?.idBranchOffice,
      );
      docks.replaceRange(
        index,
        index + 1,
        [
          dockModel.copyWith(
            branchOfficeModel: branchOffice,
          ),
        ],
      );

      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> search(String src) async {
    try {
      if (src.isEmpty) {
        docksSearched.value = [];
        return;
      }
      final regex = RegExp(src);
      docksSearched.value =
          docks.where((p0) => regex.hasMatch(p0.code)).toList();
    } catch (e) {
      docksSearched.value = [];
    }
  }

  @override
  void resetFilter() async {
    docksSearched.value = [];
  }
}
