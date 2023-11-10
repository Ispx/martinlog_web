import 'package:flutter/material.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/repositories/create_company_repository.dart';
import 'package:martinlog_web/repositories/get_companies_repository.dart';
import 'package:martinlog_web/repositories/get_company_repositoy.dart';
import 'package:martinlog_web/state/app_state.dart';

abstract class ICompanyViewModel {
  Future<void> getCompany();
  Future<void> getAllCompanies();
  Future<void> createCompany(CompanyModel companyModel);
}

class CompanyViewModel extends ChangeNotifier implements ICompanyViewModel {
  AppState appState = AppStateEmpity();
  CompanyModel? companyModel;
  Set<CompanyModel> companies = {};
  final IGetCompaniesRepository getCompaniesRepository;
  final IGetCompanyRepository getCompanyRepository;
  final ICreateCompanyRepository createCompanyRepository;

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
      companies.addAll(await getCompaniesRepository());
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  void changeState(AppState appState) {
    this.appState = appState;
    notifyListeners();
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
}
