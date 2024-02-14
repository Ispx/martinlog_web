import 'package:martinlog_web/core/consts/endpoints.dart';
import '../services/http/http.dart';

abstract interface class IUpdateOperationRepository {
  Future<void> call({
    required String operationKey,
    required int progress,
    required String? additionalData,
  });
}

class UpdateOperationRepository implements IUpdateOperationRepository {
  final IHttp http;
  final String urlBase;
  UpdateOperationRepository({required this.http, required this.urlBase});
  @override
  Future<void> call({
    required String operationKey,
    required int progress,
    required String? additionalData,
  }) async {
    try {
      await http.request(
        url: urlBase +
            Endpoints.operationUpdate
                .replaceAll("<operationKey>", operationKey),
        method: HttpMethod.PUT,
        body: {
          "progress": progress,
          "additionalData": additionalData,
        },
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
