import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/models/dashboard_model.dart';
import 'package:martinlog_web/widgets/page_widget_mobile.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../core/dependencie_injection_manager/simple.dart';
import '../../state/app_state.dart';
import '../../state/menu_state.dart';
import '../../style/size/app_size.dart';
import '../../style/text/app_text_style.dart';
import '../../view_models/dashboard_view_model.dart';
import '../../view_models/menu_view_model.dart';
import '../../widgets/icon_buttom_widget.dart';
import 'operation/views/operation_view_mobile.dart';

class DashboardViewMobile extends StatefulWidget {
  const DashboardViewMobile({super.key});

  @override
  State<DashboardViewMobile> createState() => _DashboardViewMobileState();
}

class _DashboardViewMobileState extends State<DashboardViewMobile> {
  final DashboardViewModel controller = simple.get<DashboardViewModel>();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onRefresh();
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onRefresh() {
    simple.get<DashboardViewModel>().fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: context.appTheme.backgroundColor,
        body: LayoutBuilder(builder: (context, snapshot) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Gap(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButtonWidget(
                        title: 'Nova operação',
                        onTap: () => simple
                            .get<MenuViewModel>()
                            .changeMenu(MenuEnum.Operations),
                        icon: const Icon(
                          LineIcons.dolly,
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  SizedBox(
                    width: snapshot.maxWidth,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: LayoutBuilder(builder: (context, constraint) {
                        final width = constraint.maxWidth;
                        return Obx(() {
                          final state = controller.appState.value;

                          return controller.dashboardResults.value.isEmpty &&
                                  (state is AppStateDone ||
                                      state is AppStateLoading)
                              ? SizedBox(
                                  height: 30.h,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          LineIcons.dolly,
                                          color: Colors.grey,
                                          size: 10.h,
                                        ),
                                        SizedBox(
                                          height: AppSize.padding * 2,
                                        ),
                                        Text(
                                          state is AppStateDone
                                              ? 'Nenhuma operação registrada até o momento.'
                                              : "Carregando dados, por favor aguarde...",
                                          style:
                                              AppTextStyle.displayLarge(context)
                                                  .copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ...controller.dashboardResults.value
                                        .map((dashboardModel) {
                                      return Column(
                                        children: [
                                          const Gap(16),
                                          CardSummaryOperationWidget(
                                            width: width,
                                            controller: controller,
                                            dashboardModel: dashboardModel,
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ],
                                );
                        });
                      }),
                    ),
                  ),
                  const Gap(40),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Operações Recentes',
                      style: AppTextStyle.mobileDisplayLarge(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Obx(() {
                    return PageWidgetMobile(
                        totalByPage: 20,
                        isLoadingItens:
                            controller.appState.value is AppStateLoading,
                        itens: controller.operations.map((operationModel) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSize.padding / 2,
                            ),
                            child: OperationWidgetMobile(
                              key: ObjectKey(operationModel),
                              operationModel: operationModel,
                              onAction: () async {},
                            ),
                          );
                        }).toList(),
                        onRefresh: () async => onRefresh());
                  })
                ],
              ),
            ),
          );
        }));
  }
}

class CardSummaryOperationWidget extends StatelessWidget {
  final DashboardModel dashboardModel;
  final DashboardViewModel controller;
  final double width;
  const CardSummaryOperationWidget({
    super.key,
    required this.width,
    required this.dashboardModel,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 6.0,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(2.w),
        child: LayoutBuilder(builder: (context, snapshot) {
          final widthIndicator = snapshot.maxWidth / 3.5;
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 2.w,
              ),
              Row(
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: context.appTheme.secondColor,
                    ),
                    alignment: Alignment.center,
                    child: Center(
                      child: Icon(
                        LineIcons.dolly,
                        color: Colors.white,
                        size: 4.w,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 1.w,
                  ),
                  Text(
                    dashboardModel.name,
                    style: AppTextStyle.displayLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 3.w,
              ),
              Obx(() {
                return SizedBox(
                  width: width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CardIndicatorWidget(
                        isLoading: controller.appState.value is AppStateLoading,
                        width: widthIndicator,
                        value: dashboardModel.total,
                        title: "15º atual",
                        backgroundColor: Colors.blue,
                      ),
                      SizedBox(width: width * .05),
                      CardIndicatorWidget(
                        isLoading: controller.appState.value is AppStateLoading,
                        width: widthIndicator,
                        value: dashboardModel.today,
                        title: "Hoje",
                        backgroundColor: context.appTheme.primaryColor,
                      ),
                      SizedBox(width: width * .05),
                      CardIndicatorWidget(
                        isLoading: controller.appState.value is AppStateLoading,
                        width: widthIndicator,
                        value: dashboardModel.inProgress,
                        title: "Em execução",
                        backgroundColor: context.appTheme.primaryVariant,
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(
                height: 2.w,
              ),
            ],
          );
        }),
      ),
    );
  }
}

class CardIndicatorWidget extends StatelessWidget {
  final String title;
  final int value;
  final bool isLoading;
  final double? width;
  final Color backgroundColor;
  const CardIndicatorWidget({
    super.key,
    this.width,
    required this.title,
    required this.value,
    required this.backgroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 4.0,
      child: Container(
        width: width,
        height: width != null ? width! * .80 : null,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: kIsWeb
            ? EdgeInsets.only(
                top: 0.5.w,
                bottom: 0.5.w,
                left: 0.5.w,
              )
            : const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyle.mobileDisplaySmall(context).copyWith(
                overflow: TextOverflow.ellipsis,
                color: Colors.white,
              ),
            ),
            isLoading
                ? Text(
                    'Carregando...',
                    style: AppTextStyle.mobileDisplaySmall(context).copyWith(
                      overflow: TextOverflow.ellipsis,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    value.toString(),
                    style: AppTextStyle.mobileDisplayLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                      color: Colors.white,
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
