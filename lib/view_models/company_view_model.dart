import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/repositories/get_companies_repository.dart';
import 'package:martinlog_web/repositories/get_company_repositoy.dart';
import 'package:martinlog_web/state/app_state.dart';

abstract class ICompanyViewModel {
  Future<void> getCompany();
  Future<void> getAllCompanies();
  Future<void> createCompany();
}

class CompanyViewModel implements ICompanyViewModel {
  AppState appState = AppStateEmpity();
  CompanyModel? companyModel;
  List<CompanyModel> companies = [];
  final IGetCompaniesRepository getCompaniesRepository;
  final IGetCompanyRepository getCompanyRepository;
  CompanyViewModel({
    required this.getCompaniesRepository,
    required this.getCompanyRepository,
  });
  @override
  Future<void> createCompany() {
    // TODO: implement createCompany
    throw UnimplementedError();
  }

  @override
  Future<void> getAllCompanies() async {
    try {
      changeState(AppStateLoading());
      companies = await getCompaniesRepository();
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  void changeState(AppState appState) {
    this.appState = appState;
  }

  @override
  Future<void> getCompany() async {
    try {
      changeState(AppStateLoading());
      companyModel = await getCompanyRepository();
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }
}
