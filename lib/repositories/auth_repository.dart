import 'package:dio/dio.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/services/http/http.dart';
import 'package:martinlog_web/models/auth_model.dart';

abstract interface class IAuthRepository {
  Future<AuthModel> call(String document, String password);
}

class AuthRepository implements IAuthRepository {
  final IHttp http;
  final String urlBase;
  AuthRepository({required this.http, required this.urlBase});
  @override
  Future<AuthModel> call(String document, String password) async {
    try {
      final response = await http.request<Response>(
        url: urlBase + Endpoints.auth,
        method: HttpMethod.POST,
        body: {
          "document": document,
          "password": password,
        },
      );

      return AuthModel.fromJson(Map.castFrom(response.data));
    } catch (e) {
      var message = 'Falha inesperada';
      message = e.toString().split(':').lastOrNull ?? message;
      throw message;
    }
  }
}
