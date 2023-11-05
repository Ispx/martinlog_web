import 'dart:convert';
import 'package:http/http.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/services/http/http.dart';
import 'package:martinlog_web/models/operation_model.dart';

abstract interface class IGetOperationRepository {
  Future<OperationModel> call(String operationKey);
}

class GetOperationRepository implements IGetOperationRepository {
  final IHttp http;
  final String urlBase;
  GetOperationRepository({required this.http, required this.urlBase});
  @override
  Future<OperationModel> call(String operationKey) async {
    try {
      final response = await http.request<Response>(
        url: urlBase +
            Endpoints.operation.replaceAll('<operationKey>', operationKey),
        method: HttpMethod.GET,
      );
      return OperationModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
