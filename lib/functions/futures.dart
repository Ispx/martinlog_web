import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/profile_type_extension.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/branch_office_view_model.dart';
import 'package:martinlog_web/view_models/company_view_model.dart';
import 'package:martinlog_web/view_models/dock_view_model.dart';
import 'package:martinlog_web/view_models/user_view_model.dart';

Future Function() funcGetAccountInfo = () {
  return Future.sync(() {
    if (simple.get<AuthViewModel>().authModel?.idProfile ==
        ProfileTypeEnum.MASTER.idProfileType) {
      simple.get<CompanyViewModel>().getAllCompanies();
      simple.get<UserViewModel>().getAll();
    }
    simple.get<BranchOfficeViewModelImpl>().getAll();
    simple.get<CompanyViewModel>().getCompany();
    simple.get<DockViewModel>().getAll();
  });
};
