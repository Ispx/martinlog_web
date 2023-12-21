import 'package:flutter/material.dart';
import 'package:flutter_excel/excel.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/operation_status_enum.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
import 'package:martinlog_web/extensions/operation_status_extension.dart';
import 'package:martinlog_web/extensions/profile_type_extension.dart';
import 'package:martinlog_web/input_formaters/liscense_plate_input_formatter.dart';
import 'package:martinlog_web/input_formaters/percentage_input_formatter.dart';
import 'package:martinlog_web/input_formaters/upper_case_text_formatter.dart';
import 'package:martinlog_web/mixins/validators_mixin.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/navigator/go_to.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/company_view_model.dart';
import 'package:martinlog_web/view_models/dock_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';
import 'package:martinlog_web/widgets/icon_buttom_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:martinlog_web/enums/dock_type_enum.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/dock_type_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/models/dock_model.dart';
import 'package:martinlog_web/models/operation_model.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/widgets/dropbox_widget.dart';
import 'package:martinlog_web/widgets/text_form_field_widget.dart';

class OperationView extends StatefulWidget {
  const OperationView({super.key});

  @override
  State<OperationView> createState() => _OperationViewState();
}

class _OperationViewState extends State<OperationView> {
  late final Worker worker;
  final controller = simple.get<OperationViewModel>();

  @override
  void initState() {
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
            Obx(() {
              return PageWidget(
                itens: controller.operations.value
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
                onRefresh: () async => await controller.getAll(),
                limitByPage: 10,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class PageWidget extends StatefulWidget {
  final List<Widget> itens;
  final int limitByPage;
  final VoidCallback? onRefresh;

  const PageWidget({
    Key? key,
    required this.itens,
    required this.limitByPage,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<PageWidget> createState() => _PageWidgetState();
}

class _PageWidgetState extends State<PageWidget> {
  late List<Widget> sublist;
  @override
  void initState() {
    final lastIndex = widget.itens.length < widget.limitByPage
        ? widget.itens.length
        : widget.limitByPage;
    sublist = widget.itens.sublist(0, lastIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      height: double.maxFinite,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.padding / 2,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  if (widget.onRefresh != null) {
                    widget.onRefresh!();
                  }
                },
                icon: const Icon(Icons.refresh),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSize.padding),
                child: ListView.builder(
                  itemCount: widget.itens.length,
                  itemBuilder: (context, index) => widget.itens[index],
                ),
              ),
            ),
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
    companies = simple.get<AuthViewModel>().authModel?.idProfile ==
            ProfileTypeEnum.MASTER.idProfileType
        ? simple.get<CompanyViewModel>().companies.toList()
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
          : e.idDockType.getDockType() == dockTypeSelected)
      .toList();

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
                width: 15.w,
                child: IconButtonWidget(
                  onTap: open,
                  title: 'Nova Operação',
                  icon: const Icon(Icons.add),
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
                              child: buildSelectable(
                                context: context,
                                title: "Tipo",
                                child: DropBoxWidget<DockType>(
                                  controller: dockTypeEditingController,
                                  enable: controller.appState.value
                                      is! AppStateLoading,
                                  width: 15.w,
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
                              flex: 2,
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
                                          icon: const Icon(LineIcons.dolly),
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

  const OperationWidget({
    super.key,
    required this.operationModel,
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
  late final AnimationController animationController;
  late final Animation<double> progressAnimation;
  late final Animation<int> textAnimation;
  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: 2.seconds)
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(100.milliseconds).then(
        (value) => animationController.forward(),
      );
    });

    super.initState();
  }

  Future<void> downloadFile() async {
    final excel = Excel.createExcel();
    const sheetName = "Detalhes";
    excel.updateCell(
        sheetName, CellIndex.indexByString("A1"), "TRANSPORTADORA");
    excel.updateCell(sheetName, CellIndex.indexByString("A2"),
        widget.operationModel.companyModel.fantasyName);
    excel.updateCell(sheetName, CellIndex.indexByString("B1"), "CNPJ");
    excel.updateCell(sheetName, CellIndex.indexByString("B2"),
        widget.operationModel.companyModel.cnpj);
    excel.updateCell(sheetName, CellIndex.indexByString("C1"), "DOCA");
    excel.updateCell(sheetName, CellIndex.indexByString("C2"),
        widget.operationModel.dockModel?.code);
    excel.updateCell(sheetName, CellIndex.indexByString("D1"), "Tipo");
    excel.updateCell(sheetName, CellIndex.indexByString("D2"),
        widget.operationModel.dockModel?.idDockType.getDockType().description);
    excel.updateCell(sheetName, CellIndex.indexByString("E1"), "Status");
    excel.updateCell(
        sheetName,
        CellIndex.indexByString("E2"),
        widget.operationModel.idOperationStatus
            .getOperationStatus()
            .description);
    excel.updateCell(
        sheetName, CellIndex.indexByString("F1"), "Data de início");
    excel.updateCell(sheetName, CellIndex.indexByString("F2"),
        widget.operationModel.createdAt.ddMMyyyyHHmmss);
    excel.updateCell(
        sheetName, CellIndex.indexByString("G1"), "Data de finalização");
    excel.updateCell(sheetName, CellIndex.indexByString("G2"),
        widget.operationModel.finishedAt?.ddMMyyyyHHmmss ?? '');
    excel.updateCell(sheetName, CellIndex.indexByString("H1"), "Placa");
    excel.updateCell(sheetName, CellIndex.indexByString("H2"),
        widget.operationModel.liscensePlate);
    excel.updateCell(sheetName, CellIndex.indexByString("I1"), "Descrição");
    excel.updateCell(sheetName, CellIndex.indexByString("I2"),
        widget.operationModel.description);
    excel.updateCell(
        sheetName, CellIndex.indexByString("J1"), "Chave da operação");
    excel.updateCell(sheetName, CellIndex.indexByString("J2"),
        widget.operationModel.operationKey);
    excel.setDefaultSheet(sheetName);
    excel.save(fileName: "${widget.operationModel.operationKey}.xlsx");
  }

  Future<void> update() async {
    await controller.updateProgress(
      operationKey: widget.operationModel.operationKey,
      progress: progressObs.value,
    );
  }

  @override
  void dispose() {
    workerAppState.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Obx(() {
      return Card(
        elevation: 0.0,
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
                    widget.operationModel.dockModel!.idDockType
                        .getDockType()
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
                child: SizedBox(
                  width: 4.w,
                  child: Text(
                    widget.operationModel.dockModel?.code ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.displayMedium(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: appTheme.titleColor,
                    ),
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
                  maxLength: 3,
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
                      operationKey: widget.operationModel.operationKey);
                  await controller.getAll();
                },
              ),
              IconButton(
                icon: const Icon(LineIcons.eye),
                onPressed: () {
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
                          width: 70.w,
                          child: DetailsWidget(
                            operationModel: widget.operationModel,
                          ),
                        ),
                        actions: [
                          SizedBox(
                            width: 10.w,
                            child: IconButtonWidget(
                              icon: const Icon(LineIcons.download),
                              radius: 10,
                              title: 'Baixar arquivo',
                              onTap: downloadFile,
                            ),
                          ),
                          SizedBox(
                            width: AppSize.padding,
                          ),
                          SizedBox(
                            width: 10.w,
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
                      value: widget.operationModel.dockModel!.idDockType
                          .getDockType()
                          .description,
                    ),
                    ValuesDetailsWidget(
                        title: 'Status:',
                        value: widget.operationModel.idOperationStatus
                            .getOperationStatus()
                            .description),
                    ValuesDetailsWidget(
                      title: 'Data de início:',
                      value: widget.operationModel.createdAt.ddMMyyyyHHmmss,
                    ),
                    ValuesDetailsWidget(
                      title: 'Data da finalização:',
                      value: widget.operationModel.finishedAt?.ddMMyyyyHHmmss ??
                          '',
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
            Positioned(
              height: snap.maxWidth * .3,
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
