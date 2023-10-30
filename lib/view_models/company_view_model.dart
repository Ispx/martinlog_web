import 'package:martinlog_web/state/app_state.dart';

abstract class ICompanyViewModel {
  Future<void> getCompany();
  Future<void> getAllCompanies();
  Future<void> createCompany();
}

class CompanyViewModel implements ICompanyViewModel {
  AppState appState = AppStateEmpity();
  @override
  Future<void> createCompany() {
    // TODO: implement createCompany
    throw UnimplementedError();
  }

  @override
  Future<void> getAllCompanies() {
    // TODO: implement getAllCompanies
    throw UnimplementedError();
  }

  @override
  Future<void> getCompany() {
    // TODO: implement getCompany
    throw UnimplementedError();
  }
}
