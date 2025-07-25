import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/input_formaters/upper_case_text_formatter.dart';
import 'package:martinlog_web/mixins/validators_mixin.dart';
import 'package:martinlog_web/models/branch_office_model.dart';
import 'package:martinlog_web/models/dock_model.dart';
import 'package:martinlog_web/models/dock_type_model.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/branch_office_view_model.dart';
import 'package:martinlog_web/view_models/dock_type_view_model.dart';
import 'package:martinlog_web/view_models/dock_view_model.dart';
import 'package:martinlog_web/views/web/operation_view.dart';
import 'package:martinlog_web/widgets/dropbox_widget.dart';
import 'package:martinlog_web/widgets/icon_buttom_widget.dart';
import 'package:martinlog_web/widgets/page_widget.dart';
import 'package:martinlog_web/widgets/text_form_field_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DockView extends StatefulWidget {
  const DockView({super.key});

  @override
  State<DockView> createState() => _DockViewState();
}

class _DockViewState extends State<DockView> {
  late final Worker worker;
  late final Worker workerSearch;
  var textSearched = ''.obs;
  final controller = simple.get<DockViewModel>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.resetFilter();
      await simple.get<DockViewModel>().getAll();
    });
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
    worker.dispose();
    workerSearch.dispose();
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
            const CreateDockWidget(),
            const Gap(5),
            const Divider(),
            const Gap(30),
            Row(
              children: [
                SizedBox(
                  width: AppSize.padding,
                ),
                Expanded(
                  child: TextFormFieldWidget<OutlineInputBorder>(
                    label: 'Pesquisar',
                    hint: 'Pesquise por nome',
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
              final itens = controller.docksSearched.isEmpty
                  ? controller.docks.value
                  : controller.docksSearched.value;
              return PageWidget(
                key: ValueKey(DateTime.now()),
                itens: itens
                    .map(
                      (dockModel) => Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSize.padding / 2,
                        ),
                        child: DockWidget(
                          key: ObjectKey(dockModel),
                          dockModel: dockModel,
                        ),
                      ),
                    )
                    .toList(),
                isLoadingItens: controller.appState.value is AppStateLoading,
                onRefresh: () async => await controller.getAll(),
                onDownload: () async => await controller.downloadFile(),
                totalByPage: 10,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class CreateDockWidget extends StatefulWidget {
  const CreateDockWidget({super.key});

  @override
  State<CreateDockWidget> createState() => _CreateDockWidgetState();
}

class _CreateDockWidgetState extends State<CreateDockWidget>
    with ValidatorsMixin {
  var isLoading = false.obs;
  var isOpen = false.obs;
  late TextEditingController dockCodeEditingController;
  late TextEditingController dockTypeEditingController;
  late TextEditingController branchOfficeEditingController;

  late TextEditingController isActiveEditingController;

  DockTypeModel? dockTypeSelected = null;
  BranchOfficeModel? branchOfficeSelected = null;

  late final GlobalKey<FormState> formState;
  final controller = simple.get<DockViewModel>();
  @override
  void initState() {
    formState = GlobalKey<FormState>();
    dockCodeEditingController = TextEditingController();
    dockTypeEditingController = TextEditingController();
    isActiveEditingController = TextEditingController();
    branchOfficeEditingController = TextEditingController();
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
    dockCodeEditingController.clear();
    branchOfficeEditingController.clear();
    setState(() {});
  }

  void open() {
    isOpen.value = true;
  }

  void close() {
    isOpen.value = false;
  }

  Future<void> create() async {
    if (dockTypeSelected == null) {
      BannerComponent(
        message: "Selecione o tipo de doca",
        backgroundColor: Colors.red,
      );
      return;
    }
    if (branchOfficeSelected == null) {
      BannerComponent(
        message: "Selecione uma filial",
        backgroundColor: Colors.red,
      );
      return;
    }
    if (formState.currentState?.validate() ?? false) {
      isLoading.value = true;
      await controller.create(
        idDockType: dockTypeSelected!.idDockType,
        code: dockCodeEditingController.text,
        branchOffice: branchOfficeSelected!,
      );
      await controller.getAll();
      isLoading.value = false;
      clearFields();
    }
  }

  @override
  void dispose() {
    formState.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return !isOpen.value
          ? Visibility(
              visible: simple
                      .get<AuthViewModel>()
                      .authModel!
                      .idProfile
                      .getProfile() ==
                  ProfileTypeEnum.MASTER,
              child: Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 15.w,
                  child: IconButtonWidget(
                    onTap: open,
                    title: 'Nova Doca',
                    icon: const Icon(LineIcons.warehouse),
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
                            buildSelectable(
                              context: context,
                              title: "Tipo",
                              child: DropBoxWidget<DockTypeModel>(
                                controller: dockTypeEditingController,
                                enable: controller.appState.value
                                    is! AppStateLoading,
                                width: 15.w,
                                dropdownMenuEntries: simple
                                    .get<DockTypeViewModel>()
                                    .dockTypes
                                    .map(
                                      (e) => DropdownMenuEntry<DockTypeModel>(
                                        value: e,
                                        label: e.name,
                                      ),
                                    )
                                    .toList(),
                                onSelected: (DockTypeModel? e) {
                                  dockTypeSelected = e;
                                  dockCodeEditingController.clear();
                                  setState(() {});
                                },
                              ),
                            ),
                            SizedBox(
                              width: AppSize.padding * 2,
                            ),
                            Obx(() {
                              final branchOffices = simple
                                  .get<BranchOfficeViewModelImpl>()
                                  .branchOfficeList
                                  .value;
                              return buildSelectable(
                                context: context,
                                title: "Filial",
                                child: DropBoxWidget<BranchOfficeModel>(
                                  enable: controller.appState.value
                                      is! AppStateLoading,
                                  icon: const Icon(Icons.business),
                                  dropdownMenuEntries: branchOffices
                                      .map(
                                        (e) => DropdownMenuEntry<
                                            BranchOfficeModel>(
                                          value: e,
                                          label: e.name,
                                        ),
                                      )
                                      .toList(),
                                  onSelected: (BranchOfficeModel? e) {
                                    branchOfficeSelected = e;
                                    setState(() {});
                                  },
                                  controller: branchOfficeEditingController,
                                ),
                              );
                            }),
                            SizedBox(
                              width: AppSize.padding * 2,
                            ),
                            Expanded(
                              child: buildSelectable(
                                context: context,
                                title: "Código",
                                child: TextFormFieldWidget<OutlineInputBorder>(
                                  controller: dockCodeEditingController,
                                  enable: controller.appState.value
                                      is! AppStateLoading,
                                  validator: isNotEmpity,
                                  inputFormatters: [UpperCaseTextFormatter()],
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
                            const Expanded(flex: 3, child: SizedBox.shrink()),
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
                                              isLoading.value ? null : create(),
                                          title: 'Criar',
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

class DockWidget extends StatefulWidget {
  final DockModel dockModel;

  const DockWidget({
    super.key,
    required this.dockModel,
  });

  @override
  State<DockWidget> createState() => _DockWidgetState();
}

class _DockWidgetState extends State<DockWidget> {
  late final TextEditingController dockCodeEdittinController;
  late final TextEditingController branchOfficeEdittinController;

  final controller = simple.get<DockViewModel>();

  @override
  void initState() {
    dockCodeEdittinController =
        TextEditingController(text: widget.dockModel.code);
    branchOfficeEdittinController = TextEditingController(
      text: widget.dockModel.branchOfficeModel?.name,
    );

    super.initState();
  }

  @override
  void dispose() {
    dockCodeEdittinController.dispose();
    branchOfficeEdittinController.dispose();
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
                flex: 2,
                child: Text(
                  widget.dockModel.createdAt.ddMMyyyyHHmmss,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.displayMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: appTheme.titleColor,
                  ),
                ),
              ),
              Flexible(
                child: SizedBox(
                  width: 10.w,
                  child: Center(
                    child: Text(
                      widget.dockModel.dockTypeModel?.name ?? 'N/D',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.displayMedium(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: appTheme.titleColor,
                      ),
                    ),
                  ),
                ),
              ),
              Obx(
                () {
                  final branchOffices = simple
                      .get<BranchOfficeViewModelImpl>()
                      .branchOfficeList
                      .value;
                  return DropBoxWidget<BranchOfficeModel>(
                    key: ObjectKey(widget.dockModel),
                    enable: simple
                            .get<AuthViewModel>()
                            .authModel!
                            .idProfile
                            .getProfile() ==
                        ProfileTypeEnum.MASTER,
                    label: 'Filial',
                    width: 13.w,
                    icon: const Icon(Icons.business),
                    dropdownMenuEntries: [
                      ...branchOffices
                          .map(
                            (e) =>
                                DropdownMenuEntry(value: e, label: e.name),
                          )
                          .toList()
                    ],
                    onSelected: (branchOffice) {
                      if (branchOffice == null) return;
                      controller.bindBranchOffice(
                          branchOffice, widget.dockModel);
                    },
                    controller: branchOfficeEdittinController,
                  );
                },
              ),
              Flexible(
                child: SizedBox(
                  width: 10.w,
                  child: Center(
                    child: Text(
                      widget.dockModel.code.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.displayMedium(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: appTheme.titleColor,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: SizedBox(
                  width: 10.w,
                  child: Text(
                    (widget.dockModel.operationKey?.isEmpty ?? true)
                        ? 'Disponível'
                        : 'Em operação',
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.displayMedium(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: appTheme.titleColor,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10.w,
                child: TextActionButtom(
                  title: widget.dockModel.isActive ? 'Desativar' : 'Ativar',
                  isEnable: controller.appState.value is! AppStateLoading,
                  backgroundColor: widget.dockModel.isActive
                      ? appTheme.redColor
                      : appTheme.greenColor,
                  padding: EdgeInsets.symmetric(
                    vertical: AppSize.padding / 2,
                    horizontal: AppSize.padding,
                  ),
                  onAction: () async {
                    if (controller.appState.value is AppStateLoading)
                      return;
                    await controller.updateDock(
                      widget.dockModel.copyWith(
                        isActive: !widget.dockModel.isActive,
                      ),
                    );
                    await controller.getAll();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
