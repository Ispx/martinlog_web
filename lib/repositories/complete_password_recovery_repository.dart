import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/services/http/http.dart';

abstract interface class ICompletePasswordRecoveryRepository {
  Future<void> call({
    required String document,
    required String token,
    required String password,
  });
}

final class CompletePasswordRecoveryRepository
    implements ICompletePasswordRecoveryRepository {
  final String urlBase;
  final IHttp http;
  CompletePasswordRecoveryRepository(
      {required this.http, required this.urlBase});
  @override
  Future<void> call({
    required String document,
    required String token,
    required String password,
  }) async {
    try {
      await http.request(
          url: urlBase + Endpoints.passwordRecoveryComplete,
          method: HttpMethod.POST,
          body: {
            "document": document,
            "token": token,
            "password": password,
          });
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
