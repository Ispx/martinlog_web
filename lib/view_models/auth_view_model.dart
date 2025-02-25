import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/state_manager.dart';
import 'package:martinlog_web/core/consts/routes.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/models/auth_model.dart';
import 'package:martinlog_web/navigator/go_to.dart';
import 'package:martinlog_web/repositories/auth_repository.dart';
import 'package:martinlog_web/state/app_state.dart';

const passwordKey = 'passwordKey';
const documentKey = 'documentKey';

abstract interface class IAuthViewModel {
  Future<void> login(String document, String password);
  Future<void> loggout();
  Future<void> autoLogin();
  Future<void> init();
}

class AuthViewModel implements IAuthViewModel {
  final IAuthRepository authRepository;
  var appState = AppState().obs;
  var documentStored = ''.obs;
  var passwordStored = ''.obs;
  final _storage = const FlutterSecureStorage();

  AuthModel? authModel;
  AuthViewModel({required this.authRepository});

  @override
  Future<void> loggout() async {
    simple.reset();
    GoTo.removeAllPreviousAndGoTo(Routes.auth);
  }

  @override
  Future<void> login(String document, String password) async {
    try {
      changeState(AppStateLoading());

      authModel = await authRepository(document, password);
      _saveValueInLocalStorage(documentKey, document);
      _saveValueInLocalStorage(passwordKey, password);

      simple.update<AuthViewModel>(() => this);
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  void changeState(AppState appState) {
    this.appState.value = appState;
  }

  Future<void> _saveValueInLocalStorage(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> _getValueInLocalStorage(String key) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> autoLogin() async {
    try {
      final document = await _getValueInLocalStorage(documentKey);
      final password = await _getValueInLocalStorage(passwordKey);
      if (document == null || password == null) return;
      authModel = await authRepository(document, password);
      simple.update<AuthViewModel>(() => this);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> init() async {
    documentStored.value = (await _getValueInLocalStorage(documentKey)) ?? '';
  }
}
