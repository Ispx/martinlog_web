import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:scaffold_responsive/scaffold_responsive.dart';

import '../../components/banner_component.dart';
import '../../core/consts/routes.dart';
import '../../core/dependencie_injection_manager/simple.dart';
import '../../images/app_images.dart';
import '../../mixins/validators_mixin.dart';
import '../../navigator/go_to.dart';
import '../../state/app_state.dart';
import '../../style/size/app_size.dart';
import '../../style/text/app_text_style.dart';
import '../../view_models/auth_view_model.dart';
import '../../widgets/buttom_widget.dart';
import '../../widgets/text_form_field_widget.dart';

class AuthViewMobile extends StatefulWidget {
  const AuthViewMobile({super.key});

  @override
  State<AuthViewMobile> createState() => _AuthViewMobileState();
}

class _AuthViewMobileState extends State<AuthViewMobile> with ValidatorsMixin {
  late final GlobalKey<FormState> formState;
  late final ResponsiveMenuController menuController;
  late final AuthViewModel controller;
  late final Worker worker;

  var _password = '';
  var _cpf = '';
  var isVisiblePassword = false.obs;
  set cpf(String cpf) => _cpf = cpf;
  set password(String password) => _password = password;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await controller.init();
      setState(() {});
    });
    //GoTo.removeAllAndGoTo(Routes.menu);
    controller = simple.get<AuthViewModel>();
    worker = ever(controller.appState, (appState) {
      if (appState is AppStateError) {
        BannerComponent(
            message: appState.msg ?? "Ocorreu um erro",
            backgroundColor: Colors.red);
      }
      if (appState is AppStateDone) {
        GoTo.removeAllAndGoTo(Routes.menu);
      }
    });
    menuController = ResponsiveMenuController();
    formState = GlobalKey<FormState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.backgroundColor,
      body: _buildBody(),
    );
  }

  @override
  void dispose() {
    formState.currentState?.dispose();
    worker.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    return LayoutBuilder(builder: (context, constraint) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Gap(56),
              Image.asset(
                AppImages.logo,
                height: 32.w,
              ),
              const Gap(40),
              Form(
                key: formState,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            "Seja Bem-vindo!",
                            style: AppTextStyle.displayLarge(context).copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 26.sp,
                            ),
                          ),
                          SizedBox(
                            height: AppSize.padding / 2,
                          ),
                          Text(
                            "Insira seu CPF e Senha para efetuar o login.",
                            style: AppTextStyle.displayLarge(context).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(40),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Login",
                        style: AppTextStyle.mobileDisplayMedium(context)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Gap(16),
                    TextFormFieldWidget<OutlineInputBorder>(
                      key: ValueKey(controller.documentStored.value),
                      label: "CPF",
                      initialValue: controller.documentStored.value,
                      validator: isNotCPF,
                      onSaved: (e) {
                        cpf = e;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.]'),
                        ),
                        TextInputMask(
                          mask: '999.999.999-99',
                        ),
                      ],
                    ),
                    Gap(1.5.h),
                    Obx(
                      () => TextFormFieldWidget<OutlineInputBorder>(
                        label: "Senha",
                        validator: isNotEmpity,
                        obscure: !isVisiblePassword.value,
                        maxLines: 1,
                        sufix: GestureDetector(
                          onTap: () {
                            isVisiblePassword.value = !isVisiblePassword.value;
                          },
                          child: Icon(
                            isVisiblePassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        onSaved: (e) {
                          password = e;
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: () {
                          GoTo.goTo(Routes.passwordRecovery);
                        },
                        child: Text(
                          "Esqueci minha senha",
                          style: AppTextStyle.mobileDisplayMedium(context)
                              .copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Gap(AppSize.padding * 4),
                    Obx(() {
                      return ButtomWidget(
                        title: "Acessar agora",
                        isLoading: controller.appState.value is AppStateLoading,
                        radius: 10,
                        onTap: () async {
                          if (formState.currentState?.validate() ?? false) {
                            formState.currentState!.save();
                            await controller.login(_cpf, _password);
                          }
                        },
                      );
                    })
                  ],
                ),
              ),
              Gap(5.h),
            ],
          ),
        ),
      );
    });
  }
}
