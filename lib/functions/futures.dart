import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/view_models/company_view_model.dart';
import 'package:martinlog_web/view_models/dock_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';

Future getAccountInfo = Future.sync(() async {
  await simple.get<OperationViewModel>().getAll();
  await simple.get<CompanyViewModel>().getCompany();
  await simple.get<CompanyViewModel>().getAllCompanies();
  await simple.get<DockViewModel>().getAll();
  return true;
});

Future getOperationsInfo = Future.value([
  simple.get<OperationViewModel>().getAll(),
]);

Future getDocksInfo = Future.value([
  simple.get<DockViewModel>().getAll(),
]);
