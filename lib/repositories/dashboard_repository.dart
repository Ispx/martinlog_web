import 'package:dio/dio.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
import 'package:martinlog_web/models/dashboard_model.dart';
import 'package:martinlog_web/services/http/http.dart';

abstract interface class IDashboardRepository {
  Future<List<DashboardModel>> call();
}

final class DashboardRepository implements IDashboardRepository {
  final String urlBase;
  final Http http;
  DashboardRepository({required this.http, required this.urlBase});
  @override
  Future<List<DashboardModel>> call() async {
    try {
      final validUntil = DateTime.now().toUtc();
      final validSince = DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day > 15 ? 15 : 1)
          .toUtc();

      final response = await http.request<Response>(
        url:
            "$urlBase${Endpoints.dashboard}?validUntil=${validUntil.yyyyMMddyHHmmss}&validSince=${validSince.yyyyMMddyHHmmss}",
        method: HttpMethod.GET,
      );

      var result = List<DashboardModel>.from(
          response.data.map((e) => DashboardModel.fromJson(e)).toList());
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
