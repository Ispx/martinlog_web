import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/menu_extention.dart';
import 'package:martinlog_web/functions/futures.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/state/menu_state.dart';
import 'package:martinlog_web/view_models/menu_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';
import 'package:martinlog_web/views/operation_view.dart';
import 'package:martinlog_web/widgets/app_bar_widget.dart';
import 'package:martinlog_web/widgets/circular_progress_indicator_widget.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  late final MenuViewModel menuViewModel;
  late final Worker worker;
  Widget getViewByMenu(MenuEnum menuEnum) => switch (menuEnum) {
        MenuEnum.Operations => OperationView(),
        _ => const Center()
      };
  @override
  void initState() {
    worker = everAll([simple.get<OperationViewModel>().appState], (state) {
      menuViewModel.changeStatus(state as AppState);
    });
    menuViewModel = simple.get<MenuViewModel>();
    super.initState();
  }

  @override
  void dispose() {
    worker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.backgroundColor,
      appBar: AppBarWidget(
        context: context,
        backgroundColor: context.appTheme.backgroundColor,
        title: menuViewModel.menuState.value.menuEnum.title,
        content: const Center(),
      ),
      body: FutureBuilder(
        future: getAccountInfo,
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicatorWidget());
          }
          return Obx(() {
            return Column(
              children: [
                menuViewModel.menuState.value.appState is AppStateLoading
                    ? SizedBox(
                        height: 6,
                        child: LinearProgressIndicator(
                          color: context.appTheme.secondColor,
                          backgroundColor: context.appTheme.greyColor,
                        ),
                      )
                    : const SizedBox.shrink(),
                Expanded(
                  child: getViewByMenu(menuViewModel.menuState.value.menuEnum),
                ),
              ],
            );
          });
        },
      ),
    );
  }
}
