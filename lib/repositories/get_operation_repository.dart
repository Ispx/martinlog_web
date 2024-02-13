import 'package:dio/dio.dart';
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
        url: '$urlBase${Endpoints.operation}/$operationKey',
        method: HttpMethod.GET,
      );
      return OperationModel.fromJson(response.data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
