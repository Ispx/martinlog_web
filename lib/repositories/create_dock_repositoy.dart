import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/enums/dock_type_enum.dart';
import 'package:martinlog_web/extensions/dock_type_extension.dart';
import 'package:martinlog_web/services/http/http.dart';
import 'package:martinlog_web/models/dock_model.dart';

abstract interface class ICreateDockRepository {
  Future<DockModel> call({required String code, required DockType dockType});
}

class CreateDockRepository implements ICreateDockRepository {
  final IHttp http;
  final String urlBase;
  CreateDockRepository({required this.http, required this.urlBase});
  @override
  Future<DockModel> call(
      {required String code, required DockType dockType}) async {
    try {
      final response = await http.request<Response>(
        url: urlBase + Endpoints.dock,
        method: HttpMethod.PUT,
        body: {
          "code": code,
          "type": dockType.idDockType,
          "isActive": true,
        },
      );
      return DockModel.fromJson(response.data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
