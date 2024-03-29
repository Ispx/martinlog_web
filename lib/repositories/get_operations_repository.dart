import 'package:dio/dio.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
import 'package:martinlog_web/services/http/http.dart';
import 'package:martinlog_web/models/operation_model.dart';

abstract interface class IGetOperationsRepository {
  Future<List<OperationModel>> call(
      {DateTime? dateFrom, DateTime? dateUntil, List<int>? status});
}

class GetOperationsRepository implements IGetOperationsRepository {
  final IHttp http;
  final String urlBase;
  GetOperationsRepository({required this.http, required this.urlBase});

  @override
  Future<List<OperationModel>> call(
      {DateTime? dateFrom, DateTime? dateUntil, List<int>? status}) async {
    try {
      final params = <String, dynamic>{};
      String url = urlBase + Endpoints.operationAll;
      if (dateFrom != null) {
        params.addAll({"dateFrom": dateFrom.yyyyMMddyHHmmss});
        if (dateUntil == null) throw Exception("dateUntil is required");
        params.addAll({"dateUntil": dateUntil.yyyyMMddyHHmmss});
        url +=
            "?dateFrom=${dateFrom.yyyyMMddyHHmmss}&dateUntil=${dateUntil.yyyyMMddyHHmmss}";
      }
      if (status != null) {
        params.addAll({for (int st in status) "status": st});
      }
      final response = await http.request<Response>(
        url: url,
        method: HttpMethod.GET,
        //   params: params,
      );
      var result = List<OperationModel>.from(
          response.data.map((e) => OperationModel.fromJson(e)).toList());
      return result;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
