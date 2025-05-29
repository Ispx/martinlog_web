import 'package:get/get.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/profile_type_extension.dart';
import 'package:martinlog_web/models/branch_office_model.dart';
import 'package:martinlog_web/repositories/create_branch_office_repository.dart';
import 'package:martinlog_web/repositories/get_branch_office_repository.dart';
import 'package:martinlog_web/repositories/get_company_repositoy.dart';
import 'package:martinlog_web/repositories/link_company_to_branch_office_repository.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/dashboard_view_model.dart';
import 'package:martinlog_web/view_models/dock_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';

abstract interface class BranchOfficeViewModel {
  Future<void> getAll();
  Future<void> linkCompany(int idCompany, int idBranchOffice);
  Future<void> create(String name);
  Future<void> switchBranchOffice(BranchOfficeModel model);
  List<BranchOfficeModel> get branchs;
  int? idBranchOfficeActivated;
}

class BranchOfficeViewModelImpl extends GetxController
    implements BranchOfficeViewModel {
  final LinkCompanyToBranchOfficeRepository linkCompanyToBranchOfficeRepository;
  final GetBranchOfficeRepository getBranchOfficeRepository;
  final CreateBranchOfficeRepository createBranchOfficeRepository;
  final IGetCompanyRepository getCompanyRepository;
  var appState = AppState().obs;
  var branchOfficeList = <BranchOfficeModel>[].obs;

  BranchOfficeViewModelImpl({
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
  Future<void> linkCompany(int idCompany, int idBranchOffice) async {
    try {
      change(AppStateLoading());
      await linkCompanyToBranchOfficeRepository(
        idCompany: idCompany,
        idBranchOffice: idBranchOffice,
      );
      change(AppStateDone());
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
    idBranchOfficeActivated = model?.idBranchOffice;
    simple.get<OperationViewModel>().operations.clear();
    simple.get<OperationViewModel>().operationsFilted.clear();
    simple.get<DashboardViewModel>().operations.clear();
    simple.get<DockViewModel>().docks.clear();
  }

  @override
  List<BranchOfficeModel> get branchs => branchOfficeList ?? [];

  @override
  int? idBranchOfficeActivated = -1;
}
