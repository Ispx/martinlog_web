import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/models/operation_model.dart';
import 'package:martinlog_web/services/http/http.dart';

abstract interface class IGetOperationsPedingRepository {
  Future<List<OperationModel>> call();
}

class GetOperationsPedingRepository implements IGetOperationsPedingRepository {
  final IHttp http;
  final String urlBase;
  GetOperationsPedingRepository({required this.http, required this.urlBase});
  @override
  Future<List<OperationModel>> call() async {
    try {
      final response = await http.request<Response>(
        url: '$urlBase${Endpoints.operationPending}',
        method: HttpMethod.GET,
      );
      var result = await Isolate.run(() => List<OperationModel>.from(
          response.data.map((e) => OperationModel.fromJson(e)).toList()));
      return result;
    } catch (e) {
      throw "Ocorreu um erro ao obter as operações em execução";
    }
  }
}
