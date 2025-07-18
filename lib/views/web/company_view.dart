import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
import 'package:martinlog_web/helpers/formater_helper.dart';
import 'package:martinlog_web/input_formaters/upper_case_text_formatter.dart';
import 'package:martinlog_web/mixins/validators_mixin.dart';
import 'package:martinlog_web/models/branch_office_model.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/state/menu_state.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/branch_office_view_model.dart';
import 'package:martinlog_web/view_models/menu_view_model.dart';
import 'package:martinlog_web/widgets/dropbox_widget.dart';
import 'package:martinlog_web/widgets/icon_buttom_widget.dart';
import 'package:martinlog_web/widgets/page_widget.dart';
import 'package:martinlog_web/widgets/text_form_field_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../view_models/company_view_model.dart';

class CompanyView extends StatefulWidget {
  const CompanyView({super.key});

  @override
  State<CompanyView> createState() => _CompanyViewState();
}

class _CompanyViewState extends State<CompanyView> {
  late final Worker worker;
  late final Worker workerSearch;
  var textSearched = ''.obs;

  final controller = simple.get<CompanyViewModel>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      simple.get<CompanyViewModel>().resetFilter();
      simple.get<CompanyViewModel>().getAllCompanies();
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
            const CreateCompanyWidget(),
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
                    hint: 'Pesquise por razão social ou cnpj',
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
              final itens = controller.companiesSearched.value.isEmpty
                  ? controller.companies.value
                  : controller.companiesSearched.value;
              return PageWidget(
                itens: itens
                    .map(
                      (companyModel) => Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSize.padding / 2,
                        ),
                        child: CompanyWidget(
                          key: ObjectKey(companyModel),
                          companyModel: companyModel,
                        ),
                      ),
                    )
                    .toList(),
                onRefresh: () async => await controller.getAllCompanies(),
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

class CreateCompanyWidget extends StatefulWidget {
  const CreateCompanyWidget({super.key});

  @override
  State<CreateCompanyWidget> createState() => _CreateCompanyWidgetState();
}

class _CreateCompanyWidgetState extends State<CreateCompanyWidget>
    with ValidatorsMixin {
  late final TextEditingController socialRasonEditingController;
  late final TextEditingController fantasyNameEditingController;
  late final TextEditingController cnpjEditingController;
  late final TextEditingController ownerNameEditingController;
  late final TextEditingController ownerCpfEditingController;
  late final TextEditingController telephoneEditingController;
  late final TextEditingController zipcodeEditingController;
  late final TextEditingController streetNumberEditingController;
  late final TextEditingController streetComplementEditingController;
  late final TextEditingController branchOfficeEditingController;

  var isLoading = false.obs;
  var isOpen = false.obs;
  List<BranchOfficeModel> branchOfficesSelected = [];
  late final GlobalKey<FormState> formState;
  final controller = simple.get<CompanyViewModel>();
  @override
  void initState() {
    formState = GlobalKey<FormState>();
    socialRasonEditingController = TextEditingController();
    fantasyNameEditingController = TextEditingController();
    cnpjEditingController = TextEditingController();
    ownerNameEditingController = TextEditingController();
    ownerCpfEditingController = TextEditingController();
    telephoneEditingController = TextEditingController();
    zipcodeEditingController = TextEditingController();
    streetNumberEditingController = TextEditingController();
    streetComplementEditingController = TextEditingController();
    branchOfficeEditingController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });

    super.initState();
  }

  void clearFields() {
    socialRasonEditingController.clear();
    fantasyNameEditingController.clear();
    cnpjEditingController.clear();
    ownerNameEditingController.clear();
    ownerCpfEditingController.clear();
    telephoneEditingController.clear();
    zipcodeEditingController.clear();
    streetNumberEditingController.clear();
    streetComplementEditingController.clear();
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
    if (formState.currentState?.validate() ?? false) {
      isLoading.value = true;
      await controller.createCompany(
        CompanyModel(
          idCompany: -1,
          socialRason: socialRasonEditingController.text,
          fantasyName: fantasyNameEditingController.text,
          cnpj: cnpjEditingController.text,
          ownerName: ownerNameEditingController.text,
          ownerCpf: ownerCpfEditingController.text,
          telephone: telephoneEditingController.text,
          zipcode: zipcodeEditingController.text,
          streetNumber: streetNumberEditingController.text,
          streetComplement: streetComplementEditingController.text,
          branchOffices: branchOfficesSelected,
        ),
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
                  title: 'Nova Transportadora',
                  icon: const Icon(LineIcons.truck),
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
                                title: "CNPJ",
                                child: TextFormFieldWidget<OutlineInputBorder>(
                                  controller: cnpjEditingController,
                                  enable: controller.appState.value
                                      is! AppStateLoading,
                                  validator: isNotCNPJ,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'),
                                    ),
                                    TextInputMask(
                                      mask: '99.999.999/9999-99',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: AppSize.padding * 2,
                            ),
                            Expanded(
                              child: buildSelectable(
                                context: context,
                                title: "Razão Social",
                                child: TextFormFieldWidget<OutlineInputBorder>(
                                  controller: socialRasonEditingController,
                                  enable: controller.appState.value
                                      is! AppStateLoading,
                                  validator: isNotEmpity,
                                  inputFormatters: [
                                    UpperCaseTextFormatter(),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: AppSize.padding * 2,
                            ),
                            Expanded(
                              child: buildSelectable(
                                context: context,
                                title: "Nome fantasia",
                                child: TextFormFieldWidget<OutlineInputBorder>(
                                  controller: fantasyNameEditingController,
                                  enable: controller.appState.value
                                      is! AppStateLoading,
                                  validator: isNotEmpity,
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
                            Expanded(
                              child: buildSelectable(
                                context: context,
                                title: "Proprietário",
                                child: TextFormFieldWidget<OutlineInputBorder>(
                                  controller: ownerNameEditingController,
                                  enable: controller.appState.value
                                      is! AppStateLoading,
                                  validator: isNotFullName,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: AppSize.padding * 2,
                            ),
                            Expanded(
                              child: buildSelectable(
                                context: context,
                                title: "CPF Proprietário",
                                child: TextFormFieldWidget<OutlineInputBorder>(
                                  controller: ownerCpfEditingController,
                                  enable: controller.appState.value
                                      is! AppStateLoading,
                                  validator: isNotCPF,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'),
                                    ),
                                    TextInputMask(
                                      mask: '999.999.999-99',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: AppSize.padding * 2,
                            ),
                            Expanded(
                              child: buildSelectable(
                                context: context,
                                title: "Telefone",
                                child: TextFormFieldWidget<OutlineInputBorder>(
                                  controller: telephoneEditingController,
                                  enable: controller.appState.value
                                      is! AppStateLoading,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'),
                                    ),
                                    TextInputMask(
                                      mask: '(99) 99999-9999',
                                    ),
                                  ],
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
                            Expanded(
                              child: buildSelectable(
                                context: context,
                                title: "CEP",
                                child: TextFormFieldWidget<OutlineInputBorder>(
                                  controller: zipcodeEditingController,
                                  enable: controller.appState.value
                                      is! AppStateLoading,
                                  validator: isNotEmpity,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'),
                                    ),
                                    TextInputMask(
                                      mask: '99999-999',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: AppSize.padding * 2,
                            ),
                            Expanded(
                              child: buildSelectable(
                                context: context,
                                title: "Número",
                                child: TextFormFieldWidget<OutlineInputBorder>(
                                  controller: streetNumberEditingController,
                                  enable: controller.appState.value
                                      is! AppStateLoading,
                                  validator: isNotEmpity,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: AppSize.padding * 2,
                            ),
                            Expanded(
                              child: buildSelectable(
                                context: context,
                                title: "Complemento",
                                child: TextFormFieldWidget<OutlineInputBorder>(
                                  controller: streetComplementEditingController,
                                  enable: controller.appState.value
                                      is! AppStateLoading,
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
                            buildSelectable(
                              context: context,
                              title: "Filial",
                              child: DropBoxWidget<BranchOfficeModel>(
                                enable: controller.appState.value
                                    is! AppStateLoading,
                                width: 15.w,
                                dropdownMenuEntries: simple
                                    .get<BranchOfficeViewModelImpl>()
                                    .branchs
                                    .map(
                                      (e) =>
                                          DropdownMenuEntry<BranchOfficeModel>(
                                        value: e,
                                        label: e.name,
                                      ),
                                    )
                                    .toList(),
                                onSelected: (BranchOfficeModel? e) {
                                  if (!branchOfficesSelected.contains(e)) {
                                    branchOfficesSelected.add(e!);
                                  }
                                  branchOfficeEditingController.clear();
                                  setState(() {});
                                },
                                controller: branchOfficeEditingController,
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
                                          title: 'Cadastrar',
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

class CompanyWidget extends StatefulWidget {
  final CompanyModel companyModel;

  const CompanyWidget({
    super.key,
    required this.companyModel,
  });

  @override
  State<CompanyWidget> createState() => _CompanyWidgetState();
}

class _CompanyWidgetState extends State<CompanyWidget> {
  late final TextEditingController branchOfficeEdittinController;

  @override
  void initState() {
    branchOfficeEdittinController = TextEditingController(
      text: widget.companyModel.branchOffices.firstOrNull?.name,
    );
    super.initState();
  }

  @override
  void dispose() {
    branchOfficeEdittinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
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
                widget.companyModel.createdAt!.toLocal().ddMMyyyyHHmmss,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.displayMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: appTheme.titleColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              flex: 2,
              child: Text(
                FormaterHelper.cnpj(widget.companyModel.cnpj),
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.displayMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: appTheme.titleColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 25.w,
                child: Text(
                  widget.companyModel.socialRason,
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
              flex: 2,
              child: SizedBox(
                width: 25.w,
                child: Text(
                  widget.companyModel.fantasyName,
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
              flex: 2,
              child: SizedBox(
                width: 20.w,
                child: Text(
                  widget.companyModel.ownerName,
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
              flex: 2,
              child: SizedBox(
                width: 10.w,
                child: Text(
                  FormaterHelper.telephone(widget.companyModel.telephone),
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.displayMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: appTheme.titleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                simple
                    .get<BranchOfficeViewModelImpl>()
                    .setCompanyToBind(widget.companyModel);
                simple
                    .get<MenuViewModel>()
                    .changeMenu(MenuEnum.BindBranchOffice);
              },
              icon: Icon(
                Icons.business,
                color: widget.companyModel.branchOffices.isEmpty
                    ? null
                    : context.appTheme.secondColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LinkCompanyBranchOfficeWidget extends StatefulWidget {
  final CompanyModel companyModel;
  const LinkCompanyBranchOfficeWidget({
    super.key,
    required this.companyModel,
  });

  @override
  State<LinkCompanyBranchOfficeWidget> createState() =>
      _LinkCompanyBranchOfficeWidgetState();
}

class _LinkCompanyBranchOfficeWidgetState
    extends State<LinkCompanyBranchOfficeWidget> {
  late BranchOfficeViewModel controller;
  @override
  void initState() {
    controller = simple.get<BranchOfficeViewModelImpl>();
    controller.getAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 90.w,
        height: 80.h,
        color: Colors.white,
        child: Column(
          children: [],
        ));
  }
}
