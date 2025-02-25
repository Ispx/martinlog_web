import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/event_type_enum.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/event_type_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/extensions/menu_extention.dart';
import 'package:martinlog_web/extensions/profile_type_extension.dart';
import 'package:martinlog_web/functions/futures.dart';
import 'package:martinlog_web/images/app_images.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/state/menu_state.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/company_view_model.dart';
import 'package:martinlog_web/view_models/dashboard_view_model.dart';
import 'package:martinlog_web/view_models/dock_view_model.dart';
import 'package:martinlog_web/view_models/menu_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';
import 'package:martinlog_web/view_models/user_view_model.dart';
import 'package:martinlog_web/views/web/company_view.dart';
import 'package:martinlog_web/views/web/dashboard_view.dart';
import 'package:martinlog_web/views/web/dock_view.dart';
import 'package:martinlog_web/views/web/operation_view.dart';
import 'package:martinlog_web/views/web/users_view.dart';
import 'package:martinlog_web/widgets/app_bar_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('operation_events');
  late final MenuViewModel menuViewModel;
  late final Worker worker;

  Widget getViewByMenu(MenuEnum menuEnum) => switch (menuEnum) {
        MenuEnum.Operations =>
          const OperationView(key: ObjectKey(MenuEnum.Operations)),
        MenuEnum.Dock => const DockView(key: ObjectKey(MenuEnum.Dock)),
        MenuEnum.Company => const CompanyView(key: ObjectKey(MenuEnum.Company)),
        MenuEnum.Users => const UserView(key: ObjectKey(MenuEnum.Users)),
        MenuEnum.Dashboard =>
          const DashboardView(key: ObjectKey(MenuEnum.Dashboard))
      };
  @override
  void initState() {
    _collection.snapshots().where((event) {
      for (var doc in event.docChanges) {
        final data = doc.doc.data() as Map;
        if (data['idUser'] == simple.get<AuthViewModel>().authModel?.idUser) {
          return false;
        }
        if (data['data']['company']['cnpj'] !=
                simple.get<CompanyViewModel>().companyModel?.cnpj &&
            simple.get<AuthViewModel>().authModel?.idProfile !=
                ProfileTypeEnum.MASTER.idProfileType) {
          return false;
        }
      }
      return true;
    }).listen((event) async {
      if (event.docChanges.length == 1) {
        for (var doc in event.docChanges) {
          final data = doc.doc.data() as Map;
          final eventType = data['event_type'];
          final operationKey = data['data']['operationKey'];
          final fantasyName =
              data['data']['company']['fantasyName'].toString().toUpperCase();

          final message =
              "$fantasyName: Operação ${operationKey.substring(0, 8)} foi ${eventType == EventTypeEnum.OPERATION_UPDATED.description ? 'atualizada' : eventType == EventTypeEnum.OPERATION_FINISHED.description ? 'finalizada' : eventType == EventTypeEnum.OPERATION_CREATED.description ? 'criada' : 'cancelada'}.";

          BannerComponent(
            duration: 5.seconds,
            message: message,
            // ignore: use_build_context_synchronously
            backgroundColor: context.appTheme.primaryColor,
            actions: [
              TextActionButtom(
                title: 'Ver detalhes',
                onAction: () async {
                  final operationViewModel = simple.get<OperationViewModel>();
                  await operationViewModel.getOperation(
                      operationKey: operationKey);
                  final operationModel = operationViewModel.operationModel!;
                  // ignore: use_build_context_synchronously
                  showDialogDetailsOperation(
                    context,
                    operationModel,
                  );
                },
              ),
            ],
          );
        }
      }
    });

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      funcGetAccountInfo();
    });
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
      body: Obx(
        () {
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
                    profiles: const [ProfileTypeEnum.MASTER],
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
                        MenuEnum.Company,
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
