class AppState {}

class AppStateEmpity extends AppState {}

class AppStateLoading extends AppState {}

class AppStateDone extends AppState {
  AppStateDone();
}

class AppStateError extends AppState {
  final String? msg;
  AppStateError(this.msg);
}
