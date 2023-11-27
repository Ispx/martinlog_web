import 'package:get/get.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/state/menu_state.dart';

class MenuViewModel extends GetxController {
  var menuState = MenuState(menuEnum: MenuEnum.Operations).obs;

  void _change(MenuState menuState) {
    this.menuState.value = menuState;
  }

  Future<void> changeMenu(MenuEnum menu, {Function? clousure}) async {
    try {
      if (clousure != null) {
        _change(MenuState(menuEnum: menu, appState: AppStateLoading()));
        await clousure();
      }
      _change(MenuState(menuEnum: menu, appState: AppStateDone()));
    } catch (e) {
      _change(MenuState(menuEnum: menu, appState: AppStateError(e.toString())));
    }
  }
}
