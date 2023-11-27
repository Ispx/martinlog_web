import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/menu_extention.dart';
import 'package:martinlog_web/functions/futures.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/state/menu_state.dart';
import 'package:martinlog_web/view_models/menu_view_model.dart';
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
  Widget getViewByMenu(MenuEnum menuEnum) => switch (menuEnum) {
        MenuEnum.Operations => OperationView(),
        _ => const Center()
      };
  @override
  void initState() {
    menuViewModel = simple.get<MenuViewModel>();
    super.initState();
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
                menuViewModel.menuState.value is AppStateLoading
                    ? const SizedBox(
                        height: 8,
                        child: LinearProgressIndicator(),
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
