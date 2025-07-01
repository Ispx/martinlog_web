import 'package:flutter_excel/excel.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/repositories/create_company_repository.dart';
import 'package:martinlog_web/repositories/get_companies_repository.dart';
import 'package:martinlog_web/repositories/get_company_repositoy.dart';
import 'package:martinlog_web/state/app_state.dart';

abstract class ICompanyViewModel {
  Future<void> getCompany();
  Future<void> getAllCompanies();
  Future<void> createCompany(CompanyModel companyModel);
  Future<void> downloadFile();
  Future<void> search(String src);
  CompanyModel? companyModel;

  void resetFilter();
}

class CompanyViewModel extends GetxController implements ICompanyViewModel {
  var appState = AppState().obs;
  var companies = <CompanyModel>[].obs;
  final IGetCompaniesRepository getCompaniesRepository;
  final IGetCompanyRepository getCompanyRepository;
  final ICreateCompanyRepository createCompanyRepository;
  var companiesSearched = <CompanyModel>[].obs;

  CompanyViewModel({
    required this.getCompaniesRepository,
    required this.getCompanyRepository,
    required this.createCompanyRepository,
  });
  @override
  Future<void> createCompany(CompanyModel companyModel) async {
    try {
      changeState(AppStateLoading());
      final company = await createCompanyRepository(companyModel);
      companies.add(company);
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> getAllCompanies() async {
    try {
      if (appState is AppStateLoading) return;
      changeState(AppStateLoading());
      final companies = await getCompaniesRepository();
      this.companies.value = companies
        ..sort((a, b) => a.createdAt!.isAfter(b.createdAt!) ? 0 : 1);
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  void changeState(AppState appState) {
    this.appState.value = appState;
  }

  @override
  Future<void> downloadFile() async {
    changeState(AppStateLoading());
    final excel = Excel.createExcel();
    const sheetName = "Transportadoras";
    excel.updateCell(sheetName, CellIndex.indexByString("A1"), "Cnpj");
    excel.updateCell(sheetName, CellIndex.indexByString("B1"), "Razão Social");
    excel.updateCell(sheetName, CellIndex.indexByString("C1"), "Nome fantasia");
    excel.updateCell(
        sheetName, CellIndex.indexByString("D1"), "Nome do proprietário");
    excel.updateCell(
        sheetName, CellIndex.indexByString("E1"), "CPF do proprietário");
    excel.updateCell(sheetName, CellIndex.indexByString("F1"), "Telefone");
    excel.updateCell(sheetName, CellIndex.indexByString("G1"), "CEP");
    excel.updateCell(
        sheetName, CellIndex.indexByString("H1"), "Número do endereço");
    excel.updateCell(sheetName, CellIndex.indexByString("I1"), "Complemento");
    excel.updateCell(
        sheetName, CellIndex.indexByString("J1"), "Data de criação");

    for (int i = 0; i < companies.length; i++) {
      var index = i + 2;
      final companyModel = companies[i];
      excel.updateCell(
          sheetName, CellIndex.indexByString("A$index"), companyModel.cnpj);
      excel.updateCell(sheetName, CellIndex.indexByString("B$index"),
          companyModel.socialRason);
      excel.updateCell(
        sheetName,
        CellIndex.indexByString("C$index"),
        companyModel.fantasyName,
      );
      excel.updateCell(sheetName, CellIndex.indexByString("D$index"),
          companyModel.ownerName);
      excel.updateCell(
          sheetName, CellIndex.indexByString("E$index"), companyModel.ownerCpf);
      excel.updateCell(sheetName, CellIndex.indexByString("F$index"),
          companyModel.telephone);
      excel.updateCell(
          sheetName, CellIndex.indexByString("G$index"), companyModel.zipcode);
      excel.updateCell(sheetName, CellIndex.indexByString("H$index"),
          companyModel.streetNumber);
      excel.updateCell(sheetName, CellIndex.indexByString("I$index"),
          companyModel.streetComplement);
      excel.updateCell(sheetName, CellIndex.indexByString("J$index"),
          companyModel.createdAt!.ddMMyyyy);
    }

    excel.setDefaultSheet(sheetName);
    excel.save(fileName: "relatório_das_transportadoras.xlsx");
    changeState(AppStateDone());
  }

  @override
  Future<void> getCompany() async {
    try {
      if (appState is AppStateLoading) return;
      changeState(AppStateLoading());
      companyModel = await getCompanyRepository();
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> search(String src) async {
    try {
      if (src.isEmpty) {
        companiesSearched.value = [];
        return;
      }
      final regex = RegExp(src);
      companiesSearched.value = companies
          .where(
            (p0) => regex.hasMatch(p0.socialRason) || regex.hasMatch(p0.cnpj),
          )
          .toList();
    } catch (e) {
      companiesSearched.value = [];
    }
  }

  @override
  void resetFilter() async {
    companiesSearched.value = [];
  }

  @override
  CompanyModel? companyModel;
}
