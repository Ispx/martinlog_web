import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/operation_status_enum.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/extensions/operation_status_extension.dart';
import 'package:martinlog_web/extensions/profile_type_extension.dart';
import 'package:martinlog_web/input_formaters/liscense_plate_input_formatter.dart';
import 'package:martinlog_web/input_formaters/percentage_input_formatter.dart';
import 'package:martinlog_web/input_formaters/upper_case_text_formatter.dart';
import 'package:martinlog_web/mixins/validators_mixin.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/models/dock_model.dart';
import 'package:martinlog_web/models/dock_type_model.dart';
import 'package:martinlog_web/models/operation_model.dart';
import 'package:martinlog_web/navigator/go_to.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/branch_office_view_model.dart';
import 'package:martinlog_web/view_models/company_view_model.dart';
import 'package:martinlog_web/view_models/dock_type_view_model.dart';
import 'package:martinlog_web/view_models/dock_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';
import 'package:martinlog_web/widgets/dropbox_widget.dart';
import 'package:martinlog_web/widgets/icon_buttom_widget.dart';
import 'package:martinlog_web/widgets/page_widget.dart';
import 'package:martinlog_web/widgets/text_form_field_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart'
    as dataPicker;

var pageWidgetMobileKey = 'state_key';

class OperationView extends StatefulWidget {
  const OperationView({super.key});

  @override
  State<OperationView> createState() => _OperationViewState();
}

class _OperationViewState extends State<OperationView> {
  late final Worker worker;
  late final Worker workerSearch;

  final controller = simple.get<OperationViewModel>();
  late final TextEditingController operationStatusEditingController;
  OperationStatusEnum? operationStatusEnumSelected;
  late final TextEditingController dockTypeEditingController;
  var textSearched = ''.obs;
  var textDateRangeSelected = ''.obs;
  DockTypeModel? dockTypeSelected;
  DateRange? dateRangeSelected;
  OperationStatusEnum? operationStatusSelected;

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      simple.get<OperationViewModel>().operations.clear();
      simple.get<OperationViewModel>().operationsFilted.clear();
      await Future.wait([
        simple.get<DockViewModel>().getAll(),
        simple.get<CompanyViewModel>().getCompany(),
        simple.get<CompanyViewModel>().getAllCompanies(),
        simple.get<OperationViewModel>().getAll(),
        simple.get<DockTypeViewModel>().getAll(),
      ]);
    });

    operationStatusEditingController = TextEditingController();
    dockTypeEditingController = TextEditingController();
    workerSearch = ever(textSearched, controller.search);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(
        vertical: AppSize.padding,
        horizontal: AppSize.padding * 2,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const CreateOperationWidget(),
            const Gap(5),
            const Divider(),
            const Gap(30),
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    await dataPicker.showDateRangePickerModalDialog(
                      context: context,
                      builder: (context, date) {
                        return DateRangePickerWidget(
                          onDateRangeChanged: (DateRange? value) {
                            dateRangeSelected = value;
                          },
                          quickDateRanges: [
                            QuickDateRange(
                                dateRange: null, label: "Limpar datas"),
                            QuickDateRange(
                              label: 'Últimos 7 dias',
                              dateRange: DateRange(
                                DateTime.now()
                                    .subtract(const Duration(days: 7)),
                                DateTime.now(),
                              ),
                            ),
                            QuickDateRange(
                              label: 'Últimos 30 dias',
                              dateRange: DateRange(
                                DateTime.now()
                                    .subtract(const Duration(days: 30)),
                                DateTime.now(),
                              ),
                            ),
                            QuickDateRange(
                              label: 'Últimos 60 dias',
                              dateRange: DateRange(
                                DateTime.now()
                                    .subtract(const Duration(days: 60)),
                                DateTime.now(),
                              ),
                            ),
                            QuickDateRange(
                              label: 'Últimos 90 dias',
                              dateRange: DateRange(
                                DateTime.now()
                                    .subtract(const Duration(days: 90)),
                                DateTime.now(),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    if (dateRangeSelected == null) {
                      controller.clear();
                      textDateRangeSelected.value = '';
                      controller.getAll();
                    }
                    if (dateRangeSelected != null) {
                      controller.clear();
                      controller.getAll(
                        dateFrom: dateRangeSelected?.start,
                        dateUntil: dateRangeSelected?.end,
                      );
                      textDateRangeSelected.value =
                          "${dateRangeSelected!.start.ddMMyyyy} - ${dateRangeSelected!.end.ddMMyyyy}";
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.date_range),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.resolveWith(
                      (states) => RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                SizedBox(
                  width: AppSize.padding,
                ),
                Obx(() {
                  return Text(
                    textDateRangeSelected.value,
                    style: AppTextStyle.displayMedium(context),
                  );
                }),
                SizedBox(
                  width: AppSize.padding,
                ),
                DropBoxWidget<OperationStatusEnum>(
                  controller: operationStatusEditingController,
                  label: 'Status',
                  dropdownMenuEntries: [
                    ...OperationStatusEnum.values
                        .map(
                          (e) =>
                              DropdownMenuEntry(value: e, label: e.description),
                        )
                        .toList()
                  ],
                  onSelected: (e) async {
                    operationStatusSelected = e;
                    simple.get<OperationViewModel>().filterByStatus(e);
                    setState(() {});
                  },
                ),
                SizedBox(
                  width: AppSize.padding,
                ),
                Obx(() {
                  return DropBoxWidget<DockTypeModel>(
                    controller: dockTypeEditingController,
                    enable: simple.get<DockTypeViewModel>().appState
                        is! AppStateLoading,
                    label: 'Tipo',
                    dropdownMenuEntries: [
                      ...simple
                          .get<DockTypeViewModel>()
                          .dockTypes
                          .value
                          .map(
                            (e) => DropdownMenuEntry(value: e, label: e.name),
                          )
                          .toList()
                    ],
                    onSelected: (e) {
                      if (e == null) {
                        simple.get<OperationViewModel>().resetFilter();
                        return;
                      }
                      simple.get<OperationViewModel>().filterByDock(e);
                    },
                  );
                }),
                SizedBox(
                  width: AppSize.padding,
                ),
                Expanded(
                  child: TextFormFieldWidget<OutlineInputBorder>(
                    label: 'Pesquisar',
                    hint: 'Pesquise por transportadora ou doca',
                    onChange: (e) => textSearched.value = e,
                    maxLines: 1,
                  ),
                ),
                SizedBox(
                  width: AppSize.padding,
                ),
              ],
            ),
            const Gap(10),
            Obx(() {
              final itens = controller.operationsFilted.value
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
                  .toList();
              return PageWidget(
                key: ValueKey(pageWidgetMobileKey),
                itens: itens,
                onRefresh: () async => await controller.onRefresh(),
                onDownload: () async {
                  if (dateRangeSelected == null) {
                    BannerComponent(
                      message: "Selecione um período para download do arquivo.",
                      backgroundColor: Colors.red,
                    );
                    return;
                  }
                  controller.downloadFile(
                    dateFrom: dateRangeSelected!.start,
                    dateUntil: dateRangeSelected!.end,
                    status: operationStatusSelected != null
                        ? [
                            operationStatusSelected!.idOperationStatus,
                          ]
                        : null,
                  );
                },
                totalByPage: controller.limitPaginationOffset,
                isLoadingItens:
                    controller.appState.value is AppStateLoadingMore,
                onPageChanged: (index) async {
                  await controller.getItensByPageIndex(
                    index ?? 0,
                    dateFrom: dateRangeSelected?.start,
                    dateUntil: dateRangeSelected?.end,
                  );
                  controller.search(textSearched.value);
                },
                isEnableLoadMoreItens: controller.isEnableLoadMoreItens.value,
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

class _CreateOperationWidgetState extends State<CreateOperationWidget>
    with ValidatorsMixin {
  DockTypeModel? dockTypeSelected = null;
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
  late TextEditingController routeEditingController;
  late TextEditingController placeEditingController;

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
    routeEditingController = TextEditingController();
    placeEditingController = TextEditingController();

    companies = simple.get<AuthViewModel>().authModel?.idProfile ==
            ProfileTypeEnum.MASTER.idProfileType
        ? simple
                    .get<BranchOfficeViewModelImpl>()
                    .branchOfficeActivated
                    .value
                    .idBranchOffice >
                0
            ? simple
                .get<BranchOfficeViewModelImpl>()
                .companiesBindedBranchOffice
            : simple.get<CompanyViewModel>().companies.toList()
        : [
            simple.get<CompanyViewModel>().companyModel!,
          ];
    super.initState();
  }

  List<DockModel> getDocksByDockType() => simple
      .get<DockViewModel>()
      .docks
      .where((e) => dockTypeSelected == null
          ? true
          : e.dockTypeModel?.idDockType == dockTypeSelected?.idDockType)
      .toList();

  void clearFields() {
    dockModelSelected = null;
    companyModelSelected = null;
    liscensePlateEditingController.clear();
    descriptionEditingController.clear();
    dockCodeEditingController.clear();
    dockTypeEditingController.clear();
    companyEditingController.clear();
    routeEditingController.clear();
    placeEditingController.clear();
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
        place: placeEditingController.text,
        route: routeEditingController.text,
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
                width: 15.w,
                child: IconButtonWidget(
                  onTap: open,
                  title: 'Nova Operação',
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
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Obx(() {
                                return buildSelectable(
                                  context: context,
                                  title: "Tipo",
                                  child: DropBoxWidget<DockTypeModel>(
                                    controller: dockTypeEditingController,
                                    enable: simple
                                        .get<DockTypeViewModel>()
                                        .appState is! AppStateLoading,
                                    width: 15.w,
                                    dropdownMenuEntries: simple
                                        .get<DockTypeViewModel>()
                                        .dockTypes
                                        .value
                                        .map(
                                          (e) =>
                                              DropdownMenuEntry<DockTypeModel>(
                                            value: e,
                                            label: e.name,
                                          ),
                                        )
                                        .toList(),
                                    onSelected: (DockTypeModel? e) {
                                      dockTypeSelected = e;
                                      dockModelSelected = null;
                                      dockCodeEditingController.clear();
                                      setState(() {});
                                    },
                                  ),
                                );
                              }),
                            ),
                            Expanded(
                              child: buildSelectable(
                                context: context,
                                title: "Doca",
                                child: DropBoxWidget<DockModel>(
                                  controller: dockCodeEditingController,
                                  enable: controller.appState.value
                                      is! AppStateLoading,
                                  width: 15.w,
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
                            ),
                            Expanded(
                              child: buildSelectable(
                                context: context,
                                title: "Placa",
                                child: SizedBox(
                                  width: 15.w,
                                  child:
                                      TextFormFieldWidget<OutlineInputBorder>(
                                    controller: liscensePlateEditingController,
                                    enable: controller.appState.value
                                        is! AppStateLoading,
                                    validator: isNotLiscensePlate,
                                    inputFormatters: [
                                      UpperCaseTextFormatter(),
                                      LiscensePlateInputFormatter(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: buildSelectable(
                                context: context,
                                title: "Transportadora",
                                child: DropBoxWidget<CompanyModel>(
                                  width: 20.w,
                                  controller: companyEditingController,
                                  enable: controller.appState.value
                                      is! AppStateLoading,
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
                            ),
                          ],
                        ),
                        SizedBox(
                          height: AppSize.padding * 2,
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 3,
                              fit: FlexFit.tight,
                              child: buildSelectable(
                                context: context,
                                title: "Descrição",
                                child: TextFormFieldWidget<OutlineInputBorder>(
                                  controller: descriptionEditingController,
                                  enable: controller.appState.value
                                      is! AppStateLoading,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: AppSize.padding * 2,
                            ),
                            Flexible(
                              child: buildSelectable(
                                context: context,
                                title: "Rota",
                                child: TextFormFieldWidget<OutlineInputBorder>(
                                  controller: routeEditingController,
                                  prefixText: '/',
                                  enable: controller.appState.value
                                      is! AppStateLoading,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: AppSize.padding * 2,
                            ),
                            Flexible(
                              child: buildSelectable(
                                context: context,
                                title: "Loja",
                                child: TextFormFieldWidget<OutlineInputBorder>(
                                  controller: placeEditingController,
                                  enable: controller.appState.value
                                      is! AppStateLoading,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: AppSize.padding * 2,
                            ),
                            Flexible(
                              flex: 2,
                              child: Center(
                                child: buildSelectable(
                                  context: context,
                                  title: "",
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
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
                                          onTap: () =>
                                              isLoading.value ? null : start(),
                                          title: 'Iniciar',
                                          icon: const Icon(LineIcons.check),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
    });
  }

  Widget buildSelectable(
      {required BuildContext context,
      required String title,
      required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.displayMedium(context).copyWith(
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

class OperationWidget extends StatefulWidget {
  final OperationModel operationModel;
  final VoidCallback? onAction;
  const OperationWidget({
    super.key,
    required this.operationModel,
    this.onAction,
  });

  @override
  State<OperationWidget> createState() => _OperationWidgetState();
}

class _OperationWidgetState extends State<OperationWidget>
    with SingleTickerProviderStateMixin {
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
    progressAnimation =
        Tween<double>(begin: 0.0, end: widget.operationModel.progress / 100)
            .animate(
      CurvedAnimation(parent: animationController, curve: Curves.decelerate),
    );

    textAnimation =
        IntTween(begin: 0, end: widget.operationModel.progress).animate(
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
      progressAnimation =
          Tween<double>(begin: 0.0, end: newProgress / 100).animate(
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
    controller.downloadFile(values: [widget.operationModel]);
  }

  Future<void> update() async {
    await controller.updateOperation(
      operationModel: widget.operationModel,
      progress: progressObs.value,
      additionalData: null,
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
      return Card(
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppSize.padding * 1.5,
            horizontal: AppSize.padding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: TextActionButtom(
                  title: widget.operationModel.operationKey.substring(0, 8),
                  backgroundColor: appTheme.primaryColor,
                  titleColor: appTheme.titleColor,
                  onAction: () {},
                ),
              ),
              Flexible(
                flex: 2,
                child: Text(
                  widget.operationModel.createdAt.ddMMyyyyHHmmss,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.displayMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: appTheme.titleColor,
                  ),
                ),
              ),
              simple.get<AuthViewModel>().authModel!.idProfile.getProfile() ==
                      ProfileTypeEnum.MASTER
                  ? SizedBox(
                      width: 10.w,
                      child: Text(
                        widget.operationModel.companyModel.fantasyName,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.displayMedium(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: appTheme.titleColor,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              SizedBox(
                width: 8.w,
                child: Center(
                  child: Text(
                    widget.operationModel.dockModel!.dockTypeModel?.name ??
                        'N/D',
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.displayMedium(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: appTheme.titleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Flexible(
                child: SizedBox(
                  width: 4.w,
                  child: Text(
                    widget.operationModel.dockModel?.code ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.displayMedium(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: appTheme.titleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                width: 8.w,
                child: Center(
                  child: Text(
                    widget.operationModel.liscensePlate,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.displayMedium(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: appTheme.titleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                width: 8.w,
                child: Center(
                  child: Text(
                    widget.operationModel.idOperationStatus
                        .getOperationStatus()
                        .description,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.displayMedium(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: appTheme.titleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Flexible(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      "${progressObs.value}%",
                      style: AppTextStyle.displaySmall(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CircularProgressIndicator(
                      value: progressAnimation.value,
                      color: widget.operationModel.idOperationStatus ==
                              OperationStatusEnum.CANCELED.idOperationStatus
                          ? appTheme.greyColor
                          : context.appTheme.primaryColor,
                      backgroundColor: Colors.grey.shade200,
                      semanticsValue: progressObs.value.toString(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: TextFormFieldWidget<OutlineInputBorder>(
                  controller: percentageEdittinController,
                  onChange: (e) => progressObs.value = e.isEmpty
                      ? 0
                      : int.parse(RegExp(r'[0-9]')
                          .allMatches(e)
                          .map((e) => e[0])
                          .join()),
                  textAlign: TextAlign.center,
                  fillColor: appTheme.greyColor.withOpacity(.2),
                  enable: controller.appState.value is! AppStateLoading &&
                      widget.operationModel.idOperationStatus ==
                          OperationStatusEnum.IN_PROGRESS.idOperationStatus,
                  maxLength: 4,
                  inputFormatters: [
                    PercentageInputFormatter(),
                  ],
                ),
              ),
              InkWell(
                onTap: widget.operationModel.idOperationStatus
                            .getOperationStatus() ==
                        OperationStatusEnum.IN_PROGRESS
                    ? () async => await update()
                    : null,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.operationModel.idOperationStatus
                                .getOperationStatus() ==
                            OperationStatusEnum.IN_PROGRESS
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
              TextActionButtom(
                title: "Cancelar",
                isEnable: widget.operationModel.idOperationStatus
                        .getOperationStatus() ==
                    OperationStatusEnum.IN_PROGRESS,
                backgroundColor: appTheme.redColor,
                padding: EdgeInsets.symmetric(
                  vertical: AppSize.padding / 2,
                  horizontal: AppSize.padding,
                ),
                onAction: () async {
                  if (controller.appState.value is AppStateLoading) return;
                  await controller.cancel(
                      operationModel: widget.operationModel);
                  if (widget.onAction != null) {
                    widget.onAction!();
                  }
                },
              ),
              IconButton(
                icon: const Icon(LineIcons.eye),
                onPressed: () {
                  showDialogDetailsOperation(context, widget.operationModel);
                },
              ),
            ],
          ),
        ),
      );
    });
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

class _DetailsWidgetState extends State<DetailsWidget>
    with SingleTickerProviderStateMixin {
  var additionalData = ''.obs;
  var progressObs = 0.obs;
  late final TextEditingController percentageEdittinController;
  late final TextEditingController additionalDataEdittinController;

  late final AnimationController animationController;
  late final Animation<double> progressAnimation;
  late final Animation<int> textAnimation;
  late final Worker workerAppState;
  late final Worker workerAdditionalData;
  final controller = simple.get<OperationViewModel>();
  @override
  void initState() {
    additionalDataEdittinController =
        TextEditingController(text: widget.operationModel.additionalData);
    additionalData.update((val) {
      if (widget.operationModel.additionalData != null) {
        additionalData.value = widget.operationModel.additionalData!;
        setState(() {});
      }
    });
    workerAdditionalData = debounce(
      additionalData,
      (text) async {
        if (controller.appState.value is AppStateLoading) return;
        await controller.updateOperation(
          operationModel: widget.operationModel,
          progress: widget.operationModel.progress,
          additionalData: text,
        );
      },
      time: 3.seconds,
    );
    animationController = AnimationController(vsync: this, duration: 2.seconds)
      ..addListener(() {
        progressObs.value = textAnimation.value;
        setState(() {});
      });
    progressAnimation =
        Tween<double>(begin: 0.0, end: widget.operationModel.progress / 100)
            .animate(
      CurvedAnimation(parent: animationController, curve: Curves.decelerate),
    );
    textAnimation =
        IntTween(begin: 0, end: widget.operationModel.progress).animate(
      CurvedAnimation(parent: animationController, curve: Curves.decelerate),
    );
    percentageEdittinController =
        TextEditingController(text: "${widget.operationModel.progress}%");
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
    return LayoutBuilder(
      builder: (context, snap) {
        return Stack(
          children: [
            Positioned(
              left: 2.w,
              top: 0.w,
              height: snap.maxHeight * .95,
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
                      value: widget
                              .operationModel.dockModel!.dockTypeModel?.name ??
                          'N/D'),
                  ValuesDetailsWidget(
                      title: 'Status:',
                      value: widget.operationModel.idOperationStatus
                          .getOperationStatus()
                          .description),
                  ValuesDetailsWidget(
                    title: 'Data de início:',
                    value: widget.operationModel.createdAt
                        .toLocal()
                        .ddMMyyyyHHmmss,
                  ),
                  ValuesDetailsWidget(
                    title: 'Data da finalização:',
                    value: widget.operationModel.finishedAt
                            ?.toLocal()
                            .ddMMyyyyHHmmss ??
                        '',
                  ),
                  ValuesDetailsWidget(
                    title: 'Placa:',
                    value: widget.operationModel.liscensePlate,
                  ),
                  ValuesDetailsWidget(
                    title: 'Rota:',
                    value: "/${widget.operationModel.route ?? ''}",
                  ),
                  ValuesDetailsWidget(
                    title: 'Loja:',
                    value: widget.operationModel.place ?? '',
                  ),
                  ValuesDetailsWidget(
                    title: 'Descrição:',
                    value: widget.operationModel.description ?? '',
                  ),
                  Text.rich(
                    TextSpan(
                      text: 'Anexo: ',
                      style: AppTextStyle.displayMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: widget.operationModel.urlImage != null
                              ? '${widget.operationModel.urlImage!.substring(0, 50)}...'
                              : '',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              if (widget.operationModel.urlImage != null) {
                                await launchUrl(
                                    Uri.parse(widget.operationModel.urlImage!));
                                /*
                                html.window.open(
                                    widget.operationModel.urlImage!,
                                    'Arquivo anexado');
                                    */
                              }
                            },
                          style: AppTextStyle.displayMedium(context).copyWith(
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blueAccent,
                            color: Colors.blueAccent,
                          ),
                        )
                      ],
                    ),
                  ),
                  ValuesDetailsWidget(
                    title: 'Chave da operação:',
                    value: widget.operationModel.operationKey,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: const Border.fromBorderSide(
                        BorderSide(width: 1, color: Colors.black),
                      ),
                    ),
                    width: snap.maxWidth * .40,
                    height: snap.maxHeight * .35,
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: additionalDataEdittinController,
                      readOnly: widget.operationModel.idOperationStatus ==
                          OperationStatusEnum.FINISHED.idOperationStatus,
                      enabled: controller.appState is! AppStateLoading,
                      maxLength: 800,
                      maxLines: 20,
                      style: AppTextStyle.displayMedium(context).copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Descrição',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        helperStyle:
                            AppTextStyle.displayMedium(context).copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      onChanged: (e) {
                        additionalData.value = e;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              height: snap.maxWidth * .25,
              width: snap.maxWidth * .3,
              right: 5.w,
              top: 1.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    "${progressObs.value}%",
                    style: AppTextStyle.displaySmall(context)
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 22.sp),
                  ),
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: progressAnimation.value,
                      strokeWidth: 15,
                      color: widget.operationModel.idOperationStatus ==
                              OperationStatusEnum.CANCELED.idOperationStatus
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
        style: AppTextStyle.displayMedium(context).copyWith(
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: value,
            style: AppTextStyle.displayMedium(context).copyWith(
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
  final EdgeInsets? padding;
  const TextActionButtom({
    super.key,
    required this.title,
    required this.onAction,
    this.padding,
    this.isLoading = false,
    this.isEnable = true,
    this.backgroundColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading || !isEnable ? null : () => onAction(),
      style: ButtonStyle(
        shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
          (states) => RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        backgroundColor: MaterialStateProperty.resolveWith(
          (states) => isLoading || !isEnable
              ? Colors.grey
              : backgroundColor ?? Colors.transparent,
        ),
      ),
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
                style: AppTextStyle.displayMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? Colors.white,
                ),
              ),
      ),
    );
  }
}

void showDialogDetailsOperation(
    BuildContext context, OperationModel operationModel) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Detalhes',
          style: AppTextStyle.displayMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: Colors.white,
        content: SizedBox(
          height: 80.h,
          width: 80.w,
          child: DetailsWidget(
            operationModel: operationModel,
          ),
        ),
        actions: [
          SizedBox(
            width: 12.w,
            child: IconButtonWidget(
              icon: const Icon(LineIcons.upload),
              radius: 10,
              title: 'Importar arquivo',
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? imageFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (imageFile == null) return;
                await simple.get<OperationViewModel>().uploadFile(
                      operationModel: operationModel,
                      file: File(imageFile.path),
                    );
              },
            ),
          ),
          /*
          SizedBox(
            width: AppSize.padding,
          ),
          SizedBox(
            width: 12.w,
            child: IconButtonWidget(
              icon: const Icon(LineIcons.download),
              radius: 10,
              title: 'Visualizar',
              onTap: operationModel.urlImage != null
                  ? () {
                      showDialogDisplayImage(context, operationModel);
                    }
                  : null,
            ),
          ),
          */
          SizedBox(
            width: AppSize.padding,
          ),
          SizedBox(
            width: 12.w,
            child: Obx(() {
              return IconButtonWidget(
                icon: const Icon(LineIcons.download),
                radius: 10,
                title: 'Baixar arquivo',
                onTap: simple.get<OperationViewModel>().appState.value
                        is AppStateDone
                    ? () => simple
                        .get<OperationViewModel>()
                        .downloadFile(values: [operationModel])
                    : null,
              );
            }),
          ),
          SizedBox(
            width: AppSize.padding,
          ),
          SizedBox(
            width: 12.w,
            child: IconButtonWidget(
              icon: const Icon(Icons.close),
              radius: 10,
              title: 'Fechar',
              onTap: () => GoTo.pop(),
            ),
          )
        ],
      );
    },
  );
}

void showDialogDisplayImage(
    BuildContext context, OperationModel operationModel) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Arquivo',
          style: AppTextStyle.displayMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: Colors.white,
        content: SizedBox(
          height: 80.h,
          width: 80.w,
          child: Image.network(operationModel.urlImage!),
        ),
        actions: [
          SizedBox(
            width: 12.w,
            child: Obx(() {
              return IconButtonWidget(
                icon: const Icon(LineIcons.download),
                radius: 10,
                title: 'Baixar arquivo',
                onTap: simple.get<OperationViewModel>().appState.value
                        is AppStateDone
                    ? () => simple
                        .get<OperationViewModel>()
                        .downloadFile(values: [operationModel])
                    : null,
              );
            }),
          ),
          SizedBox(
            width: AppSize.padding,
          ),
          SizedBox(
            width: 12.w,
            child: IconButtonWidget(
              icon: const Icon(Icons.close),
              radius: 10,
              title: 'Fechar',
              onTap: () => GoTo.pop(),
            ),
          )
        ],
      );
    },
  );
}
