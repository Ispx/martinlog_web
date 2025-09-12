import 'package:dio/dio.dart';

import '../core/consts/endpoints.dart';
import '../services/http/http.dart';

abstract interface class IUpdateViewedNotificationRepository {
  Future<void> call(int idNotification);
}

final class UpdateViewedNotificationRepositoryImp
    implements IUpdateViewedNotificationRepository {
  final IHttp http;
  final String urlBase;
  UpdateViewedNotificationRepositoryImp({
    required this.http,
    required this.urlBase,
  });
  @override
  Future<void> call(int idNotification) async {
    try {
      String url = urlBase +
          Endpoints.notificationViewedUpdate
              .replaceAll('<idNotification>', idNotification.toString());
      await http.request<Response>(
        url: url,
        method: HttpMethod.PUT,
      );
    } catch (e) {
      print(e.toString());
    }
  }
}
