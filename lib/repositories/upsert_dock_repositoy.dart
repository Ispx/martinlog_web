import 'package:dio/dio.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/services/http/http.dart';
import 'package:martinlog_web/models/dock_model.dart';

abstract interface class IUpsertDockRepository {
  Future<DockModel> call({
    required String code,
    required int idDockType,
    required bool isActive,
    required int? idBranchOffice,
  });
}

class UpsertDockRepository implements IUpsertDockRepository {
  final IHttp http;
  final String urlBase;
  UpsertDockRepository({required this.http, required this.urlBase});
  @override
  Future<DockModel> call({
    required String code,
    required int idDockType,
    required bool isActive,
    required int? idBranchOffice,
  }) async {
    try {
      final response = await http.request<Response>(
        url: urlBase + Endpoints.dock,
        method: HttpMethod.PUT,
        body: {
          "code": code,
          "type": idDockType,
          "isActive": isActive,
          "idBranchOffice": idBranchOffice,
        },
      );
      return DockModel.fromJson(response.data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
