import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/operation_status_enum.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
import 'package:martinlog_web/extensions/operation_status_extension.dart';
import 'package:martinlog_web/functions/futures.dart';
import 'package:martinlog_web/input_formaters/liscense_plate_input_formatter.dart';
import 'package:martinlog_web/input_formaters/upper_case_text_formatter.dart';
import 'package:martinlog_web/mixins/validators_mixin.dart';
import 'package:martinlog_web/models/auth_model.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/dock_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';
import 'package:martinlog_web/views/auth_view.dart';
import 'package:martinlog_web/widgets/app_bar_widget.dart';
import 'package:martinlog_web/widgets/buttom_widget.dart';
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
            Obx(() {
              return controller.appState.value is AppStateLoading
                  ? const SizedBox(
                      height: 8,
                      child: LinearProgressIndicator(),
                    )
                  : const SizedBox.shrink();
            }),
            const Gap(5),
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
  late int totalPages;
  late int currentPage;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      height: double.maxFinite,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppSize.padding * 1.5,
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
                            enable:
                                controller.appState.value is! AppStateLoading,
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
                            enable:
                                controller.appState.value is! AppStateLoading,
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
                      ),
                      Expanded(
                        child: buildSelectable(
                          context: context,
                          title: "Transportadora",
                          child: DropBoxWidget<DockModel>(
                            width: 20.w,
                            controller: dockCodeEditingController,
                            enable:
                                controller.appState.value is! AppStateLoading,
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
                            enable:
                                controller.appState.value is! AppStateLoading,
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
                            child: Obx(
                              () {
                                return ButtomWidget(
                                  isLoading: isLoading.value,
                                  radius: 10,
                                  backgroundColor: context.appTheme.secondColor,
                                  textColor: Colors.white,
                                  title: 'Iniciar operação',
                                  onTap: () async {
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
                              },
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

  final controller = simple.get<OperationViewModel>();

  late final Worker workerAppState;
  late final Worker workerProgress;

  @override
  void initState() {
    progressObs.value = widget.operationModel.progress;
    workerAppState = ever(controller.appState, (appState) {
      if (appState is AppStateError) {
        progressObs.update((val) {
          progressObs.value = widget.operationModel.progress;
        });
        setState(() {});
      }
    });

    workerProgress = debounce(progressObs, (progressUpdated) async {
      if (controller.appState.value is AppStateLoading) return;
      await controller.updateProgress(
          operationKey: widget.operationModel.operationKey,
          progress: progressObs.value);
      await controller.getAll();
    });

    super.initState();
  }

  @override
  void dispose() {
    workerAppState.dispose();
    workerProgress.dispose();
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
                  ? Flexible(
                      flex: 2,
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
              Flexible(
                child: Text(
                  widget.operationModel.dockModel!.idDockType
                      .getDockType()
                      .description,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.displayMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: appTheme.titleColor,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  widget.operationModel.dockModel?.code ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.displayMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: appTheme.titleColor,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  widget.operationModel.liscensePlate,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.displayMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: appTheme.titleColor,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  widget.operationModel.idOperationStatus
                      .getOperationStatus()
                      .description,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.displayMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: appTheme.titleColor,
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
                      value: progressObs.value / 100,
                      color: widget.operationModel.idOperationStatus ==
                              OperationStatusEnum.IN_PROGRESS.idOperationStatus
                          ? context.appTheme.primaryColor
                          : appTheme.greyColor,
                      backgroundColor: Colors.grey.shade200,
                      semanticsValue: progressObs.value.toString(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: TextFormFieldWidget<OutlineInputBorder>(
                  initialValue: progressObs.value.toString(),
                  textAlign: TextAlign.center,
                  fillColor: appTheme.greyColor.withOpacity(.2),
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
                title: "Cancelar",
                isEnable: widget.operationModel.idOperationStatus
                        .getOperationStatus() ==
                    OperationStatusEnum.IN_PROGRESS,
                backgroundColor: appTheme.redColor,
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
    });
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
