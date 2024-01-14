import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:martinlog_web/view_models/dashboard_view_model.dart';
import 'package:martinlog_web/view_models/menu_view_model.dart';
import 'package:martinlog_web/views/operation_view.dart';
import 'package:martinlog_web/widgets/circular_progress_indicator_widget.dart';
import 'package:martinlog_web/widgets/icon_buttom_widget.dart';
import 'package:martinlog_web/widgets/page_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with KeepAliveParentDataMixin {
  final DashboardViewModel controller = simple.get<DashboardViewModel>();

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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CardSummaryOperationWidget(
                        dockType: DockType.RECEIPT,
                      ),
                      CardSummaryOperationWidget(
                        dockType: DockType.EXPEDITION,
                      ),
                      CardSummaryOperationWidget(
                        dockType: DockType.KAMIKAZE,
                      ),
                    ],
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
                PageWidget(
                  totalByPage: 5,
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
                          ),
                        ),
                      )
                      .toList(),
                  onRefresh: () async {
                    await controller.getAllOperations();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  void detach() {}

  @override
  bool get keptAlive => true;
}

class CardSummaryOperationWidget extends StatelessWidget {
  final DockType dockType;
  const CardSummaryOperationWidget({
    super.key,
    required this.dockType,
  });

  Color getColorIconDockType(DockType dockType) {
    return switch (dockType) {
      DockType.EXPEDITION => Colors.blue,
      DockType.RECEIPT => Colors.green,
      DockType.KAMIKAZE => Colors.red,
      _ => throw "Invalid icondata to dockType"
    };
  }

  IconData getIconDataByDockType(DockType dockType) {
    return switch (dockType) {
      DockType.EXPEDITION => LineIcons.arrowUp,
      DockType.RECEIPT => LineIcons.arrowDown,
      DockType.KAMIKAZE => LineIcons.alternateArrows,
      _ => throw "Invalid icondata to dockType"
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 27.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      padding: EdgeInsets.only(left: 1.w, right: 1.w),
      child: LayoutBuilder(builder: (context, snapshot) {
        final width = snapshot.maxWidth / 5;

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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: getColorIconDockType(dockType),
                  ),
                  alignment: Alignment.center,
                  child: Center(
                    child: Icon(
                      getIconDataByDockType(dockType),
                      color: Colors.white,
                      size: 30,
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
            SizedBox(
              width: snapshot.maxWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CardIndicatorWidget(
                    width: width,
                    value: simple
                        .get<DashboardViewModel>()
                        .filterOperations(
                          idDockType: dockType.idDockType,
                        )
                        .length,
                    isLoading: simple.get<DashboardViewModel>().appState.value
                        is AppStateLoading,
                    title: "Total Geral",
                    backgroundColor: Colors.yellow,
                  ),
                  CardIndicatorWidget(
                    width: width,
                    value: simple
                        .get<DashboardViewModel>()
                        .filterOperations(
                          idDockType: dockType.idDockType,
                          dateFrom: DateTime(
                              DateTime.now().year, DateTime.now().month, 1),
                          dateUntil: DateTime(DateTime.now().year,
                                  DateTime.now().month + 1, 1)
                              .subtract(1.seconds),
                        )
                        .length,
                    isLoading: simple.get<DashboardViewModel>().appState.value
                        is AppStateLoading,
                    title: "Mês",
                    backgroundColor: Colors.yellow,
                  ),
                  CardIndicatorWidget(
                    width: width,
                    value: simple
                        .get<DashboardViewModel>()
                        .filterOperations(
                          idDockType: dockType.idDockType,
                          dateFrom: DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day),
                          dateUntil: DateTime.now().add(1.days),
                        )
                        .length,
                    isLoading: simple.get<DashboardViewModel>().appState.value
                        is AppStateLoading,
                    title: "Hoje",
                    backgroundColor: Colors.green,
                  ),
                  CardIndicatorWidget(
                    width: width,
                    value: simple.get<DashboardViewModel>().filterOperations(
                      idDockType: dockType.idDockType,
                      status: [
                        OperationStatusEnum.IN_PROGRESS.idOperationStatus,
                      ],
                    ).length,
                    isLoading: simple.get<DashboardViewModel>().appState.value
                        is AppStateLoading,
                    title: "Em execução",
                    backgroundColor: Colors.green,
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
    return Container(
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
            ),
          ),
          isLoading == true
              ? const CircularProgressIndicatorWidget()
              : Text(
                  value.toString(),
                  style: AppTextStyle.displayLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                )
        ],
      ),
    );
  }
}
