import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/widgets/buttom_widget.dart';
import 'package:martinlog_web/widgets/text_form_field_widget.dart';
import 'package:scaffold_responsive/scaffold_responsive.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  late final ResponsiveMenuController menuController;

  @override
  void initState() {
    menuController = ResponsiveMenuController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
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
                    "Plataforma Martin log",
                    style: AppTextStyle.displayLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(30),
                  Expanded(
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
                        const TextFormFieldWidget<OutlineInputBorder>(
                          label: "CPF",
                        ),
                        const Gap(20),
                        const TextFormFieldWidget<OutlineInputBorder>(
                          label: "Senha",
                        ),
                        const Gap(30),
                        ButtomWidget(
                          title: "Acessar",
                          radius: 10,
                          onTap: () {},
                        )
                      ],
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
