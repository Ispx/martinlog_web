import 'dart:io';

import 'package:martinlog_web/models/auth_model.dart';
import 'package:martinlog_web/repositories/auth_repository.dart';
import 'package:martinlog_web/state/app_state.dart';

abstract interface class IAuthViewModel {
  Future<void> login(String document, String password);
  Future<void> loggout();
}

class AuthViewModel implements IAuthViewModel {
  final IAuthRepository authRepository;
  AppState appState = AppStateEmpity();
  AuthModel? authModel;
  AuthViewModel({required this.authRepository});

  @override
  Future<void> loggout() {
    exit(0);
  }

  @override
  Future<void> login(String document, String password) async {
    try {
      appState = AppStateLoading();
      authModel = await authRepository(document, password);
      appState = AppStateDone();
    } catch (e) {
      appState = AppStateError(e.toString());
    }
  }
}
