import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/consts/routes.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/dock_type_enum.dart';
import 'package:martinlog_web/enums/operation_status_enum.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
import 'package:martinlog_web/extensions/dock_type_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/extensions/operation_status_extension.dart';
import 'package:martinlog_web/input_formaters/percentage_input_formatter.dart';
import 'package:martinlog_web/models/operation_model.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';
import 'package:martinlog_web/views/mobile/operation/widgets/new_operation_widget.dart';
import 'package:martinlog_web/widgets/dropbox_widget.dart';
import 'package:martinlog_web/widgets/page_widget_mobile.dart';
import 'package:martinlog_web/widgets/text_form_field_widget.dart';

import '../../../../navigator/go_to.dart';

class OperationViewMobile extends StatefulWidget {
  const OperationViewMobile({super.key});

  @override
  State<OperationViewMobile> createState() => _OperationViewMobileState();
}

class _OperationViewMobileState extends State<OperationViewMobile> {
  late final Worker worker;
  late final Worker workerSearch;

  final controller = simple.get<OperationViewModel>();
  late final TextEditingController operationStatusEditingController;
  OperationStatusEnum? operationStatusEnumSelected;
  late final TextEditingController dockTypeEditingController;
  var textSearched = ''.obs;
  var textDateRangeSelected = ''.obs;
  DockType? dockTypeSelected;
  DateRange? dateRangeSelected;
  var operationsFilted = <OperationModel>[].obs;
  void clearFieldsFilters() {
    operationStatusEditingController.clear();
    dockTypeEditingController.clear();
    operationStatusEnumSelected = null;
    dockTypeSelected = null;
    dateRangeSelected = null;
    textSearched.value = '';
    textDateRangeSelected.value = '';
    controller.resetFilter();
    setState(() {});
  }

  @override
  void initState() {
    operationStatusEditingController = TextEditingController();
    dockTypeEditingController = TextEditingController();
    workerSearch = debounce(textSearched, controller.search);
    worker = ever(controller.appState, (appState) {
      if (appState is AppStateError) {
        BannerComponent(
          message: appState.msg ?? "Ocorreu um erro",
          backgroundColor: Colors.red,
        );
        return;
      }
      if (appState is AppStateDone && appState.result is String) {
        BannerComponent(
          message: appState.result,
          backgroundColor: Colors.green,
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    workerSearch.dispose();
    worker.dispose();
    super.dispose();
  }

  int selected = 0;
  Future<void> _setDateRangeText() async {
    if (dateRangeSelected == null) {
      controller.resetFilter();
      textDateRangeSelected.value = '';
    }
    if (dateRangeSelected != null) {
      await controller.filterByDate(
        dateRangeSelected!.start,
        dateRangeSelected!.end,
      );
      textDateRangeSelected.value = "${dateRangeSelected!.start.ddMMyyyy} - ${dateRangeSelected!.end.ddMMyyyy}";
    }
  }

  Future<void> _selectDate(int days, int buttonNumber) async {
    if (selected == buttonNumber) {
      setState(() {
        selected = 0;
        dateRangeSelected = null;
      });
    } else {
      setState(() {
        selected = buttonNumber;
        dateRangeSelected = DateRange(
          DateTime.now().subtract(const Duration(days: 7)),
          DateTime.now(),
        );
      });
    }
    await _setDateRangeText();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(
        vertical: AppSize.padding,
        horizontal: AppSize.padding * 2,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Gap(8),
            const CreateOperationWidget(),
            const Gap(8),
            const Divider(),
            const Gap(8),
            SizedBox(
              height: 249,
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: AppSize.padding,
                      ),
                      Obx(() {
                        return Text(
                          textDateRangeSelected.value,
                          style: AppTextStyle.mobileDisplayMedium(context),
                        );
                      }),
                      SizedBox(
                        width: AppSize.padding,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DropBoxWidget<OperationStatusEnum>(
                        width: MediaQuery.of(context).size.width - 32,
                        controller: operationStatusEditingController,
                        label: 'Status',
                        dropdownMenuEntries: [
                          ...OperationStatusEnum.values
                              .map(
                                (e) => DropdownMenuEntry(value: e, label: e.description),
                              )
                              .toList()
                        ],
                        onSelected: (e) {
                          if (e == null) return;
                          simple.get<OperationViewModel>().filterByStatus(e);
                        },
                      ),
                      const SizedBox(height: 8),
                      DropBoxWidget<DockType>(
                        width: MediaQuery.of(context).size.width - 32,
                        controller: dockTypeEditingController,
                        label: 'Tipo',
                        dropdownMenuEntries: [
                          ...DockType.values
                              .map(
                                (e) => DropdownMenuEntry(value: e, label: e.description),
                              )
                              .toList()
                        ],
                        onSelected: (e) {
                          if (e == null) return;
                          simple.get<OperationViewModel>().filterByDock(e);
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormFieldWidget<OutlineInputBorder>(
                      label: 'Pesquisar',
                      hint: 'Pesquise por transportadora ou doca',
                      onChange: (e) => textSearched.value = e,
                    ),
                  ),
                  SizedBox(
                    width: AppSize.padding,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    TextActionButtom(
                      title: 'Últimos 7 dias',
                      selected: selected == 1,
                      onAction: () async => await _selectDate(7, 1),
                      selectedColor: appTheme.primaryColor,
                      backgroundColor: selected == 1 ? Colors.white : appTheme.primaryColor,
                      titleColor: appTheme.titleColor,
                    ),
                    const Gap(8),
                    TextActionButtom(
                      title: 'Últimos 30 dias',
                      selected: selected == 2,
                      onAction: () async => await _selectDate(30, 2),
                      selectedColor: appTheme.primaryColor,
                      backgroundColor: selected == 2 ? Colors.white : appTheme.primaryColor,
                      titleColor: appTheme.titleColor,
                    ),
                    const Gap(8),
                    TextActionButtom(
                      title: 'Últimos 60 dias',
                      selected: selected == 3,
                      onAction: () async => await _selectDate(60, 3),
                      selectedColor: appTheme.primaryColor,
                      backgroundColor: selected == 3 ? Colors.white : appTheme.primaryColor,
                      titleColor: appTheme.titleColor,
                    ),
                    const Gap(8),
                    TextActionButtom(
                      title: 'Últimos 90 dias',
                      selected: selected == 4,
                      onAction: () async => await _selectDate(90, 4),
                      selectedColor: appTheme.primaryColor,
                      backgroundColor: selected == 4 ? Colors.white : appTheme.primaryColor,
                      titleColor: appTheme.titleColor,
                    ),
                    const Gap(8),
                    TextActionButtom(
                      title: 'Personalizado ${textDateRangeSelected.value}',
                      selected: selected == 5,
                      onAction: () async {
                        final appTheme = context.appTheme;
                        final date = await showDateRangePicker(
                          barrierColor: appTheme.primaryColor,
                          context: context,
                          firstDate: DateTime(1990, 01, 01),
                          lastDate: DateTime.now(),
                        );
                        setState(() {
                          selected = 5;
                          dateRangeSelected = date != null ? DateRange(date.start, date.end) : null;
                          if (date == null) selected = 0;
                        });

                        await _setDateRangeText();
                      },
                      selectedColor: appTheme.primaryColor,
                      backgroundColor: selected == 5 ? Colors.white : appTheme.primaryColor,
                      titleColor: appTheme.titleColor,
                    ),
                    const Gap(8),
                  ],
                ),
              ),
            ),
            const Gap(10),
            Obx(() {
              final itens = controller.operationsFilted
                  .map(
                    (operationModel) => Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppSize.padding / 2,
                      ),
                      child: OperationWidgetMobile(
                        key: ObjectKey(operationModel),
                        operationModel: operationModel,
                      ),
                    ),
                  )
                  .toList();
              return PageWidgetMobile(
                key: ObjectKey(itens),
                itens: itens,
                onRefresh: () async => await controller.getAll(),
                onDownload: () async => await controller.downloadFile(controller.operationsFilted),
                totalByPage: 10,
              );
            }),
          ],
        ),
      ),
    );
  }
}


class OperationWidgetMobile extends StatefulWidget {
  final OperationModel operationModel;
  final Future<void> Function()? onAction;
  const OperationWidgetMobile({
    super.key,
    required this.operationModel,
    this.onAction,
  });

  @override
  State<OperationWidgetMobile> createState() => _OperationWidgetMobileState();
}

class _OperationWidgetMobileState extends State<OperationWidgetMobile> with SingleTickerProviderStateMixin {
  var progressObs = 0.obs;
  late final TextEditingController percentageEdittinController;

  final controller = simple.get<OperationViewModel>();
  late final Worker workerAppState;
  late final Worker workerProgress;
  late final AnimationController animationController;
  late Animation<double> progressAnimation;
  late final Animation<int> textAnimation;

  late OperationModel operation;

  @override
  void initState() {
    operation = widget.operationModel;

    animationController = AnimationController(vsync: this, duration: 1.seconds)
      ..addListener(() {
        progressObs.value = textAnimation.value;
        percentageEdittinController.text = "${progressObs.value}%";
        setState(() {});
      });
    progressAnimation = Tween<double>(begin: 0.0, end: widget.operationModel.progress / 100).animate(
      CurvedAnimation(parent: animationController, curve: Curves.decelerate),
    );

    textAnimation = IntTween(begin: 0, end: widget.operationModel.progress).animate(
      CurvedAnimation(parent: animationController, curve: Curves.decelerate),
    );
    percentageEdittinController = TextEditingController();

    workerAppState = ever(controller.appState, (appState) {
      if (appState is AppStateError) {
        progressObs.update((val) {
          progressObs.value = widget.operationModel.progress;
        });
        setState(() {});
      }
    });
    workerProgress = ever(progressObs, (newProgress) {
      progressAnimation = Tween<double>(begin: 0.0, end: newProgress / 100).animate(
        CurvedAnimation(parent: animationController, curve: Curves.decelerate),
      );
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(100.milliseconds).then(
        (value) => animationController.forward(),
      );
    });

    super.initState();
  }

  Future<void> downloadFile() async {
    controller.downloadFile([operation]);
  }

  Future<void> update() async {
    await controller.updateOperation(
      operationModel: operation,
      progress: progressObs.value,
      additionalData: null,
    );
    if (widget.onAction != null) await widget.onAction!();
    getUpdatedOperation();
  }

  Future<void> getUpdatedOperation() async {
    await controller.getAll();
    operation = controller.operations.firstWhere((element) => element.liscensePlate == operation.liscensePlate);
  }

  @override
  void dispose() {
    workerAppState.dispose();
    workerProgress.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Obx(() {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: 360,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextActionButtom(
                  title: operation.operationKey.substring(0, 8),
                  backgroundColor: appTheme.primaryColor,
                  titleColor: appTheme.titleColor,
                  onAction: () {},
                ),
                OperationSubtitleTextWidget(
                  text: operation.createdAt.toBrazillianHour.ddMMyyyyHHmmss,
                  textAlign: null,
                  width: null,
                ),
              ],
            ),
            const Gap(32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (simple.get<AuthViewModel>().authModel!.idProfile.getProfile() == ProfileTypeEnum.MASTER)
                  OperationSubtitleTextWidget(
                    text: operation.companyModel.fantasyName,
                    textAlign: null,
                    width: null,
                  ),
                OperationSubtitleTextWidget(
                  text: operation.dockModel!.idDockType.getDockType().description,
                  width: null,
                ),
                OperationSubtitleTextWidget(
                  text: operation.dockModel?.code ?? '',
                ),
                OperationSubtitleTextWidget(
                  text: operation.liscensePlate,
                  width: null,
                ),
              ],
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: Text(
                    operation.idOperationStatus.getOperationStatus().description,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.mobileDisplayMedium(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: appTheme.titleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Flexible(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        "${progressObs.value}%",
                        style: AppTextStyle.mobileDisplaySmall(context).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      CircularProgressIndicator(
                        value: progressAnimation.value,
                        color:
                            operation.idOperationStatus == OperationStatusEnum.CANCELED.idOperationStatus ? appTheme.greyColor : context.appTheme.primaryColor,
                        backgroundColor: Colors.grey.shade200,
                        semanticsValue: progressObs.value.toString(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(40),
            TextFormFieldWidget<OutlineInputBorder>(
              controller: percentageEdittinController,
              onChange: (e) => progressObs.value = e.isEmpty ? 0 : int.parse(RegExp(r'[0-9]').allMatches(e).map((e) => e[0]).join()),
              textAlign: TextAlign.center,
              fillColor: appTheme.greyColor.withOpacity(.2),
              enable: controller.appState.value is! AppStateLoading && operation.idOperationStatus == OperationStatusEnum.IN_PROGRESS.idOperationStatus,
              maxLength: 4,
              inputFormatters: [
                PercentageInputFormatter(),
              ],
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: operation.idOperationStatus.getOperationStatus() == OperationStatusEnum.IN_PROGRESS ? () async => await update() : null,
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: operation.idOperationStatus.getOperationStatus() == OperationStatusEnum.IN_PROGRESS
                              ? context.appTheme.secondColor.withOpacity(.3)
                              : context.appTheme.greyColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            LineIcons.syncIcon,
                            color: context.appTheme.secondColor,
                          ),
                        ),
                      ),
                    ),
                    const Gap(16),
                    TextActionButtom(
                      title: "Cancelar",
                      isEnable: operation.idOperationStatus.getOperationStatus() == OperationStatusEnum.IN_PROGRESS,
                      backgroundColor: appTheme.redColor,
                      padding: EdgeInsets.symmetric(
                        vertical: AppSize.padding / 2,
                        horizontal: AppSize.padding,
                      ),
                      onAction: () async {
                        if (controller.appState.value is AppStateLoading) return;
                        await controller.cancel(operationModel: operation);
                        if (widget.onAction != null) {
                          widget.onAction!();
                        }
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LineIcons.eye),
                  onPressed: () async {
                    GoTo.goTo(Routes.operationDetails, arguments: [
                      operation,
                      () => getUpdatedOperation(),
                    ]);
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class OperationSubtitleTextWidget extends StatelessWidget {
  const OperationSubtitleTextWidget({
    super.key,
    required this.text,
    this.width = 88,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final double? width;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Flexible(
      child: SizedBox(
        width: width,
        child: Text(
          textAlign: textAlign,
          text,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.mobileDisplayMedium(context).copyWith(
            fontWeight: FontWeight.w600,
            color: appTheme.titleColor,
          ),
        ),
      ),
    );
  }
}

class ValuesDetailsWidget extends StatelessWidget {
  final String title;
  final String value;
  const ValuesDetailsWidget({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: "$title ",
        style: AppTextStyle.mobileDisplayMedium(context).copyWith(
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: value,
            style: AppTextStyle.mobileDisplayMedium(context).copyWith(
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}

class TextActionButtom extends StatelessWidget {
  final String title;
  final VoidCallback onAction;
  final Color? backgroundColor;
  final bool isLoading;
  final bool isEnable;
  final Color? titleColor;
  final Color? selectedColor;
  final EdgeInsets? padding;
  final bool? selected;
  const TextActionButtom({
    super.key,
    required this.title,
    required this.onAction,
    this.padding,
    this.isLoading = false,
    this.isEnable = true,
    this.backgroundColor,
    this.titleColor,
    this.selected,
    this.selectedColor,
  });

  ButtonStyle get _buttonStyle => TextButton.styleFrom(
        backgroundColor: isLoading || !isEnable ? Colors.grey : backgroundColor ?? Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: selected != null
              ? BorderSide(
                  color: isLoading || !isEnable ? Colors.grey : selectedColor ?? backgroundColor ?? Colors.transparent,
                  width: 2,
                )
              : BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading || !isEnable ? null : () => onAction(),
      style: _buttonStyle,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(4),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              )
            : Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.mobileDisplayMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? Colors.white,
                ),
              ),
      ),
    );
  }
}
