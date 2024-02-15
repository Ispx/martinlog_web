import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/dock_type_enum.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
import 'package:martinlog_web/extensions/dock_type_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/input_formaters/upper_case_text_formatter.dart';
import 'package:martinlog_web/mixins/validators_mixin.dart';
import 'package:martinlog_web/models/dock_model.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/utils/utils.dart';
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
  final controller = simple.get<DockViewModel>();

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
            const CreateDockWidget(),
            const Gap(5),
            const Divider(),
            const Gap(30),
            Obx(() {
              return PageWidget(
                itens: controller.docks.value
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
  late TextEditingController isActiveEditingController;

  DockType? dockTypeSelected = null;

  late final GlobalKey<FormState> formState;
  final controller = simple.get<DockViewModel>();
  @override
  void initState() {
    formState = GlobalKey<FormState>();
    dockCodeEditingController = TextEditingController();
    dockTypeEditingController = TextEditingController();
    isActiveEditingController = TextEditingController();
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
    dockCodeEditingController.clear();
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
    if (formState.currentState?.validate() ?? false) {
      isLoading.value = true;
      await controller.create(
        dockType: dockTypeSelected!,
        code: dockCodeEditingController.text,
      );
      await controller.getAll();
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
                  title: 'Nova Doca',
                  icon: const Icon(LineIcons.warehouse),
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
                                  dockCodeEditingController.clear();
                                  setState(() {});
                                },
                              ),
                            ),
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
  final controller = simple.get<DockViewModel>();

  @override
  void initState() {
    dockCodeEdittinController =
        TextEditingController(text: widget.dockModel.code);

    super.initState();
  }

  Future<void> update() async {}

  @override
  void dispose() {
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
                flex: 2,
                child: Text(
                  Utils.fromServerToLocal(widget.dockModel.createdAt.toString())
                      .ddMMyyyyHHmmss,
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
                      widget.dockModel.idDockType.getDockType().description,
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
                    if (controller.appState.value is AppStateLoading) return;
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
