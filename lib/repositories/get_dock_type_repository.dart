import 'package:dio/dio.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/models/dock_type_model.dart';
import 'package:martinlog_web/services/http/http.dart';

abstract interface class IGetDockTypeRepository {
  Future<List<DockTypeModel>> call();
}

class GetDockTypeRepository implements IGetDockTypeRepository {
  final IHttp http;
  final String urlBase;
  GetDockTypeRepository({required this.http, required this.urlBase});
  @override
  Future<List<DockTypeModel>> call() async {
    try {
      final response = await http.request<Response>(
        url: urlBase + Endpoints.dockAll,
        method: HttpMethod.GET,
      );

      var result = List<DockTypeModel>.from(
          response.data.map((e) => DockTypeModel.fromJson(e)).toList());
      return result;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
