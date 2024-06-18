import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/dock_type_extension.dart';
import 'package:martinlog_web/extensions/operation_status_extension.dart';
import 'package:martinlog_web/widgets/page_widget_mobile.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../core/dependencie_injection_manager/simple.dart';
import '../../enums/dock_type_enum.dart';
import '../../enums/operation_status_enum.dart';
import '../../state/app_state.dart';
import '../../state/menu_state.dart';
import '../../style/size/app_size.dart';
import '../../style/text/app_text_style.dart';
import '../../view_models/dashboard_view_model.dart';
import '../../view_models/menu_view_model.dart';
import '../../widgets/circular_progress_indicator_widget.dart';
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
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CardSummaryOperationWidget(
                              width: width,
                              controller: controller,
                              dockType: DockType.RECEIPT,
                            ),
                            const Gap(16),
                            CardSummaryOperationWidget(
                              width: width,
                              controller: controller,
                              dockType: DockType.EXPEDITION,
                            ),
                            const Gap(16),
                            CardSummaryOperationWidget(
                              width: width,
                              controller: controller,
                              dockType: DockType.TRANSFER,
                            ),
                            const Gap(16),
                            CardSummaryOperationWidget(
                              width: width,
                              controller: controller,
                              dockType: DockType.KAMIKAZE,
                            ),
                          ],
                        );
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
                  PageWidgetMobile(
                    totalByPage: 5,
                    itens:
                        controller.getLastsOperations(6).map((operationModel) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSize.padding / 2,
                        ),
                        child: OperationWidgetMobile(
                          key: ObjectKey(operationModel),
                          operationModel: operationModel,
                          onAction: () async =>
                              await controller.getAllOperations(),
                        ),
                      );
                    }).toList(),
                    onRefresh: () async => await controller.getAllOperations(),
                  )
                ],
              ),
            ),
          );
        }));
  }
}

class CardSummaryOperationWidget extends StatelessWidget {
  final DockType dockType;
  final DashboardViewModel controller;
  final double width;
  const CardSummaryOperationWidget({
    super.key,
    required this.width,
    required this.dockType,
    required this.controller,
  });
  Color getColorIconDockType(DockType dockType) {
    return switch (dockType) {
      DockType.EXPEDITION => Colors.blue,
      DockType.RECEIPT => Colors.green,
      DockType.TRANSFER => Colors.orange,
      DockType.KAMIKAZE => Colors.red,
      _ => throw "Invalid icondata to dockType"
    };
  }

  IconData getIconDataByDockType(DockType dockType) {
    return switch (dockType) {
      DockType.EXPEDITION => LineIcons.arrowUp,
      DockType.RECEIPT => LineIcons.arrowDown,
      DockType.TRANSFER => LineIcons.alternateExchange,
      DockType.KAMIKAZE => LineIcons.alternateArrows,
      _ => throw "Invalid icondata to dockType"
    };
  }

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
        padding: EdgeInsets.only(left: 1.w, right: 1.w),
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
                      color: getColorIconDockType(dockType),
                    ),
                    alignment: Alignment.center,
                    child: Center(
                      child: Icon(
                        getIconDataByDockType(dockType),
                        color: Colors.white,
                        size: 4.w,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 1.w,
                  ),
                  Text(
                    dockType.description,
                    style: AppTextStyle.displayLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 3.w,
              ),
              SizedBox(
                width: width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CardIndicatorWidget(
                      width: widthIndicator,
                      value: controller.filterOperations(
                          idDockType: dockType.idDockType,
                          dateFrom: DateTime.now().day <= 15
                              ? DateTime(DateTime.now().year,
                                      DateTime.now().month, 1)
                                  .toUtc()
                              : DateTime(DateTime.now().year,
                                      DateTime.now().month, 16)
                                  .toUtc(),
                          dateUntil: DateTime.now().day <= 15
                              ? DateTime(DateTime.now().year,
                                      DateTime.now().month, 15, 23, 59, 59)
                                  .toUtc()
                              : DateTime(DateTime.now().year,
                                      DateTime.now().month + 1, 1)
                                  .toUtc()
                                  .subtract(1.seconds),
                          status: [
                            OperationStatusEnum.CREATED.idOperationStatus,
                            OperationStatusEnum.IN_PROGRESS.idOperationStatus,
                            OperationStatusEnum.FINISHED.idOperationStatus,
                          ]).length,
                      isLoading: controller.appState.value is AppStateLoading,
                      title: "15º atual",
                      backgroundColor: Colors.blue,
                    ),
                    SizedBox(width: width * .05),
                    CardIndicatorWidget(
                      width: widthIndicator,
                      value: controller.filterOperations(
                          idDockType: dockType.idDockType,
                          dateFrom: DateTime(DateTime.now().year,
                                  DateTime.now().month, DateTime.now().day)
                              .toUtc(),
                          dateUntil: DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  23,
                                  59,
                                  59)
                              .toUtc(),
                          status: [
                            OperationStatusEnum.CREATED.idOperationStatus,
                            OperationStatusEnum.IN_PROGRESS.idOperationStatus,
                            OperationStatusEnum.FINISHED.idOperationStatus,
                          ]).length,
                      isLoading: controller.appState.value is AppStateLoading,
                      title: "Hoje",
                      backgroundColor: context.appTheme.primaryColor,
                    ),
                    SizedBox(width: width * .05),
                    CardIndicatorWidget(
                      width: widthIndicator,
                      value: controller.filterOperations(
                          idDockType: dockType.idDockType,
                          status: [
                            OperationStatusEnum.CREATED.idOperationStatus,
                            OperationStatusEnum.IN_PROGRESS.idOperationStatus,
                          ]).length,
                      isLoading: controller.appState.value is AppStateLoading,
                      title: "Em execução",
                      backgroundColor: context.appTheme.primaryVariant,
                    ),
                  ],
                ),
              ),
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
  final bool? isLoading;
  final double? width;
  final Color backgroundColor;
  const CardIndicatorWidget({
    super.key,
    this.width,
    required this.title,
    required this.value,
    required this.backgroundColor,
    this.isLoading,
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
            isLoading == true
                ? const CircularProgressIndicatorWidget()
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
