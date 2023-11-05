import 'package:http_interceptor/http_interceptor.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';

class UnauthorizedInterceptor implements InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async =>
      request;

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    if (response.statusCode == 401) {
      await simple.get<AuthViewModel>().loggout();
      return response;
    }
    return response;
  }

  @override
  Future<bool> shouldInterceptRequest() async => false;

  @override
  Future<bool> shouldInterceptResponse() async => true;
}
