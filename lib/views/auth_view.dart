import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/state_manager.dart';
import 'package:martinlog_web/core/consts/routes.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/mixins/validators_mixin.dart';
import 'package:martinlog_web/navigator/go_to.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/widgets/buttom_widget.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/widgets/text_form_field_widget.dart';
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
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          "assets/images/background.jpeg",
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          Flexible(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.padding),
              child: Column(
                children: [
                  const Gap(30),
                  Text(
                    "MARTIN LOG",
                    style: AppTextStyle.displayLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(30),
                  Expanded(
                    child: Form(
                      key: formState,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Login",
                            style: AppTextStyle.displayMedium(context).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Gap(15),
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
                          const Gap(20),
                          TextFormFieldWidget<OutlineInputBorder>(
                            label: "Senha",
                            validator: isNotEmpity,
                            onSaved: (e) {
                              password = e;
                            },
                          ),
                          const Gap(30),
                          Obx(() {
                            return ButtomWidget(
                              title: "Acessar",
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
                  SizedBox(
                    height: AppSize.padding * 10,
                  )
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
