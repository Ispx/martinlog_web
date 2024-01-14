import 'package:flutter_excel/excel.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/extensions/profile_type_extension.dart';
import 'package:martinlog_web/helpers/formater_helper.dart';
import 'package:martinlog_web/models/user_model.dart';
import 'package:martinlog_web/repositories/create_user_repository.dart';
import 'package:martinlog_web/repositories/get_users_repository.dart';
import 'package:martinlog_web/repositories/update_user_repository.dart';
import 'package:martinlog_web/state/app_state.dart';

abstract interface class IUserViewModel {
  Future<void> create(
      {required String fullname,
      required String document,
      required String email,
      required int idProfile,
      required int idCompany});
  Future<void> updateUser(UserModel userModel);
  Future<void> getAll();
  Future<void> search(String text);
  Future<void> downloadFile(List<UserModel> users);
}

class UserViewModel implements IUserViewModel {
  final ICreateUserRepository createUserRepository;
  final IUpdateUserRepository updateUserRepository;

  final IGetUsersRepository getUsersRepository;
  UserViewModel({
    required this.createUserRepository,
    required this.updateUserRepository,
    required this.getUsersRepository,
  });

  var appState = AppState().obs;
  var users = <UserModel>[].obs;
  var usersFilted = <UserModel>[].obs;

  void changeState(AppState appState) => this.appState.value = appState;

  @override
  Future<void> create(
      {required String fullname,
      required String document,
      required String email,
      required int idProfile,
      required int idCompany}) async {
    try {
      changeState(AppStateLoading());
      await createUserRepository(
        fullname: fullname,
        document: document,
        email: email,
        idProfile: idProfile,
        idCompany: idCompany,
      );
      await getAll();
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> getAll() async {
    try {
      changeState(AppStateLoading());
      final users = await getUsersRepository();
      this.users.value = users
        ..sort((a, b) => a.createdAt.isAfter(b.createdAt) ? 0 : 1);
      usersFilted.value = this.users;
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> search(String text) async {
    usersFilted.value = users
        .where(
          (p0) =>
              p0.document.contains(text) ||
              p0.fullname.contains(text) ||
              p0.companyModel.fantasyName.contains(text),
        )
        .toList();
  }

  @override
  Future<void> downloadFile(List<UserModel> users) async {
    changeState(AppStateLoading());
    final excel = Excel.createExcel();
    const sheetName = "Usuários";
    excel.updateCell(sheetName, CellIndex.indexByString("A1"), "Nome completo");
    excel.updateCell(sheetName, CellIndex.indexByString("B1"), "Documento");
    excel.updateCell(sheetName, CellIndex.indexByString("C1"), "E-mail");
    excel.updateCell(sheetName, CellIndex.indexByString("D1"), "Perfil");
    excel.updateCell(sheetName, CellIndex.indexByString("E1"), "Status");
    excel.updateCell(
        sheetName, CellIndex.indexByString("F1"), "Transportadora");
    excel.updateCell(sheetName, CellIndex.indexByString("G1"), "CNPJ");
    for (int i = 0; i < usersFilted.length; i++) {
      var index = i + 2;
      final userModel = usersFilted[i];
      excel.updateCell(
          sheetName, CellIndex.indexByString("A$index"), userModel.fullname);
      excel.updateCell(sheetName, CellIndex.indexByString("B$index"),
          FormaterHelper.cpfOrCPNJ(userModel.document));
      excel.updateCell(
        sheetName,
        CellIndex.indexByString("C$index"),
        userModel.email,
      );
      excel.updateCell(sheetName, CellIndex.indexByString("D$index"),
          userModel.idProfile.getProfile().description);
      excel.updateCell(sheetName, CellIndex.indexByString("E$index"),
          userModel.isActive ? 'Ativo' : 'Desativado');
      excel.updateCell(sheetName, CellIndex.indexByString("F$index"),
          userModel.companyModel.fantasyName);
      excel.updateCell(sheetName, CellIndex.indexByString("G$index"),
          userModel.companyModel.cnpj);
    }

    excel.setDefaultSheet(sheetName);
    excel.save(fileName: "relatório_dos_usuários.xlsx");
    changeState(AppStateDone());
  }

  @override
  Future<void> updateUser(UserModel userModel) async {
    try {
      changeState(AppStateLoading());
      await updateUserRepository(
        fullname: userModel.fullname,
        document: userModel.document,
        email: userModel.email,
        idProfile: userModel.idProfile,
        isActive: userModel.isActive,
      );
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }
}
