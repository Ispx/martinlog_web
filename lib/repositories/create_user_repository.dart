import 'package:dio/dio.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/models/user_model.dart';
import 'package:martinlog_web/services/http/http.dart';

abstract interface class ICreateUserRepository {
  Future<UserModel> call(
      {required String fullname,
      required String document,
      required String email,
      required int idProfile,
      required int idCompany});
}

final class CreateUserRepository implements ICreateUserRepository {
  final IHttp http;
  final String urlBase;
  CreateUserRepository({
    required this.http,
    required this.urlBase,
  });
  @override
  Future<UserModel> call(
      {required String fullname,
      required String document,
      required String email,
      required int idProfile,
      required int idCompany}) async {
    try {
      final response = await http.request<Response>(
          url: urlBase + Endpoints.user,
          method: HttpMethod.POST,
          body: {
            "fullname": fullname,
            "document": document,
            "email": email,
            "idProfile": idProfile,
          },
          headers: {
            "idCompany": idCompany,
          });
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception("Ocorreu um erro ao criar o usuário");
    }
  }
}
