import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/extensions/profile_type_extension.dart';
import 'package:martinlog_web/helpers/formater_helper.dart';
import 'package:martinlog_web/mixins/validators_mixin.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/models/operation_model.dart';
import 'package:martinlog_web/models/user_model.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/company_view_model.dart';
import 'package:martinlog_web/view_models/user_view_model.dart';
import 'package:martinlog_web/widgets/dropbox_widget.dart';
import 'package:martinlog_web/widgets/icon_buttom_widget.dart';
import 'package:martinlog_web/widgets/page_widget.dart';
import 'package:martinlog_web/widgets/text_action_buttom_widget.dart';
import 'package:martinlog_web/widgets/text_form_field_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  late final Worker worker;
  late final Worker workerSearch;

  final controller = simple.get<UserViewModel>();
  var textSearched = ''.obs;
  CompanyModel? companyModel;
  var operationsFilted = <OperationModel>[].obs;
  void clearFieldsFilters() {
    textSearched.value = '';
    setState(() {});
  }

  @override
  void initState() {
    simple.get<UserViewModel>().getAll();
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
            const CreateUserWidget(),
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
                    hint: 'Pesquise por nome, documento ou transportadora',
                    onChange: (e) => textSearched.value = e,
                  ),
                ),
                SizedBox(
                  width: AppSize.padding,
                ),
              ],
            ),
            const Gap(10),
            Obx(() {
              final itens = controller.usersFilted.value
                  .map(
                    (userModel) => Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppSize.padding / 2,
                      ),
                      child: UserWidget(
                        key: ObjectKey(userModel),
                        userModel: userModel,
                      ),
                    ),
                  )
                  .toList();
              return PageWidget(
                key: ObjectKey(itens),
                itens: itens,
                onRefresh: () async => await controller.getAll(),
                onDownload: () async =>
                    await controller.downloadFile(controller.usersFilted),
                totalByPage: 10,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class CreateUserWidget extends StatefulWidget {
  const CreateUserWidget({super.key});

  @override
  State<CreateUserWidget> createState() => _CreateUserWidgetState();
}

class _CreateUserWidgetState extends State<CreateUserWidget>
    with ValidatorsMixin {
  CompanyModel? companyModelSelected = null;
  ProfileTypeEnum? profileSelected = null;

  var isLoading = false.obs;
  var isOpen = false.obs;
  late final List<CompanyModel> companies;
  late TextEditingController fullnameEditingController;
  late TextEditingController documentEditingController;
  late TextEditingController emailEditingController;
  late TextEditingController companyEditingController;
  late TextEditingController profileEditingController;

  late final GlobalKey<FormState> formState;
  final controller = simple.get<UserViewModel>();
  @override
  void initState() {
    formState = GlobalKey<FormState>();
    fullnameEditingController = TextEditingController();
    documentEditingController = TextEditingController();
    emailEditingController = TextEditingController();
    companyEditingController = TextEditingController();
    profileEditingController = TextEditingController();
    companies = simple.get<CompanyViewModel>().companies.toList();
    super.initState();
  }

  void clearFields() {
    companyModelSelected = null;
    profileSelected = null;
    fullnameEditingController.clear();
    documentEditingController.clear();
    emailEditingController.clear();
    companyEditingController.clear();
    setState(() {});
  }

  void open() {
    isOpen.value = true;
  }

  void close() {
    isOpen.value = false;
  }

  Future<void> create() async {
    if (companyModelSelected == null || profileSelected == null) {
      BannerComponent(
        message: "Preencha todos os campos para cadastrar um novo usuário",
        backgroundColor: Colors.red,
      );
      return;
    }
    if (formState.currentState?.validate() ?? false) {
      isLoading.value = true;
      await controller.create(
        fullname: fullnameEditingController.text,
        document: documentEditingController.text,
        idCompany: companyModelSelected!.idCompany,
        idProfile: profileSelected!.idProfileType,
        email: emailEditingController.text,
      );
      isLoading.value = false;
      close();
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
                  title: 'Novo usuário',
                  icon: const Icon(LineIcons.user),
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
                                title: "Nome completo",
                                child: TextFormFieldWidget<OutlineInputBorder>(
                                  controller: fullnameEditingController,
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
                                title: "CPF",
                                child: TextFormFieldWidget<OutlineInputBorder>(
                                  controller: documentEditingController,
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
                                title: "E-mail",
                                child: TextFormFieldWidget<OutlineInputBorder>(
                                  controller: emailEditingController,
                                  validator: isNotEmail,
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
                            Expanded(
                              child: buildSelectable(
                                context: context,
                                title: "Perfil",
                                child: DropBoxWidget<ProfileTypeEnum>(
                                  width: 20.w,
                                  controller: profileEditingController,
                                  enable: controller.appState.value
                                      is! AppStateLoading,
                                  dropdownMenuEntries: ProfileTypeEnum.values
                                      .map(
                                        (e) =>
                                            DropdownMenuEntry<ProfileTypeEnum>(
                                          value: e,
                                          label: e.description,
                                        ),
                                      )
                                      .toList(),
                                  onSelected: (ProfileTypeEnum? e) {
                                    profileSelected = e;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: AppSize.padding * 2,
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
                            const Expanded(child: SizedBox.shrink()),
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

class UserWidget extends StatefulWidget {
  final UserModel userModel;

  const UserWidget({
    super.key,
    required this.userModel,
  });

  @override
  State<UserWidget> createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  late final TextEditingController profileEditingController;
  final controller = simple.get<UserViewModel>();
  @override
  void initState() {
    profileEditingController = TextEditingController(
        text: widget.userModel.idProfile.getProfile().description);
    super.initState();
  }

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
              SizedBox(
                width: 12.w,
                child: Text(
                  widget.userModel.fullname.capitalize ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.displayMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: appTheme.titleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 8.w,
                child: Text(
                  FormaterHelper.cpfOrCPNJ(widget.userModel.document),
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.displayMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: appTheme.titleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 10.w,
                child: Text(
                  widget.userModel.email,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.displayMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: appTheme.titleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 10.w,
                child: DropBoxWidget<ProfileTypeEnum>(
                  controller: profileEditingController,
                  dropdownMenuEntries: [
                    ...ProfileTypeEnum.values
                        .map((e) =>
                            DropdownMenuEntry(value: e, label: e.description))
                        .toList()
                  ],
                  onSelected: (e) async {
                    if (e == null) return;
                    await controller.updateUser(
                      widget.userModel.copyWith(
                        idProfile: e.idProfileType,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 8.w,
                child: Text(
                  widget.userModel.isActive ? 'Ativo' : 'Desativado',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.displayMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: appTheme.titleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 15.w,
                child: Text(
                  widget.userModel.companyModel.fantasyName,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.displayMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: appTheme.titleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 10.w,
                child: TextActionButtomWidget(
                  title: widget.userModel.isActive ? 'Desativar' : 'Ativar',
                  isEnable: controller.appState.value is! AppStateLoading,
                  backgroundColor: widget.userModel.isActive
                      ? appTheme.redColor
                      : appTheme.greenColor,
                  padding: EdgeInsets.symmetric(
                    vertical: AppSize.padding / 2,
                    horizontal: AppSize.padding,
                  ),
                  onAction: () async {
                    if (controller.appState.value is AppStateLoading) return;
                    await controller.updateUser(
                      widget.userModel.copyWith(
                        isActive: !widget.userModel.isActive,
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
