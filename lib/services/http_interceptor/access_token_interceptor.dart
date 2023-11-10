import 'package:dio/dio.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';

class AccessTokenInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final authModel = simple.get<AuthViewModel>().authModel;

    if (authModel != null) {
      options.headers['Authorization'] = 'Bearer ${authModel.accessToken}';
    }
    super.onRequest(options, handler);
  }
}
