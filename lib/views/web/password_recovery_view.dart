import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/consts/routes.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/mixins/validators_mixin.dart';
import 'package:martinlog_web/navigator/go_to.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/password_recovery_view_model.dart';
import 'package:martinlog_web/widgets/buttom_widget.dart';
import 'package:martinlog_web/widgets/text_form_field_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PassswordRecoveryView extends StatefulWidget {
  const PassswordRecoveryView({super.key});

  @override
  State<PassswordRecoveryView> createState() => _PassswordRecoveryViewState();
}

class _PassswordRecoveryViewState extends State<PassswordRecoveryView>
    with ValidatorsMixin {
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
          BannerComponent(
              message: state.msg ?? "Ocorreu um erro",
              backgroundColor: Colors.red);
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
      body: Center(
        child: Container(
          width: 70.w,
          height: 70.h,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white),
          child: PageView(
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
        ),
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
      final width = snap.maxWidth;
      return Form(
        key: formState,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  "Esqueci minha senha",
                  style: AppTextStyle.displayLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 1.w,
                ),
                Text(
                  "Informe o cpf do seu usuário",
                  style: AppTextStyle.displayMedium(context),
                ),
              ],
            ),
            SizedBox(
              width: width * .40,
              child: TextFormFieldWidget(
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
            ),
            Column(
              children: [
                SizedBox(
                  width: width * .40,
                  child: Obx(() {
                    return ButtomWidget(
                      title: 'Avançar',
                      radius: 10,
                      isLoading: simple
                          .get<PasswordRecoveryViewModel>()
                          .appState
                          .value is AppStateLoading,
                      onTap: () async {
                        if (formState.currentState!.validate()) {
                          formState.currentState!.save();
                        }
                      },
                    );
                  }),
                ),
                SizedBox(
                  height: 2.w,
                ),
                TextButton(
                  onPressed: GoTo.pop,
                  child: Text(
                    'Voltar para o login',
                    style: AppTextStyle.displayMedium(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ignore: must_be_immutable
class CompleteRecoveryPasswordWidget extends StatelessWidget
    with ValidatorsMixin {
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
      final width = snap.maxWidth;
      return Form(
        key: formState,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  "Esqueci minha senha",
                  style: AppTextStyle.displayLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 1.w,
                ),
                Text(
                  "Preencha os campos abaixo para cadastrar sua nova senha:",
                  style: AppTextStyle.displayMedium(context),
                ),
              ],
            ),
            SizedBox(
              width: width * .40,
              child: Column(
                children: [
                  TextFormFieldWidget(
                    label: "Token",
                    validator: isNotEmpity,
                    onSaved: (e) => token = e,
                  ),
                  SizedBox(
                    height: 1.w,
                  ),
                  TextFormFieldWidget(
                    label: "Nova senha",
                    validator: isNotEmpity,
                    obscure: true,
                    onSaved: (e) => password = e,
                  ),
                  SizedBox(
                    height: 1.w,
                  ),
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
            ),
            Column(
              children: [
                SizedBox(
                  width: width * .40,
                  child: Obx(() {
                    return ButtomWidget(
                      title: 'Confirmar',
                      radius: 10,
                      isLoading: simple
                          .get<PasswordRecoveryViewModel>()
                          .appState
                          .value is AppStateLoading,
                      onTap: () async {
                        formState.currentState!.save();
                        if (formState.currentState!.validate()) {
                          onConfirm(password, token);
                        }
                      },
                    );
                  }),
                ),
                SizedBox(
                  height: 2.w,
                ),
                TextButton(
                  onPressed: () {
                    onPrevious();
                  },
                  child: Text(
                    'Voltar para a etapa anterior',
                    style: AppTextStyle.displayMedium(context),
                  ),
                ),
              ],
            ),
          ],
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
            style: AppTextStyle.displayLarge(context).copyWith(
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
