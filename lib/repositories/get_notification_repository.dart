import 'package:dio/dio.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/models/notification_model.dart';
import 'package:martinlog_web/services/http/http.dart';

abstract interface class IGetNotificationsRepository {
  Future<List<NotificationModel>> call();
}

final class GetNotificationRepositoryImp implements IGetNotificationsRepository {
  final IHttp http;
  final String urlBase;
  GetNotificationRepositoryImp({required this.http, required this.urlBase});
  @override
  Future<List<NotificationModel>> call() async {
    String url = urlBase + Endpoints.notificationAll;
    final response = await http.request<Response>(
      url: url,
      method: HttpMethod.GET,
    );
    var result = List<NotificationModel>.from(
        response.data.map((e) => NotificationModel.fromJson(e)).toList());
    return result;
  }
}
