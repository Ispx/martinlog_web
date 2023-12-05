import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/menu_extention.dart';
import 'package:martinlog_web/functions/futures.dart';
import 'package:martinlog_web/images/app_images.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/state/menu_state.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/menu_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';
import 'package:martinlog_web/views/operation_view.dart';
import 'package:martinlog_web/widgets/app_bar_widget.dart';
import 'package:martinlog_web/widgets/circular_progress_indicator_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
            return Row(
              children: [
                DrawerMenu(
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
                        child: getViewByMenu(
                            menuViewModel.menuState.value.menuEnum),
                      ),
                    ],
                  ),
                ),
              ],
            );
          });
        },
      ),
    );
  }
}

class DrawerMenu extends StatefulWidget {
  final MenuViewModel menuViewModel;
  const DrawerMenu({super.key, required this.menuViewModel});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  bool isOpen = false;
  void onTap() {
    isOpen = !isOpen;
    setState(() {});
  }

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
        width: isOpen ? 15.w : 5.w,
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
                  child: SvgPicture.asset(
                    isOpen ? AppImages.longLogo : AppImages.shortLogo,
                    width: !isOpen ? 3.w : 10.w,
                  ),
                ),
              ),
              Expanded(
                  child: Column(
                children: [
                  SizedBox(height: AppSize.padding * 2),
                  MenuItem(
                    icon: Icon(
                      Icons.dashboard,
                      color: Colors.white,
                    ),
                    isOpen: isOpen,
                    title: 'Dashboard',
                    isSelected: widget.menuViewModel.menuState.value.menuEnum ==
                        MenuEnum.Dashboard,
                    onTap: () {
                      widget.menuViewModel.changeMenu(MenuEnum.Dashboard);
                    },
                  ),
                  SizedBox(height: AppSize.padding),
                  MenuItem(
                    icon: Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    isOpen: isOpen,
                    title: 'Operações',
                    isSelected: widget.menuViewModel.menuState.value.menuEnum ==
                        MenuEnum.Operations,
                    onTap: () {
                      widget.menuViewModel.changeMenu(MenuEnum.Operations);
                    },
                  ),
                  SizedBox(height: AppSize.padding),
                  MenuItem(
                    icon: Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    isOpen: isOpen,
                    title: 'Docas',
                    isSelected: widget.menuViewModel.menuState.value.menuEnum ==
                        MenuEnum.Dock,
                    onTap: () {
                      widget.menuViewModel.changeMenu(MenuEnum.Dock);
                    },
                  ),
                  SizedBox(
                    height: AppSize.padding,
                  ),
                  MenuItem(
                    icon: Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    isOpen: isOpen,
                    isSelected: widget.menuViewModel.menuState.value.menuEnum ==
                        MenuEnum.Company,
                    title: 'Transportadoras',
                    onTap: () {
                      widget.menuViewModel.changeMenu(MenuEnum.Company);
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
  final isSelected;
  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isOpen = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
                            style: AppTextStyle.displayMedium(context).copyWith(
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
    );
  }
}
