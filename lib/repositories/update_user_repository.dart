import 'package:dio/dio.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/models/user_model.dart';
import 'package:martinlog_web/services/http/http.dart';

abstract interface class IUpdateUserRepository {
  Future<UserModel> call({
    required String fullname,
    required String document,
    required String email,
    required int idProfile,
    required bool isActive,
  });
}

final class UpdateUserRepository implements IUpdateUserRepository {
  final IHttp http;
  final String urlBase;
  UpdateUserRepository({
    required this.http,
    required this.urlBase,
  });
  @override
  Future<UserModel> call({
    required String fullname,
    required String document,
    required String email,
    required int idProfile,
    required bool isActive,
  }) async {
    try {
      final response = await http.request<Response>(
        url: urlBase + Endpoints.user,
        method: HttpMethod.PUT,
        body: {
          "fullname": fullname,
          "document": document,
          "email": email,
          "idProfile": idProfile,
          "isActive": isActive,
        },
      );
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception("Ocorreu um erro ao atualizar o usuário");
    }
  }
}
