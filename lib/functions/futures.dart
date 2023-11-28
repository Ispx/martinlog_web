import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/profile_type_extension.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/company_view_model.dart';
import 'package:martinlog_web/view_models/dock_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';

Future getAccountInfo = Future.sync(() async {
  await simple.get<OperationViewModel>().getAll();
  if (simple.get<AuthViewModel>().authModel?.idProfile ==
      ProfileTypeEnum.MASTER.idProfileType) {
    await simple.get<CompanyViewModel>().getAllCompanies();
  }
  await simple.get<CompanyViewModel>().getCompany();
  await simple.get<DockViewModel>().getAll();
  return true;
});
