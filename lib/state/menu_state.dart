import 'package:martinlog_web/state/app_state.dart';

enum MenuEnum { Operations, Dashboard, Dock, Company, Users, BranchOffice }

class MenuState {
  final MenuEnum menuEnum;
  final AppState? appState;

  MenuState({required this.menuEnum, this.appState});

  MenuState copyWith({
    MenuEnum? menuEnum,
    AppState? appState,
  }) {
    return MenuState(
      menuEnum: menuEnum ?? this.menuEnum,
      appState: appState ?? this.appState,
    );
  }
}
