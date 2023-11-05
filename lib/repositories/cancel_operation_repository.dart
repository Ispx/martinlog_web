import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/services/http/http.dart';

abstract interface class ICancelOperationRepository {
  Future<void> call(String operationKey);
}

class CancelOperationRepository implements ICancelOperationRepository {
  final IHttp http;
  final String urlBase;
  CancelOperationRepository({required this.http, required this.urlBase});
  @override
  Future<void> call(String operationKey) async {
    try {
      await http.request(
        url: urlBase +
            Endpoints.operationCancel
                .replaceAll("<operationKey>", operationKey),
        method: HttpMethod.POST,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
