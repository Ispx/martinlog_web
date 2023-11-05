import 'dart:convert';
import 'package:http/http.dart';
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
      if (dateFrom != null) {
        params.addAll({"dateFrom": dateFrom.yyyyMMdd()});
        if (dateUntil == null) throw Exception("dateUntil is required");
        params.addAll({"dateUntil": dateUntil.yyyyMMdd()});
      }
      if (status != null) {
        params.addAll({for (int st in status) "status": st});
      }
      final response = await http.request<Response>(
        url: urlBase + Endpoints.operationAll,
        method: HttpMethod.GET,
        params: params,
      );
      return jsonDecode(response.body)
          .map((e) => OperationModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
