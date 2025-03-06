import 'package:martinlog_web/core/consts/endpoints.dart';

import '../services/http/http.dart';

abstract interface class IUpdateOperationRepository {
  Future<void> call({
    required String operationKey,
    int? progress,
    String? additionalData,
    String? liscensePlate,
    String? urlImage,
    String? description,
    String? dockCode,
    int? idCompany,
    String? route,
    String? place,
  });
}

class UpdateOperationRepository implements IUpdateOperationRepository {
  final IHttp http;
  final String urlBase;
  UpdateOperationRepository({required this.http, required this.urlBase});
  @override
  Future<void> call({
    required String operationKey,
    int? progress,
    String? additionalData,
    String? liscensePlate,
    String? urlImage,
    String? description,
    String? dockCode,
    int? idCompany,
    String? route,
    String? place,
  }) async {
    final data = {};
    if (progress != null) {
      data.addAll({"progress": progress});
    }
    if (additionalData != null) {
      data.addAll({
        "additionalData": additionalData,
      });
    }
    if (urlImage != null) {
      data.addAll({
        "urlImage": urlImage,
      });
    }
    if (description != null) {
      data.addAll({
        "description": description,
      });
    }
    if (dockCode != null) {
      data.addAll({
        "dockCode": dockCode,
      });
    }
    if (idCompany != null) {
      data.addAll({
        "idCompany": idCompany,
      });
    }
    if (liscensePlate != null) {
      data.addAll({
        "liscensePlate": liscensePlate,
      });
    }
    if (route != null) {
      data.addAll({
        "route": route,
      });
    }
    if (place != null) {
      data.addAll({
        "place": place,
      });
    }
    try {
      await http.request(
        url: urlBase +
            Endpoints.operationUpdate.replaceAll(
              "<operationKey>",
              operationKey,
            ),
        method: HttpMethod.PUT,
        body: data,
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
