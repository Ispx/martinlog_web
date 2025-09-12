import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/core/config/env_confg.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/extensions/menu_extention.dart';
import 'package:martinlog_web/state/menu_state.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/branch_office_view_model.dart';
import 'package:martinlog_web/view_models/menu_view_model.dart';
import 'package:martinlog_web/views/web/bind_branch_office_view.dart';
import 'package:martinlog_web/views/web/branch_office_view.dart';
import 'package:martinlog_web/views/web/company_view.dart';
import 'package:martinlog_web/views/web/dashboard_view.dart';
import 'package:martinlog_web/views/web/dock_view.dart';
import 'package:martinlog_web/views/web/operation_view.dart';
import 'package:martinlog_web/views/web/settings_view.dart';
import 'package:martinlog_web/views/web/users_view.dart';
import 'package:martinlog_web/widgets/app_bar_widget.dart';
import 'package:martinlog_web/widgets/drawer_menu_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:web_socket_client/web_socket_client.dart';

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
          const BindBranchOfficeView(key: ObjectKey(MenuEnum.BindBranchOffice)),
        MenuEnum.Settings =>
          const SettingsView(key: ObjectKey(MenuEnum.Settings)),
      };
  @override
  void initState() {
    menuViewModel = simple.get<MenuViewModel>();

    final uri = Uri.parse(
        '${EnvConfig.wsBase}/ws/branch-office/${simple.get<BranchOfficeViewModelImpl>().idBranchOfficeActivated}/operations');
    final socket = WebSocket(uri);
    if (simple.get<AuthViewModel>().authModel!.idProfile.getProfile() ==
        ProfileTypeEnum.MASTER) {
      socket.send('connected');
    }
    socket.messages.listen((message) {
      showFloatingBanner(
        context,
        message,
      );
    });
    super.initState();
  }

  void showFloatingBanner(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 2)}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 25,
        left: 30.w,
        right: 30.w,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.appTheme.secondColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nova atualização",
                        style: AppTextStyle.displaySmall(context).copyWith(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: AppSize.padding / 2,
                      ),
                      Text(
                        message,
                        style: AppTextStyle.displayMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => entry.remove(),
                )
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(duration, () {
      entry.remove();
    });
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
