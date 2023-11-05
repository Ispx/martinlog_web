import 'package:http_interceptor/http_interceptor.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';

class SwitchCompanyInterceptor implements InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final authModel = simple.get<AuthViewModel>().authModel;
    if (authModel != null) {
      request.headers['idCompany'] = authModel.idCompany.toString();
    }
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse(
          {required BaseResponse response}) async =>
      response;

  @override
  Future<bool> shouldInterceptRequest() async => true;

  @override
  Future<bool> shouldInterceptResponse() async => false;
}
