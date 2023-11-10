import 'package:martinlog_web/core/consts/endpoints.dart';
import '../services/http/http.dart';

abstract interface class IUpdateProgressOperationRepository {
  Future<void> call({required String operationKey, required int progress});
}

class UpdateProgressOperationRepository
    implements IUpdateProgressOperationRepository {
  final IHttp http;
  final String urlBase;
  UpdateProgressOperationRepository(
      {required this.http, required this.urlBase});
  @override
  Future<void> call(
      {required String operationKey, required int progress}) async {
    try {
      await http.request(
        url: urlBase +
            Endpoints.operationProgress
                .replaceAll("<operationKey>", operationKey),
        method: HttpMethod.PUT,
        body: {
          "progress": progress,
        },
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
