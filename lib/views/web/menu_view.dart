import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/menu_extention.dart';
import 'package:martinlog_web/state/menu_state.dart';
import 'package:martinlog_web/view_models/menu_view_model.dart';
import 'package:martinlog_web/views/web/bind_branch_office_view.dart';
import 'package:martinlog_web/views/web/branch_office_view.dart';
import 'package:martinlog_web/views/web/company_view.dart';
import 'package:martinlog_web/views/web/dashboard_view.dart';
import 'package:martinlog_web/views/web/dock_view.dart';
import 'package:martinlog_web/views/web/operation_view.dart';
import 'package:martinlog_web/views/web/users_view.dart';
import 'package:martinlog_web/widgets/app_bar_widget.dart';
import 'package:martinlog_web/widgets/drawer_menu_widget.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  late final MenuViewModel menuViewModel;

  Widget getViewByMenu(MenuEnum menuEnum) => switch (menuEnum) {
        MenuEnum.Operations =>
          const OperationView(key: ObjectKey(MenuEnum.Operations)),
        MenuEnum.Dock => const DockView(key: ObjectKey(MenuEnum.Dock)),
        MenuEnum.Company => const CompanyView(key: ObjectKey(MenuEnum.Company)),
        MenuEnum.Users => const UserView(key: ObjectKey(MenuEnum.Users)),
        MenuEnum.Dashboard =>
          const DashboardView(key: ObjectKey(MenuEnum.Dashboard)),
        MenuEnum.BranchOffice =>
          const BranchOfficeView(key: ObjectKey(MenuEnum.BranchOffice)),
        MenuEnum.BindBranchOffice =>
          const BindBranchOfficeView(key: ObjectKey(MenuEnum.BindBranchOffice))
      };
  @override
  void initState() {
    menuViewModel = simple.get<MenuViewModel>();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.backgroundColor,
      body: Obx(
        () {
          return Row(
            children: [
              DrawerMenuWidget(
                menuViewModel: menuViewModel,
              ),
              Expanded(
                child: Column(
                  children: [
                    AppBarWidget(
                      backgroundColor: context.appTheme.backgroundColor,
                      title: menuViewModel.menuState.value.menuEnum.title,
                      content: const Center(),
                    ),
                    Expanded(
                      child:
                          getViewByMenu(menuViewModel.menuState.value.menuEnum),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
