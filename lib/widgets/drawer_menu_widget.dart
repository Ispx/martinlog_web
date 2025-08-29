import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/images/app_images.dart';
import 'package:martinlog_web/state/menu_state.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/menu_view_model.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DrawerMenuWidget extends StatefulWidget {
  final MenuViewModel menuViewModel;
  const DrawerMenuWidget({super.key, required this.menuViewModel});

  @override
  State<DrawerMenuWidget> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenuWidget> {
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
                      widget.menuViewModel.changeMenu(MenuEnum.Dashboard);
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
                      widget.menuViewModel.changeMenu(MenuEnum.Operations);
                    },
                  ),
                  SizedBox(height: AppSize.padding),
                  MenuItem(
                    icon: const Icon(
                      LineIcons.warehouse,
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
                    icon: const Icon(
                      Icons.business,
                      color: Colors.white,
                    ),
                    isOpen: isOpen,
                    isSelected: widget.menuViewModel.menuState.value.menuEnum ==
                        MenuEnum.BranchOffice,
                    title: 'Filial',
                    onTap: () {
                      widget.menuViewModel.changeMenu(MenuEnum.BranchOffice);
                    },
                  ),
                  SizedBox(
                    height: AppSize.padding,
                  ),
                  MenuItem(
                    icon: const Icon(
                      LineIcons.truck,
                      color: Colors.white,
                    ),
                    isOpen: isOpen,
                    isSelected: widget.menuViewModel.menuState.value.menuEnum ==
                            MenuEnum.Company ||
                        widget.menuViewModel.menuState.value.menuEnum ==
                            MenuEnum.BindBranchOffice,
                    title: 'Transportadoras',
                    onTap: () {
                      widget.menuViewModel.changeMenu(MenuEnum.Company);
                    },
                    profiles: const [ProfileTypeEnum.MASTER],
                  ),
                  SizedBox(
                    height: AppSize.padding,
                  ),
                  MenuItem(
                    icon: const Icon(
                      LineIcons.users,
                      color: Colors.white,
                    ),
                    isOpen: isOpen,
                    isSelected: widget.menuViewModel.menuState.value.menuEnum ==
                        MenuEnum.Users,
                    title: 'Usuários',
                    onTap: () {
                      widget.menuViewModel.changeMenu(MenuEnum.Users);
                    },
                    profiles: const [ProfileTypeEnum.MASTER],
                  ),
                  SizedBox(
                    height: AppSize.padding,
                  ),
                  MenuItem(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                    isOpen: isOpen,
                    isSelected: widget.menuViewModel.menuState.value.menuEnum ==
                        MenuEnum.Settings,
                    title: 'Configurações',
                    onTap: () {
                      widget.menuViewModel.changeMenu(MenuEnum.Settings);
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
                                  style: AppTextStyle.displayMedium(context)
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
