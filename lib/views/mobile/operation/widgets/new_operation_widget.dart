import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/dock_type_enum.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/dock_type_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/extensions/profile_type_extension.dart';
import 'package:martinlog_web/input_formaters/liscense_plate_input_formatter.dart';
import 'package:martinlog_web/input_formaters/upper_case_text_formatter.dart';
import 'package:martinlog_web/mixins/validators_mixin.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/models/dock_model.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/company_view_model.dart';
import 'package:martinlog_web/view_models/dock_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';
import 'package:martinlog_web/views/mobile/operation/views/operation_view_mobile.dart';
import 'package:martinlog_web/widgets/dropbox_widget.dart';
import 'package:martinlog_web/widgets/icon_buttom_widget.dart';
import 'package:martinlog_web/widgets/text_form_field_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CreateOperationWidget extends StatefulWidget {
  const CreateOperationWidget({super.key});

  @override
  State<CreateOperationWidget> createState() => _CreateOperationWidgetState();
}

class _CreateOperationWidgetState extends State<CreateOperationWidget>
    with ValidatorsMixin {
  DockType? dockTypeSelected;
  DockModel? dockModelSelected;
  CompanyModel? companyModelSelected;

  RxBool isLoading = false.obs;

  Map<String, TextEditingController> textControllers = {
    'licensePlate': TextEditingController(),
    'description': TextEditingController(),
    'dockType': TextEditingController(),
    'dockCode': TextEditingController(),
    'company': TextEditingController(),
  };

  late final List<CompanyModel> companies;
  late final GlobalKey<FormState> formState;
  final controller = simple.get<OperationViewModel>();
  RxBool isOpen = false.obs;

  @override
  void initState() {
    formState = GlobalKey<FormState>();
    bool isProfileMaster = simple.get<AuthViewModel>().authModel?.idProfile ==
        ProfileTypeEnum.MASTER.idProfileType;

    companies = isProfileMaster
        ? simple.get<CompanyViewModel>().companies.toList()
        : [
            simple.get<CompanyViewModel>().companyModel!,
          ];

    super.initState();
  }

  void open() => isOpen.value = true;
  void close() {
    clearFields();
    isOpen.value = false;
  }

  List<DockModel> getDocksByDockType() {
    return simple
        .get<DockViewModel>()
        .docks
        .where((e) => dockTypeSelected == null
            ? true
            : e.idDockType.getDockType() == dockTypeSelected)
        .toList();
  }

  void clearFields() {
    for (var controller in textControllers.values) {
      controller.clear();
    }

    dockModelSelected = null;
    companyModelSelected = null;
    setState(() {});
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
        liscensePlate: textControllers['licensePlate']!.text,
        description: textControllers['description']!.text,
      );
      pageWidgetMobileKey += "${DateTime.now().millisecondsSinceEpoch}";
      isLoading.value = false;
      clearFields();
      setState(() {});
    }
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return !isOpen.value
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButtonWidget(
                  title: 'Nova operação',
                  onTap: open,
                  icon: const Icon(
                    LineIcons.dolly,
                  ),
                ),
              ],
            )
          : Container(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(
                vertical: AppSize.padding * 1.5,
              ),
              child: Form(
                key: formState,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildSelectable(
                      context: context,
                      title: "Tipo",
                      child: DropBoxWidget<DockType>(
                        controller: textControllers['dockType']!,
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
                          textControllers['dockCode']!.clear();
                          // setState(() {});
                        },
                      ),
                    ),
                    const Gap(8),
                    buildSelectable(
                      context: context,
                      title: "Doca",
                      child: DropBoxWidget<DockModel>(
                        controller: textControllers['dockCode']!,
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
                          // setState(() {});
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
                          controller: textControllers['licensePlate']!,
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
                        controller: textControllers['company']!,
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
                          // setState(() {});
                        },
                      ),
                    ),
                    const Gap(32),
                    buildSelectable(
                      context: context,
                      title: "Descrição",
                      child: TextFormFieldWidget<OutlineInputBorder>(
                        controller: textControllers['description']!,
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
            );
    });
  }
}
