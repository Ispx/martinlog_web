import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/state_manager.dart';
import 'package:martinlog_web/core/consts/routes.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/images/app_images.dart';
import 'package:martinlog_web/mixins/validators_mixin.dart';
import 'package:martinlog_web/navigator/go_to.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/widgets/buttom_widget.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/widgets/text_form_field_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:scaffold_responsive/scaffold_responsive.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> with ValidatorsMixin {
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
    controller = simple.get<AuthViewModel>();

    worker = ever(controller.appState, (appState) {
      if (appState is AppStateError) {
        BannerComponent(
            message: appState.msg ?? "Ocorreu um erro",
            backgroundColor: Colors.red);
      }
      if (appState is AppStateDone) {
        GoTo.removeAllPreviousAndGoTo(Routes.operation);
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
      bool isWidthLow =
          constraint.maxWidth >= MediaQuery.of(context).size.width * .20;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isWidthLow
              ? Flexible(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          AppImages.background,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          Flexible(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                children: [
                  Gap(8.h),
                  Image.asset(
                    AppImages.logo,
                    height: 8.w,
                  ),
                  Gap(8.h),
                  Expanded(
                    child: Form(
                      key: formState,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Text(
                                  "Seja Bem-vindo!",
                                  style: AppTextStyle.displayLarge(context)
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                  ),
                                ),
                                SizedBox(
                                  height: AppSize.padding / 2,
                                ),
                                Text(
                                  "Insira seu CPF e Senha para efetuar o login.",
                                  style: AppTextStyle.displaySmall(context)
                                      .copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap(3.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Login",
                              style:
                                  AppTextStyle.displayMedium(context).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Gap(3.h),
                          TextFormFieldWidget<OutlineInputBorder>(
                            label: "CPF",
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
                          Gap(4.h),
                          Obx(
                            () => TextFormFieldWidget<OutlineInputBorder>(
                              label: "Senha",
                              validator: isNotEmpity,
                              obscure: !isVisiblePassword.value,
                              maxLines: 1,
                              sufix: GestureDetector(
                                onTap: () {
                                  isVisiblePassword.value =
                                      !isVisiblePassword.value;
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
                            child: Padding(
                              padding:
                                  EdgeInsets.only(top: AppSize.padding / 2),
                              child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  "Esqueci minha senha",
                                  style: AppTextStyle.displaySmall(context)
                                      .copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Gap(AppSize.padding * 2),
                          Obx(() {
                            return ButtomWidget(
                              title: "Acessar agora",
                              isLoading:
                                  controller.appState.value is AppStateLoading,
                              radius: 10,
                              onTap: () async {
                                if (formState.currentState?.validate() ??
                                    false) {
                                  formState.currentState!.save();
                                  await controller.login(_cpf, _password);
                                }
                              },
                            );
                          })
                        ],
                      ),
                    ),
                  ),
                  Gap(5.h),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
