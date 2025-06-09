import 'package:get/get.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/profile_type_extension.dart';
import 'package:martinlog_web/models/branch_office_model.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/repositories/create_branch_office_repository.dart';
import 'package:martinlog_web/repositories/get_branch_office_repository.dart';
import 'package:martinlog_web/repositories/get_company_repositoy.dart';
import 'package:martinlog_web/repositories/link_company_to_branch_office_repository.dart';
import 'package:martinlog_web/repositories/unlink_company_to_branch_office_repository.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/company_view_model.dart';
import 'package:martinlog_web/view_models/dashboard_view_model.dart';
import 'package:martinlog_web/view_models/dock_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';

abstract interface class BranchOfficeViewModel {
  Future<void> getAll();
  Future<void> unLinkCompany(
      CompanyModel companyModel, BranchOfficeModel branchOffice);
  Future<void> linkCompany(
      CompanyModel companyModel, BranchOfficeModel branchOffice);
  Future<void> create(String name);
  Future<void> switchBranchOffice(BranchOfficeModel model);
  Future<void> search(String src);
  List<CompanyModel> get companiesBindedBranchOffice;
  List<BranchOfficeModel> get branchs;
  int get idBranchOfficeActivated;
  CompanyModel? companyModel;
}

class BranchOfficeViewModelImpl extends GetxController
    implements BranchOfficeViewModel {
  final UnLinkCompanyToBranchOfficeRepository
      unlinkCompanyToBranchOfficeRepository;

  final LinkCompanyToBranchOfficeRepository linkCompanyToBranchOfficeRepository;
  final GetBranchOfficeRepository getBranchOfficeRepository;
  final CreateBranchOfficeRepository createBranchOfficeRepository;
  final IGetCompanyRepository getCompanyRepository;
  var appState = AppState().obs;
  var branchOfficeList = <BranchOfficeModel>[].obs;
  var branchsSearched = <BranchOfficeModel>[].obs;

  BranchOfficeViewModelImpl({
    required this.unlinkCompanyToBranchOfficeRepository,
    required this.createBranchOfficeRepository,
    required this.getBranchOfficeRepository,
    required this.linkCompanyToBranchOfficeRepository,
    required this.getCompanyRepository,
  });

  void change(AppState newState) => appState.value = newState;
  @override
  Future<void> getAll() async {
    try {
      if (branchOfficeList.isNotEmpty) return;
      change(AppStateLoading());
      if (simple.get<AuthViewModel>().authModel?.idProfile ==
          ProfileTypeEnum.MASTER.idProfileType) {
        branchOfficeList.value = await getBranchOfficeRepository();
      } else {
        final company = await getCompanyRepository();
        branchOfficeList.value = company.branchOffices;
      }
      change(AppStateDone());
    } catch (e) {
      change(AppStateError("Ocorreu um erro ao obter a lista de filiais."));
    }
  }

  @override
  Future<void> linkCompany(
      CompanyModel companyModel, BranchOfficeModel branchOffice) async {
    try {
      change(AppStateLoading());
      await linkCompanyToBranchOfficeRepository(
        idCompany: companyModel.idCompany,
        idBranchOffice: branchOffice.idBranchOffice,
      );
      companyModel.branchOffices.add(branchOffice);

      change(AppStateDone("Filial cadastrada com suceso"));
    } catch (e) {
      change(AppStateError("Ocorreu um erro ao vincular empresa a filial"));
    }
  }

  @override
  Future<void> create(String name) async {
    try {
      change(AppStateLoading());
      final branchOffice = await createBranchOfficeRepository(name: name);
      branchOfficeList.add(branchOffice);
      change(AppStateDone());
    } catch (e) {
      change(AppStateError("Ocorreu um erro ao vincular empresa a filial"));
    }
  }

  @override
  Future<void> switchBranchOffice(BranchOfficeModel? model) async {
    if (model != null) {
      branchOfficeActivated.value = model;
    }
    simple.get<OperationViewModel>().operations.clear();
    simple.get<OperationViewModel>().operationsFilted.clear();
    simple.get<DashboardViewModel>().operations.clear();
    simple.get<DockViewModel>().docks.clear();
  }

  @override
  List<BranchOfficeModel> get branchs => branchOfficeList ?? [];

  var branchOfficeActivated =
      BranchOfficeModel(idBranchOffice: -1, name: '').obs;

  @override
  Future<void> search(String src) async {
    try {
      List<BranchOfficeModel> branchs = <BranchOfficeModel>[];
      branchs.addAll(branchOfficeList);
      if (src.isEmpty) {
        branchsSearched.value = [];
        return;
      }
      final regex = RegExp(src);
      branchsSearched.value = branchs
          .where(
            (p0) => regex.hasMatch(p0.name),
          )
          .toList();
    } catch (e) {
      branchsSearched.value = [];
    }
  }

  @override
  CompanyModel? companyModel;

  void setCompanyToBind(CompanyModel company) {
    companyModel = company;
  }

  @override
  int get idBranchOfficeActivated => branchOfficeActivated.value.idBranchOffice;

  @override
  List<CompanyModel> get companiesBindedBranchOffice {
    final result = <CompanyModel>[];

    if (branchOfficeActivated.value.idBranchOffice <= 0) {
      return [];
    }
    for (var company in simple.get<CompanyViewModel>().companies) {
      for (var branch in company.branchOffices) {
        if (branch.idBranchOffice ==
            branchOfficeActivated.value.idBranchOffice) {
          result.add(company);
        }
      }
    }
    return result;
  }

  @override
  Future<void> unLinkCompany(
      CompanyModel companyModel, BranchOfficeModel branchOffice) async {
    try {
      change(AppStateLoading());
      await unlinkCompanyToBranchOfficeRepository(
        idCompany: companyModel.idCompany,
        idBranchOffice: branchOffice.idBranchOffice,
      );
      companyModel.branchOffices.add(branchOffice);

      change(AppStateDone("Filial cadastrada com suceso"));
    } catch (e) {
      change(AppStateError("Ocorreu um erro ao vincular empresa a filial"));
    }
  }
}
