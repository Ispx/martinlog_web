import 'dart:convert';

import 'package:http/http.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/services/http/http.dart';
import 'package:martinlog_web/models/dock_model.dart';

abstract interface class IGetDocksRepository {
  Future<List<DockModel>> call();
}

class GetDocksRepository implements IGetDocksRepository {
  final IHttp http;
  final String urlBase;
  GetDocksRepository({required this.http, required this.urlBase});
  @override
  Future<List<DockModel>> call() async {
    try {
      final response = await http.request<Response>(
        url: urlBase + Endpoints.dockAll,
        method: HttpMethod.GET,
      );
      return jsonDecode(response.body)
          .map((e) => DockModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
