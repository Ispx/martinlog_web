import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/dock_type_enum.dart';
import 'package:martinlog_web/enums/operation_status_enum.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/dock_type_extension.dart';
import 'package:martinlog_web/extensions/operation_status_extension.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/state/menu_state.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/utils/utils.dart';
import 'package:martinlog_web/view_models/dashboard_view_model.dart';
import 'package:martinlog_web/view_models/menu_view_model.dart';
import 'package:martinlog_web/views/web/operation_view.dart';
import 'package:martinlog_web/widgets/icon_buttom_widget.dart';
import 'package:martinlog_web/widgets/page_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final DashboardViewModel controller = simple.get<DashboardViewModel>();
  late Worker worker;
  @override
  void initState() {
    worker = ever(controller.operations, (callback) {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (controller.operations.isEmpty) {
        await controller.getAllOperations();
      }
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
      body: LayoutBuilder(builder: (context, snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.padding * 2,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 2.w,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    width: 15.w,
                    child: IconButtonWidget(
                      title: 'Nova operação',
                      onTap: () => simple
                          .get<MenuViewModel>()
                          .changeMenu(MenuEnum.Operations),
                      icon: const Icon(
                        LineIcons.dolly,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 2.w,
                ),
                SizedBox(
                  width: snapshot.maxWidth,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: LayoutBuilder(builder: (context, constraint) {
                      final width = constraint.maxWidth / 4.5;
                      return Column(
                        children: [
                          Wrap(
                            spacing: AppSize.padding * 2,
                            runSpacing: AppSize.padding * 2,
                            alignment: WrapAlignment.center,
                            children: [
                              CardSummaryOperationWidget(
                                width: width,
                                controller: controller,
                                dockType: DockType.RECEIPT,
                              ),
                              CardSummaryOperationWidget(
                                width: width,
                                controller: controller,
                                dockType: DockType.EXPEDITION,
                              ),
                              CardSummaryOperationWidget(
                                width: width,
                                controller: controller,
                                dockType: DockType.TRANSFER,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: AppSize.padding * 2,
                          ),
                          Wrap(
                            spacing: AppSize.padding * 2,
                            runSpacing: AppSize.padding * 2,
                            alignment: WrapAlignment.center,
                            children: [
                              CardSummaryOperationWidget(
                                width: width,
                                controller: controller,
                                dockType: DockType.KAMIKAZE,
                              ),
                              CardSummaryOperationWidget(
                                width: width,
                                controller: controller,
                                dockType: DockType.REVERSE,
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                SizedBox(
                  height: 3.w,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 1.w),
                    child: Text(
                      'Operações Recentes',
                      style: AppTextStyle.displayLarge(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Obx(() {
                  return PageWidget(
                    key: ValueKey(DateTime.now()),
                    totalByPage: 5,
                    isLoadingItens:
                        controller.appState.value is AppStateLoading,
                    itens: controller
                        .getLastsOperations(5)
                        .map(
                          (operationModel) => Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSize.padding / 2,
                            ),
                            child: OperationWidget(
                              key: ObjectKey(operationModel),
                              operationModel: operationModel,
                              onAction: () => controller.getAllOperations(),
                            ),
                          ),
                        )
                        .toList(),
                    onRefresh: () => controller.getAllOperations(),
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
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
                    width: 3.w,
                    height: 3.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Utils.getColorIconDockType(dockType),
                    ),
                    alignment: Alignment.center,
                    child: Center(
                      child: Icon(
                        Utils.getIconDataByDockType(dockType),
                        color: Colors.white,
                        size: 2.w,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 0.5.w,
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
              Obx(() {
                return SizedBox(
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
    return LayoutBuilder(builder: (context, constraint) {
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
          padding: EdgeInsets.only(
            top: 0.5.w,
            bottom: 0.5.w,
            left: 0.5.w,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyle.displaySmall(context).copyWith(
                  overflow: TextOverflow.ellipsis,
                  color: Colors.white,
                ),
              ),
              isLoading == true
                  ? Center(
                      child: Text(
                        'Carregando...',
                        style: AppTextStyle.displaySmall(context).copyWith(
                          overflow: TextOverflow.ellipsis,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      value.toString(),
                      style: AppTextStyle.displayLarge(context).copyWith(
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.white,
                      ),
                    )
            ],
          ),
        ),
      );
    });
  }
}
