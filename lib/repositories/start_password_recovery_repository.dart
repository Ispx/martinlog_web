import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/services/http/http.dart';

abstract interface class IStartPasswordRecoveryRepository {
  Future<void> call(String document);
}

final class StartPasswordRecoveryRepository
    implements IStartPasswordRecoveryRepository {
  final String urlBase;
  final IHttp http;
  StartPasswordRecoveryRepository({required this.http, required this.urlBase});
  @override
  Future<void> call(String document) async {
    try {
      await http.request(
          url: urlBase + Endpoints.passwordRecoveryStart,
          method: HttpMethod.POST,
          body: {
            "document": document,
          });
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
