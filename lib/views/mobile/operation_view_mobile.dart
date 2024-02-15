import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/dock_type_enum.dart';
import 'package:martinlog_web/enums/operation_status_enum.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
import 'package:martinlog_web/extensions/dock_type_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/extensions/operation_status_extension.dart';
import 'package:martinlog_web/extensions/profile_type_extension.dart';
import 'package:martinlog_web/input_formaters/liscense_plate_input_formatter.dart';
import 'package:martinlog_web/input_formaters/percentage_input_formatter.dart';
import 'package:martinlog_web/input_formaters/upper_case_text_formatter.dart';
import 'package:martinlog_web/mixins/validators_mixin.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/models/dock_model.dart';
import 'package:martinlog_web/models/operation_model.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/utils/utils.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/company_view_model.dart';
import 'package:martinlog_web/view_models/dock_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';
import 'package:martinlog_web/widgets/dropbox_widget.dart';
import 'package:martinlog_web/widgets/icon_buttom_widget.dart';
import 'package:martinlog_web/widgets/page_widget.dart';
import 'package:martinlog_web/widgets/text_form_field_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../navigator/go_to.dart';

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
              return PageWidget(
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

class CreateOperationWidget extends StatefulWidget {
  const CreateOperationWidget({super.key});

  @override
  State<CreateOperationWidget> createState() => _CreateOperationWidgetState();
}

class _CreateOperationWidgetState extends State<CreateOperationWidget> with ValidatorsMixin {
  DockType? dockTypeSelected = null;
  DockModel? dockModelSelected = null;
  CompanyModel? companyModelSelected = null;

  var isLoading = false.obs;
  var isOpen = false.obs;
  late final List<CompanyModel> companies;
  late TextEditingController liscensePlateEditingController;
  late TextEditingController descriptionEditingController;
  late TextEditingController dockTypeEditingController;
  late TextEditingController dockCodeEditingController;
  late TextEditingController companyEditingController;

  late final GlobalKey<FormState> formState;
  final controller = simple.get<OperationViewModel>();
  @override
  void initState() {
    formState = GlobalKey<FormState>();
    liscensePlateEditingController = TextEditingController();
    descriptionEditingController = TextEditingController();
    dockCodeEditingController = TextEditingController();
    dockTypeEditingController = TextEditingController();
    companyEditingController = TextEditingController();
    companies = simple.get<AuthViewModel>().authModel?.idProfile == ProfileTypeEnum.MASTER.idProfileType
        ? simple.get<CompanyViewModel>().companies.toList()
        : [
            simple.get<CompanyViewModel>().companyModel!,
          ];
    super.initState();
  }

  List<DockModel> getDocksByDockType() =>
      simple.get<DockViewModel>().docks.where((e) => dockTypeSelected == null ? true : e.idDockType.getDockType() == dockTypeSelected).toList();

  void clearFields() {
    dockModelSelected = null;
    companyModelSelected = null;
    liscensePlateEditingController.clear();
    descriptionEditingController.clear();
    dockCodeEditingController.clear();
    dockTypeEditingController.clear();
    companyEditingController.clear();
    setState(() {});
  }

  void open() {
    isOpen.value = true;
  }

  void close() {
    isOpen.value = false;
  }

  Future<void> start() async {
    if (companyModelSelected == null || dockModelSelected == null) {
      BannerComponent(
        message: "Preencha todas as informações para criar uma operação",
        backgroundColor: Colors.red,
      );
      return;
    }
    if (formState.currentState?.validate() ?? false) {
      isLoading.value = true;
      await controller.create(
        companyModel: companyModelSelected!,
        dockCode: dockModelSelected!.code,
        liscensePlate: liscensePlateEditingController.text,
        description: descriptionEditingController.text,
      );
      isLoading.value = false;
      clearFields();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return !isOpen.value
          ? Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 136,
                child: IconButtonWidget(
                  title: 'Nova operação',
                  onTap: open,
                  icon: const Icon(
                    LineIcons.dolly,
                  ),
                ),
              ),
            )
          : SizedBox(
              child: Container(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSize.padding * 1.5,
                  ),
                  child: Form(
                    key: formState,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 520,
                          child: Column(
                            children: [
                              buildSelectable(
                                context: context,
                                title: "Tipo",
                                child: DropBoxWidget<DockType>(
                                  controller: dockTypeEditingController,
                                  enable: controller.appState.value is! AppStateLoading,
                                  width: MediaQuery.of(context).size.width - 16,
                                  dropdownMenuEntries: DockType.values
                                      .map(
                                        (e) => DropdownMenuEntry<DockType>(
                                          value: e,
                                          label: e.description,
                                        ),
                                      )
                                      .toList(),
                                  onSelected: (DockType? e) {
                                    dockTypeSelected = e;
                                    dockModelSelected = null;
                                    dockCodeEditingController.clear();
                                    setState(() {});
                                  },
                                ),
                              ),
                              const Gap(8),
                              buildSelectable(
                                context: context,
                                title: "Doca",
                                child: DropBoxWidget<DockModel>(
                                  controller: dockCodeEditingController,
                                  enable: controller.appState.value is! AppStateLoading,
                                  width: MediaQuery.of(context).size.width - 16,
                                  dropdownMenuEntries: getDocksByDockType()
                                      .map(
                                        (e) => DropdownMenuEntry<DockModel>(
                                          value: e,
                                          label: e.code,
                                        ),
                                      )
                                      .toList(),
                                  onSelected: (DockModel? e) {
                                    dockModelSelected = e;
                                    setState(() {});
                                  },
                                ),
                              ),
                              const Gap(8),
                              buildSelectable(
                                context: context,
                                title: "Placa",
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width - 16,
                                  child: TextFormFieldWidget<OutlineInputBorder>(
                                    controller: liscensePlateEditingController,
                                    enable: controller.appState.value is! AppStateLoading,
                                    validator: isNotLiscensePlate,
                                    inputFormatters: [
                                      UpperCaseTextFormatter(),
                                      LiscensePlateInputFormatter(),
                                    ],
                                  ),
                                ),
                              ),
                              const Gap(8),
                              buildSelectable(
                                context: context,
                                title: "Transportadora",
                                child: DropBoxWidget<CompanyModel>(
                                  width: MediaQuery.of(context).size.width - 16,
                                  controller: companyEditingController,
                                  enable: controller.appState.value is! AppStateLoading,
                                  dropdownMenuEntries: companies
                                      .map(
                                        (e) => DropdownMenuEntry<CompanyModel>(
                                          value: e,
                                          label: e.fantasyName,
                                        ),
                                      )
                                      .toList(),
                                  onSelected: (CompanyModel? e) {
                                    companyModelSelected = e;
                                    setState(() {});
                                  },
                                ),
                              ),
                              const Gap(32),
                              buildSelectable(
                                context: context,
                                title: "Descrição",
                                child: TextFormFieldWidget<OutlineInputBorder>(
                                  controller: descriptionEditingController,
                                  enable: controller.appState.value is! AppStateLoading,
                                ),
                              ),
                              buildSelectable(
                                context: context,
                                title: "",
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: IconButtonWidget(
                                        onTap: close,
                                        title: 'Fechar',
                                        icon: const Icon(Icons.close),
                                      ),
                                    ),
                                    SizedBox(
                                      width: AppSize.padding * 2,
                                    ),
                                    Expanded(
                                      child: IconButtonWidget(
                                        onTap: () => isLoading.value ? null : start(),
                                        title: 'Iniciar',
                                        icon: const Icon(LineIcons.check),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
    });
  }

  Widget buildSelectable({required BuildContext context, required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.mobileDisplayMedium(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: AppSize.padding,
        ),
        child,
      ],
    );
  }
}

class OperationWidgetMobile extends StatefulWidget {
  final OperationModel operationModel;
  final VoidCallback? onAction;
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
  @override
  void initState() {
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
    controller.downloadFile([widget.operationModel]);
  }

  Future<void> update() async {
    await controller.updateProgress(
      operationKey: widget.operationModel.operationKey,
      progress: progressObs.value,
    );
    if (widget.onAction != null) {
      widget.onAction!();
    }
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
        height: 342,
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
                  title: widget.operationModel.operationKey.substring(0, 8),
                  backgroundColor: appTheme.primaryColor,
                  titleColor: appTheme.titleColor,
                  onAction: () {},
                ),
                OperationSubtitleTextWidget(
                  text: Utils.fromServerToLocal(widget.operationModel.createdAt.toString()).ddMMyyyyHHmmss,
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
                    text: widget.operationModel.companyModel.fantasyName,
                    textAlign: null,
                    width: null,
                  ),
                OperationSubtitleTextWidget(
                  text: widget.operationModel.dockModel!.idDockType.getDockType().description,
                  width: null,
                ),
                OperationSubtitleTextWidget(
                  text: widget.operationModel.dockModel?.code ?? '',
                ),
                OperationSubtitleTextWidget(
                  text: widget.operationModel.liscensePlate,
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
                    widget.operationModel.idOperationStatus.getOperationStatus().description,
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
                        color: widget.operationModel.idOperationStatus == OperationStatusEnum.CANCELED.idOperationStatus
                            ? appTheme.greyColor
                            : context.appTheme.primaryColor,
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
              enable:
                  controller.appState.value is! AppStateLoading && widget.operationModel.idOperationStatus == OperationStatusEnum.IN_PROGRESS.idOperationStatus,
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
                      onTap:
                          widget.operationModel.idOperationStatus.getOperationStatus() == OperationStatusEnum.IN_PROGRESS ? () async => await update() : null,
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.operationModel.idOperationStatus.getOperationStatus() == OperationStatusEnum.IN_PROGRESS
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
                      isEnable: widget.operationModel.idOperationStatus.getOperationStatus() == OperationStatusEnum.IN_PROGRESS,
                      backgroundColor: appTheme.redColor,
                      padding: EdgeInsets.symmetric(
                        vertical: AppSize.padding / 2,
                        horizontal: AppSize.padding,
                      ),
                      onAction: () async {
                        if (controller.appState.value is AppStateLoading) return;
                        await controller.cancel(operationKey: widget.operationModel.operationKey);
                        if (widget.onAction != null) {
                          widget.onAction!();
                        }
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LineIcons.eye),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          surfaceTintColor: Colors.white,
                          title: DetailsAlertDialogTitleWidget(operationModel: widget.operationModel),
                          backgroundColor: Colors.white,
                          content: SizedBox(
                            height: 240,
                            width: MediaQuery.of(context).size.width,
                            child: DetailsWidget(
                              operationModel: widget.operationModel,
                            ),
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 142,
                                  child: IconButtonWidget(
                                    icon: const Icon(LineIcons.download),
                                    radius: 10,
                                    title: 'Baixar arquivo',
                                    onTap: downloadFile,
                                  ),
                                ),
                                const Gap(16),
                                SizedBox(
                                  width: 96,
                                  child: IconButtonWidget(
                                    icon: const Icon(Icons.close),
                                    radius: 10,
                                    title: 'Fechar',
                                    onTap: () => GoTo.pop(),
                                  ),
                                ),
                              ],
                            )
                          ],
                        );
                      },
                    );
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

class DetailsAlertDialogTitleWidget extends StatefulWidget {
  const DetailsAlertDialogTitleWidget({
    super.key,
    required this.operationModel,
    this.onAction,
  });

  final OperationModel operationModel;
  final VoidCallback? onAction;

  @override
  State<DetailsAlertDialogTitleWidget> createState() => _DetailsAlertDialogTitleWidgetState();
}

class _DetailsAlertDialogTitleWidgetState extends State<DetailsAlertDialogTitleWidget> with SingleTickerProviderStateMixin {
  var progressObs = 0.obs;
  late final TextEditingController percentageEdittinController;
  late final AnimationController animationController;
  late final Animation<double> progressAnimation;
  late final Animation<int> textAnimation;
  late final Worker workerAppState;

  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: 2.seconds)
      ..addListener(() {
        progressObs.value = textAnimation.value;
        setState(() {});
      });
    progressAnimation = Tween<double>(begin: 0.0, end: widget.operationModel.progress / 100).animate(
      CurvedAnimation(parent: animationController, curve: Curves.decelerate),
    );
    textAnimation = IntTween(begin: 0, end: widget.operationModel.progress).animate(
      CurvedAnimation(parent: animationController, curve: Curves.decelerate),
    );
    percentageEdittinController = TextEditingController(text: "${widget.operationModel.progress}%");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(200.milliseconds).then(
        (value) => animationController.forward(),
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Detalhes',
          style: AppTextStyle.displayMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        SizedBox(
          height: 32,
          width: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                "${progressObs.value}%",
                style: AppTextStyle.mobileDisplaySmall(context).copyWith(fontWeight: FontWeight.w600),
              ),
              Positioned.fill(
                child: CircularProgressIndicator(
                  value: progressAnimation.value,
                  strokeWidth: 4,
                  color: widget.operationModel.idOperationStatus == OperationStatusEnum.CANCELED.idOperationStatus
                      ? context.appTheme.greyColor
                      : context.appTheme.primaryColor,
                  backgroundColor: Colors.grey.shade200,
                  semanticsValue: progressObs.value.toString(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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

class DetailsWidget extends StatefulWidget {
  final OperationModel operationModel;
  const DetailsWidget({
    super.key,
    required this.operationModel,
  });
  @override
  State<DetailsWidget> createState() => _DetailsWidgetState();
}

class _DetailsWidgetState extends State<DetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, snap) {
        return Stack(
          children: [
            Positioned(
                left: 2.w,
                top: 2.w,
                height: snap.maxHeight * .8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ValuesDetailsWidget(
                      title: 'Transportadora:',
                      value: widget.operationModel.companyModel.fantasyName,
                    ),
                    ValuesDetailsWidget(
                      title: 'CNPJ:',
                      value: widget.operationModel.companyModel.cnpj,
                    ),
                    ValuesDetailsWidget(
                      title: 'Doca:',
                      value: widget.operationModel.dockModel!.code,
                    ),
                    ValuesDetailsWidget(
                      title: 'Tipo:',
                      value: widget.operationModel.dockModel!.idDockType.getDockType().description,
                    ),
                    ValuesDetailsWidget(title: 'Status:', value: widget.operationModel.idOperationStatus.getOperationStatus().description),
                    ValuesDetailsWidget(
                      title: 'Data de início:',
                      value: widget.operationModel.createdAt.ddMMyyyyHHmmss,
                    ),
                    ValuesDetailsWidget(
                      title: 'Data da finalização:',
                      value: widget.operationModel.finishedAt?.ddMMyyyyHHmmss ?? '',
                    ),
                    ValuesDetailsWidget(
                      title: 'Placa:',
                      value: widget.operationModel.liscensePlate,
                    ),
                    ValuesDetailsWidget(
                      title: 'Descrição:',
                      value: widget.operationModel.description ?? '',
                    ),
                    ValuesDetailsWidget(
                      title: 'Chave da operação:',
                      value: widget.operationModel.operationKey,
                    ),
                  ],
                )),
          ],
        );
      },
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
