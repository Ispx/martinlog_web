import 'package:dio/dio.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/profile_type_extension.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';

class SwitchCompanyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final authModel = simple.get<AuthViewModel>().authModel;

    if ((options.uri.path == Endpoints.operationAll ||
            options.uri.path == Endpoints.dashboard) &&
        authModel?.idProfile == ProfileTypeEnum.MASTER.idProfileType) {
      super.onRequest(options, handler);
      return;
    } else if (options.uri.path == Endpoints.operation) {
      super.onRequest(options, handler);
      return;
    } else if (options.uri.path == Endpoints.user) {
      super.onRequest(options, handler);
      return;
    }
    if (authModel != null) {
      options.headers['idCompany'] = authModel.idCompany.toString();
    }
    super.onRequest(options, handler);
  }
}
