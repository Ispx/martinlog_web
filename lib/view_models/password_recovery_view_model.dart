import 'package:get/get.dart';
import 'package:martinlog_web/repositories/complete_password_recovery_repository.dart';
import 'package:martinlog_web/repositories/start_password_recovery_repository.dart';
import 'package:martinlog_web/state/app_state.dart';

abstract interface class IPasswordRecoveryViewModel {
  Future<void> start(String document);
  Future<void> complete({
    required String token,
    required String password,
  });
}

final class PasswordRecoveryViewModel extends GetxController
    implements IPasswordRecoveryViewModel {
  final IStartPasswordRecoveryRepository startPasswordRecoveryRepository;
  final ICompletePasswordRecoveryRepository completePasswordRecoveryRepository;
  var appState = AppState().obs;
  String document = '';
  PasswordRecoveryViewModel({
    required this.completePasswordRecoveryRepository,
    required this.startPasswordRecoveryRepository,
  });
  void changeState(AppState appState) {
    this.appState.value = appState;
  }

  @override
  Future<void> complete(
      {required String token, required String password}) async {
    try {
      changeState(AppStateLoading());
      await completePasswordRecoveryRepository(
        document: document,
        token: token,
        password: password,
      );
      changeState(AppStateDone<String>('complete'));
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> start(String document) async {
    try {
      changeState(AppStateLoading());
      await startPasswordRecoveryRepository(
        document,
      );
      this.document = document;
      changeState(AppStateDone<String>('start'));
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }
}
