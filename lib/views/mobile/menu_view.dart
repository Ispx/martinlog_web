import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/extensions/menu_extention.dart';
import 'package:martinlog_web/views/mobile/operation/views/operation_view_mobile.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../core/dependencie_injection_manager/simple.dart';
import '../../enums/profile_type_enum.dart';
import '../../images/app_images.dart';
import '../../state/app_state.dart';
import '../../state/menu_state.dart';
import '../../style/size/app_size.dart';
import '../../style/text/app_text_style.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/company_view_model.dart';
import '../../view_models/dashboard_view_model.dart';
import '../../view_models/dock_view_model.dart';
import '../../view_models/menu_view_model.dart';
import '../../view_models/operation_view_model.dart';
import '../../view_models/user_view_model.dart';
import '../../widgets/app_bar_widget_mobile.dart';
import '../web/company_view.dart';
import '../web/dock_view.dart';
import '../web/users_view.dart';
import 'dashboard_view.dart';

class MenuViewMobile extends StatefulWidget {
  const MenuViewMobile({super.key});

  @override
  State<MenuViewMobile> createState() => _MenuViewMobileState();
}

class _MenuViewMobileState extends State<MenuViewMobile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final MenuViewModel menuViewModel;
  late final Worker worker;

  Widget getViewByMenu(MenuEnum menuEnum) => switch (menuEnum) {
        MenuEnum.Operations => const OperationViewMobile(
            key: ObjectKey(MenuEnum.Operations),
          ),
        MenuEnum.Dock => const DockView(
            key: ObjectKey(MenuEnum.Dock),
          ),
        MenuEnum.Company => const CompanyView(
            key: ObjectKey(MenuEnum.Company),
          ),
        MenuEnum.Users => const UserView(
            key: ObjectKey(MenuEnum.Users),
          ),
        MenuEnum.Dashboard => const DashboardViewMobile()
      };
  @override
  void initState() {
    worker = everAll([
      simple.get<OperationViewModel>().appState,
      simple.get<DockViewModel>().appState,
      simple.get<CompanyViewModel>().appState,
      simple.get<UserViewModel>().appState,
      simple.get<DashboardViewModel>().appState
    ], (state) {
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
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          drawer: DrawerMenu(
              menuViewModel: menuViewModel, scaffoldKey: _scaffoldKey),
          backgroundColor: context.appTheme.backgroundColor,
          body: Obx(() {
            return Column(
              children: [
                AppBarWidgetMobile(
                  key: const ValueKey('AppBarWidgetMobile'),
                  prefix: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      _scaffoldKey.currentState!.openDrawer();
                    },
                  ),
                  backgroundColor: context.appTheme.backgroundColor,
                  title: menuViewModel.menuState.value.menuEnum.title,
                  content: const Center(),
                ),
                Expanded(
                  child: getViewByMenu(
                    menuViewModel.menuState.value.menuEnum,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class DrawerMenu extends StatefulWidget {
  final MenuViewModel menuViewModel;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const DrawerMenu(
      {super.key, required this.menuViewModel, required this.scaffoldKey});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  bool isOpen = false;
  void onTap() {
    isOpen = !isOpen;
    setState(() {});
  }

  // AVISO: a função widget.scaffoldKey.currentState!.closeDrawer(); está comentada!
  // caso queira adicionar a mesma novamente é só descomentar!

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      type: MaterialType.card,
      child: AnimatedContainer(
        duration: 1.seconds,
        curve: Curves.fastLinearToSlowEaseIn,
        width: isOpen ? 160 : 64,
        height: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          color: context.appTheme.secondColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSize.padding),
          child: Column(
            children: [
              SizedBox(
                height: 13.h,
                child: Center(
                  child: Image.asset(
                    isOpen ? AppImages.horizontal : AppImages.icon,
                    width: !isOpen ? 3.w : 10.w,
                  ),
                ),
              ),
              Expanded(
                  child: Column(
                children: [
                  SizedBox(height: AppSize.padding * 2),
                  MenuItem(
                    icon: const Icon(
                      Icons.dashboard,
                      color: Colors.white,
                    ),
                    isOpen: isOpen,
                    title: 'Dashboard',
                    isSelected: widget.menuViewModel.menuState.value.menuEnum ==
                        MenuEnum.Dashboard,
                    onTap: () {
                      setState(() {
                        widget.menuViewModel.changeMenu(MenuEnum.Dashboard);
                        // widget.scaffoldKey.currentState!.closeDrawer();
                      });
                    },
                  ),
                  SizedBox(height: AppSize.padding),
                  MenuItem(
                    icon: const Icon(
                      LineIcons.dolly,
                      color: Colors.white,
                    ),
                    isOpen: isOpen,
                    title: 'Operações',
                    isSelected: widget.menuViewModel.menuState.value.menuEnum ==
                        MenuEnum.Operations,
                    onTap: () {
                      setState(() {
                        widget.menuViewModel.changeMenu(MenuEnum.Operations);
                        // widget.scaffoldKey.currentState!.closeDrawer();
                      });
                    },
                  ),
                  SizedBox(
                    height: AppSize.padding,
                  ),
                ],
              )),
              IconButton(
                onPressed: onTap,
                icon: Icon(
                  isOpen ? Icons.chevron_left : Icons.chevron_right,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final VoidCallback onTap;
  final bool isOpen;
  final bool isSelected;
  final List<ProfileTypeEnum>? profiles;

  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isOpen = false,
    this.isSelected = false,
    this.profiles,
  });

  @override
  Widget build(BuildContext context) {
    return (profiles?.contains(simple
                .get<AuthViewModel>()
                .authModel!
                .idProfile
                .getProfile()) ??
            true)
        ? InkWell(
            onTap: onTap,
            splashColor: context.appTheme.primaryColor,
            child: SizedBox(
              height: 7.h,
              child: Row(
                children: [
                  Container(
                    height: double.maxFinite,
                    width: 5,
                    decoration: BoxDecoration(
                      color: isSelected ? context.appTheme.primaryColor : null,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: isOpen ? AppSize.padding : 0,
                        ),
                        icon,
                        SizedBox(
                          width: isOpen ? AppSize.padding : 0,
                        ),
                        isOpen
                            ? Expanded(
                                child: Text(
                                  title,
                                  style:
                                      AppTextStyle.mobileDisplayMedium(context)
                                          .copyWith(
                                    color: Colors.white,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w300,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
