import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/operation_status_enum.dart';
import 'package:martinlog_web/extensions/operation_status_extension.dart';
import 'package:martinlog_web/functions/futures.dart';
import 'package:martinlog_web/input_formaters/liscense_plate_input_formatter.dart';
import 'package:martinlog_web/input_formaters/upper_case_text_formatter.dart';
import 'package:martinlog_web/mixins/validators_mixin.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/view_models/dock_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';
import 'package:martinlog_web/widgets/circular_progress_indicator_widget.dart';
import 'package:martinlog_web/widgets/drawer_widget.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Operações",
        ),
      ),
      drawer: const DrawerWidget(),
      body: SizedBox(
        height: double.maxFinite,
        width: double.maxFinite,
        child: FutureBuilder(
            future: getAccountInfo,
            builder: (context, snap) {
              if (snap.hasError) {
                return Text(snap.error.toString());
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicatorWidget());
              }
              return Column(
                children: [
                  Obx(() {
                    return controller.appState.value is AppStateLoading
                        ? const SizedBox(
                            height: 8,
                            child: LinearProgressIndicator(),
                          )
                        : const SizedBox.shrink();
                  }),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(AppSize.margin),
                      child: Column(
                        children: [
                          const CreateOperationWidget(),
                          const Gap(30),
                          Expanded(
                            child: Obx(() {
                              return PageWidget(
                                itens: controller.operations.value
                                    .map(
                                      (operationModel) => Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: AppSize.padding / 2,
                                        ),
                                        child: OperationWidget(
                                          operationModel: operationModel,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onRefresh: () async =>
                                    await controller.getAll(),
                                limitByPage: 10,
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
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
  late int totalPages;
  late int currentPage;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppSize.padding,
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
              child: ListView.builder(
                itemCount: widget.itens.length,
                itemBuilder: (context, index) => widget.itens[index],
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
  var isLoading = false.obs;
  late TextEditingController liscensePlateEditingController;
  late TextEditingController descriptionEditingController;
  late TextEditingController dockTypeEditingController;
  late TextEditingController dockCodeEditingController;

  late final GlobalKey<FormState> formState;
  final controller = simple.get<OperationViewModel>();
  @override
  void initState() {
    formState = GlobalKey<FormState>();
    liscensePlateEditingController = TextEditingController();
    descriptionEditingController = TextEditingController();
    dockCodeEditingController = TextEditingController();
    dockTypeEditingController = TextEditingController();

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
    liscensePlateEditingController.clear();
    descriptionEditingController.clear();
    dockCodeEditingController.clear();
    dockTypeEditingController.clear();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SizedBox(
        child: Card(
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppSize.padding * 1.5,
              horizontal: AppSize.padding * 2,
            ),
            child: Form(
              key: formState,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildSelectable(
                        context: context,
                        title: "Tipo",
                        child: DropBoxWidget<DockType>(
                          controller: dockTypeEditingController,
                          enable: controller.appState.value is! AppStateLoading,
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
                      buildSelectable(
                        context: context,
                        title: "Doca",
                        child: DropBoxWidget<DockModel>(
                          controller: dockCodeEditingController,
                          enable: controller.appState.value is! AppStateLoading,
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
                      buildSelectable(
                        context: context,
                        title: "Placa",
                        child: SizedBox(
                          width: 10.w,
                          child: TextFormFieldWidget<OutlineInputBorder>(
                            controller: liscensePlateEditingController,
                            enable:
                                controller.appState.value is! AppStateLoading,
                            validator: isNotLiscensePlate,
                            inputFormatters: [
                              UpperCaseTextFormatter(),
                              LiscensePlateInputFormatter(),
                            ],
                          ),
                        ),
                      ),
                      buildSelectable(
                        context: context,
                        title: "Descrição",
                        child: SizedBox(
                          width: 15.w,
                          child: TextFormFieldWidget<OutlineInputBorder>(
                            controller: descriptionEditingController,
                            enable:
                                controller.appState.value is! AppStateLoading,
                          ),
                        ),
                      ),
                      buildSelectable(
                        context: context,
                        title: "",
                        child: SizedBox(
                          width: 8.w,
                          child: Obx(() {
                            return TextActionButtom(
                              title: "Iniciar",
                              isLoading: isLoading.value,
                              backgroundColor: context.appTheme.primaryColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: AppSize.padding,
                                  vertical: AppSize.padding / 2),
                              onAction: () async {
                                if (formState.currentState?.validate() ??
                                    false) {
                                  isLoading.value = true;
                                  await controller.create(
                                    dockCode: dockModelSelected!.code,
                                    liscensePlate:
                                        liscensePlateEditingController.text,
                                    description:
                                        descriptionEditingController.text,
                                  );
                                  isLoading.value = false;
                                  clearFields();
                                }
                              },
                            );
                          }),
                        ),
                      ),
                    ],
                  )
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
  late final TextEditingController progressEditingController;
  late final AnimationController animationController;
  late final Animation<double> animation;
  final controller = simple.get<OperationViewModel>();
  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: 2.seconds);
    animation = Tween<double>(
            begin: 0.0, end: widget.operationModel.progress.toDouble() / 100)
        .animate(animationController);

    animationController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
      animationController.forward();
    });
    progressEditingController =
        TextEditingController(text: widget.operationModel.progress.toString());
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSize.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppSize.padding * 1.5,
          horizontal: AppSize.padding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextActionButtom(
              title: widget.operationModel.operationKey.substring(0, 8),
              backgroundColor: Colors.grey,
              onAction: () {},
            ),
            SizedBox(
              width: 8.w,
              child: Text(
                widget.operationModel.dockModel!.idDockType
                    .getDockType()
                    .description,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.displayMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 8.w,
              child: Text(
                widget.operationModel.dockModel?.code ?? '',
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.displayMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 8.w,
              child: Text(
                widget.operationModel.liscensePlate,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.displayMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 8.w,
              child: Text(
                widget.operationModel.idOperationStatus
                    .getOperationStatus()
                    .description,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.displayMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 8.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    "${widget.operationModel.progress}%",
                    style: AppTextStyle.displaySmall(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CircularProgressIndicator(
                    value: animation.value,
                    color: widget.operationModel.idOperationStatus ==
                            OperationStatusEnum.IN_PROGRESS.idOperationStatus
                        ? context.appTheme.primaryColor
                        : Colors.grey,
                    backgroundColor: Colors.grey.shade200,
                    semanticsValue: widget.operationModel.progress.toString(),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 8.w,
              child: TextFormFieldWidget<UnderlineInputBorder>(
                controller: progressEditingController,
                enable: controller.appState.value is! AppStateLoading &&
                    widget.operationModel.idOperationStatus ==
                        OperationStatusEnum.IN_PROGRESS.idOperationStatus,
                maxLength: 3,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
            ),
            TextActionButtom(
              title: "Atualizar",
              isEnable: widget.operationModel.idOperationStatus ==
                  OperationStatusEnum.IN_PROGRESS.idOperationStatus,
              backgroundColor: Colors.blue,
              onAction: () async {
                if (controller.appState.value is AppStateLoading) return;
                await controller.updateProgress(
                    operationKey: widget.operationModel.operationKey,
                    progress: int.parse(progressEditingController.text));
                await controller.getAll();
              },
            ),
            TextActionButtom(
              title: "Cancelar",
              isEnable: widget.operationModel.idOperationStatus
                      .getOperationStatus() ==
                  OperationStatusEnum.IN_PROGRESS,
              backgroundColor: Colors.orange,
              onAction: () async {
                if (controller.appState.value is AppStateLoading) return;
                await controller.cancel(
                    operationKey: widget.operationModel.operationKey);
                await controller.getAll();
              },
            ),
          ],
        ),
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

  final EdgeInsets? padding;
  const TextActionButtom({
    super.key,
    required this.title,
    required this.onAction,
    this.padding,
    this.isLoading = false,
    this.isEnable = true,
    this.backgroundColor,
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
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
