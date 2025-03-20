import 'package:dio/dio.dart';

int? idSwitchBranchOffice;

class SwitchBranchOfficeInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (idSwitchBranchOffice != null) {
      options.headers['idBranchOffice'] = idSwitchBranchOffice;
    }
    super.onRequest(options, handler);
  }
}
