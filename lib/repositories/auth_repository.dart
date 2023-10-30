import 'package:martinlog_web/models/auth_model.dart';

abstract interface class IAuthRepository {
  Future<AuthModel> call(String document, String password);
}

class AuthRepository implements IAuthRepository {
  @override
  Future<AuthModel> call(String document, String password) {
    // TODO: implement call
    throw UnimplementedError();
  }
}
