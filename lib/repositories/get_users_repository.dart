import 'package:dio/dio.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/models/user_model.dart';
import 'package:martinlog_web/services/http/http.dart';

abstract interface class IGetUsersRepository {
  Future<List<UserModel>> call();
}

final class GetUsersRepository implements IGetUsersRepository {
  final IHttp http;
  final String urlBase;
  GetUsersRepository({required this.http, required this.urlBase});

  @override
  Future<List<UserModel>> call() async {
    try {
      final response = await http.request<Response>(
        url: urlBase + Endpoints.userAll,
        method: HttpMethod.GET,
      );
      var result = List<UserModel>.from(
          response.data.map((e) => UserModel.fromJson(e)).toList());
      return result;
    } catch (e) {
      throw Exception("Ocorreu um erro ao obter a lista de usuários");
    }
  }
}
