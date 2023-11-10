import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
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
                                      (e) => Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: AppSize.padding / 2,
                                        ),
                                        child: OperationWidget(
                                          operationModel: e,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onRefresh: () async {
                                  await Future.wait([getAccountInfo]);
                                },
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
            /*s
            Align(
              alignment: Alignment.topRight,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.arrow_back),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.arrow_forward),
                  )
                ],
              ),
            ),
            */

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

class ListOperationsWidget extends StatelessWidget {
  const ListOperationsWidget({super.key});

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...List.generate(
                10,
                (index) => Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSize.padding / 2,
                  ),
                  child: OperationWidget(
                    operationModel: OperationModel(
                      operationKey: "121421fdspkjnf;sdsadadasdas",
                      idCompany: 1,
                      idUser: 1,
                      liscensePlate: "LNS4I49",
                      progress: index,
                      idOperationStatus: 2,
                      dockModel: DockModel(
                        code: "001",
                        idDockType: 1,
                        createdAt: DateTime.now(),
                      ),
                      createdAt: DateTime.now(),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OperationWidget extends StatelessWidget {
  final OperationModel operationModel;
  const OperationWidget({super.key, required this.operationModel});

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
              title: operationModel.operationKey.substring(0, 8),
              backgroundColor: Colors.grey,
              onAction: () {},
            ),
            Text(
              operationModel.createdAt.ddMMyyyyHHmmss,
              style: AppTextStyle.displayMedium(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              operationModel.dockModel!.idDockType.getDockType().description,
              style: AppTextStyle.displayMedium(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              operationModel.dockModel?.code ?? '',
              style: AppTextStyle.displayMedium(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              operationModel.liscensePlate,
              style: AppTextStyle.displayMedium(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  "${operationModel.progress}%",
                  style: AppTextStyle.displaySmall(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CircularProgressIndicator(
                  value: operationModel.progress.toDouble() / 100,
                  color: context.appTheme.primaryColor,
                  backgroundColor: Colors.grey.shade200,
                  semanticsValue: operationModel.progress.toString(),
                ),
              ],
            ),
            TextActionButtom(
              title: "Acessar",
              backgroundColor: context.appTheme.primaryColor,
              onAction: () {},
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

  final EdgeInsets? padding;
  const TextActionButtom({
    super.key,
    required this.title,
    required this.onAction,
    this.padding,
    this.isLoading = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : () => onAction(),
      style: ButtonStyle(
        shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
          (states) => RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        backgroundColor: MaterialStateProperty.resolveWith(
          (states) =>
              isLoading ? Colors.grey : backgroundColor ?? Colors.transparent,
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
                style: AppTextStyle.displayMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
