import 'package:dio/dio.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/view_models/branch_office_view_model.dart';

class SwitchBranchOfficeInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (simple.get<BranchOfficeViewModelImpl>().idBranchOfficeActivated !=
        null) {
      options.headers['idBranchOffice'] = simple.get<BranchOfficeViewModelImpl>().idBranchOfficeActivated;
    }
    super.onRequest(options, handler);
  }
}
