import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../components/banner_component.dart';
import '../../core/consts/routes.dart';
import '../../core/dependencie_injection_manager/simple.dart';
import '../../mixins/validators_mixin.dart';
import '../../navigator/go_to.dart';
import '../../state/app_state.dart';
import '../../style/text/app_text_style.dart';
import '../../view_models/password_recovery_view_model.dart';
import '../../widgets/buttom_widget.dart';
import '../../widgets/text_form_field_widget.dart';

class PasswordRecoveryMobileView extends StatefulWidget {
  const PasswordRecoveryMobileView({super.key});

  @override
  State<PasswordRecoveryMobileView> createState() => _PasswordRecoveryMobileViewState();
}

class _PasswordRecoveryMobileViewState extends State<PasswordRecoveryMobileView> with ValidatorsMixin {
  late final TextEditingController tokenEditingController;
  late final TextEditingController passwordEditingController;
  late final PageController pageController;
  late final GlobalKey<FormState> formStateStart;
  late final GlobalKey<FormState> formStateComplete;

  late final Worker worker;
  final controller = simple.get<PasswordRecoveryViewModel>();

  @override
  void initState() {
    pageController = PageController();
    formStateStart = GlobalKey<FormState>();
    formStateComplete = GlobalKey<FormState>();
    tokenEditingController = TextEditingController();
    passwordEditingController = TextEditingController();

    worker = ever(
      controller.appState,
      (state) {
        if (state is AppStateError) {
          BannerComponent(message: state.msg ?? "Ocorreu um erro", backgroundColor: Colors.red);
        }
        if (state is AppStateDone) {
          nextPage();
        }
      },
    );
    super.initState();
  }

  Future<void> nextPage() async {
    await pageController.nextPage(
      duration: 300.milliseconds,
      curve: Curves.linear,
    );
  }

  Future<void> previousPage() async {
    await pageController.previousPage(
      duration: 300.milliseconds,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    worker.dispose();
    pageController.dispose();
    formStateStart.currentState?.dispose();
    formStateComplete.currentState?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.backgroundColor,
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          StartRecoveryPasswordWidget(
            formState: formStateStart,
            onSave: controller.start,
          ),
          CompleteRecoveryPasswordWidget(
            formState: formStateComplete,
            onConfirm: (password, token) async {
              await controller.complete(
                token: token,
                password: password,
              );
            },
            onPrevious: previousPage,
          ),
          const SucessRecoveryPasswordWidget(),
        ],
      ),
    );
  }
}

class StartRecoveryPasswordWidget extends StatelessWidget with ValidatorsMixin {
  final void Function(String document) onSave;
  final GlobalKey<FormState> formState;
  const StartRecoveryPasswordWidget({
    super.key,
    required this.formState,
    required this.onSave,
  });
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, snap) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formState,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Gap(264),
                    Column(
                      children: [
                        Text(
                          "Esqueci minha senha",
                          style: AppTextStyle.mobileDisplayLarge(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 1.w,
                        ),
                        Text(
                          "Informe o cpf do seu usuário",
                          style: AppTextStyle.mobileDisplayMedium(context),
                        ),
                      ],
                    ),
                    const Gap(32),
                    TextFormFieldWidget(
                      label: "CPF",
                      validator: isNotCPF,
                      onSaved: onSave,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.]'),
                        ),
                        TextInputMask(
                          mask: '999.999.999-99',
                        ),
                      ],
                    ),
                    const Gap(24),
                    Obx(() {
                      return ButtomWidget(
                        title: 'Avançar',
                        radius: 10,
                        isLoading: simple.get<PasswordRecoveryViewModel>().appState.value is AppStateLoading,
                        onTap: () async {
                          if (formState.currentState!.validate()) {
                            formState.currentState!.save();
                          }
                        },
                      );
                    }),
                  ],
                ),
                TextButton(
                  onPressed: GoTo.pop,
                  child: Text(
                    'Voltar para o login',
                    style: AppTextStyle.mobileDisplayMedium(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ignore: must_be_immutable
class CompleteRecoveryPasswordWidget extends StatelessWidget with ValidatorsMixin {
  final GlobalKey<FormState> formState;
  final void Function(String token, String password) onConfirm;
  final VoidCallback onPrevious;

  String token = '';
  String password = '';
  CompleteRecoveryPasswordWidget({
    super.key,
    required this.formState,
    required this.onConfirm,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, snap) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: formState,
            child: Column(
              //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Gap(152),
                Column(
                  children: [
                    Text(
                      "Esqueci minha senha",
                      style: AppTextStyle.mobileDisplayLarge(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 1.w,
                    ),
                    Text(
                      "Preencha os campos abaixo para cadastrar sua nova senha:",
                      style: AppTextStyle.mobileDisplayMedium(context),
                    ),
                  ],
                ),
                  const Gap(32),
                Column(
                  children: [
                    TextFormFieldWidget(
                      label: "Token",
                      validator: isNotEmpity,
                      onSaved: (e) => token = e,
                    ),
                    const SizedBox(height: 16),
                    TextFormFieldWidget(
                      label: "Nova senha",
                      validator: isNotEmpity,
                      obscure: true,
                      onSaved: (e) => password = e,
                    ),
                    const SizedBox(height: 16),
                    TextFormFieldWidget(
                      label: "Confirmar senha",
                      obscure: true,
                      validator: (e) {
                        if (e?.compareTo(password) != 0) {
                          return 'Senha inválida';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                  const Gap(48),
                Column(
                  children: [
                    Obx(() {
                      return ButtomWidget(
                        title: 'Confirmar',
                        radius: 10,
                        isLoading: simple.get<PasswordRecoveryViewModel>().appState.value is AppStateLoading,
                        onTap: () async {
                          formState.currentState!.save();
                          if (formState.currentState!.validate()) {
                            onConfirm(password, token);
                          }
                        },
                      );
                    }),
                    SizedBox(
                      height: 2.w,
                    ),
                    TextButton(
                      onPressed: () {
                        onPrevious();
                      },
                      child: Text(
                        'Voltar para a etapa anterior',
                        style: AppTextStyle.mobileDisplayMedium(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class SucessRecoveryPasswordWidget extends StatelessWidget {
  const SucessRecoveryPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, snap) {
      final width = snap.maxWidth;
      final height = snap.maxHeight;

      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Senha cadastrada com sucesso!!!",
            style: AppTextStyle.mobileDisplayLarge(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(
            LineIcons.checkCircle,
            size: height * .20,
            color: context.appTheme.greenColor,
          ),
          SizedBox(
            width: width * .40,
            child: ButtomWidget(
              title: 'Voltar',
              radius: 10,
              onTap: () {
                GoTo.removeAllPreviousAndGoTo(Routes.auth);
              },
            ),
          ),
        ],
      );
    });
  }
}
