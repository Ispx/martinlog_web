class AppState {}

class AppStateEmpity extends AppState {}

class AppStateLoading extends AppState {}

class AppStateLoadingMore extends AppState {}

class AppStateDone<T> extends AppState {
  final T? result;
  AppStateDone([this.result]);
}

class AppStateError extends AppState {
  final String? msg;
  AppStateError(this.msg);
}
