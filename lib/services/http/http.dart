import 'package:dio/dio.dart';
import 'package:martinlog_web/services/http_interceptor/access_token_interceptor.dart';
import 'package:martinlog_web/services/http_interceptor/switch_company_interceptor.dart';
import 'package:martinlog_web/services/http_interceptor/unauthorized_interceptor.dart';

enum HttpMethod { GET, POST, PUT }

abstract interface class IHttp {
  Future<T> request<T>({
    required String url,
    required HttpMethod method,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? params,
  });
}

class Http implements IHttp {
  final dio = Dio()
    ..interceptors.addAll([
      AccessTokenInterceptor(),
      SwitchCompanyInterceptor(),
      UnauthorizedInterceptor(),
    ]);

  @override
  Future<T> request<T>(
      {required String url,
      required HttpMethod method,
      Map<String, String>? headers,
      Map<String, dynamic>? body,
      Map<String, dynamic>? params}) async {
    dio.options.headers = headers ?? {};
    try {
      return switch (method) {
        HttpMethod.GET => await dio.get(url),
        HttpMethod.POST => await dio.post(url, data: body),
        HttpMethod.PUT => await dio.post(url, data: body)
      } as T;
    } on DioException catch (e) {
      throw e.response?.data ?? "Falha inesperada";
    }
  }
}
