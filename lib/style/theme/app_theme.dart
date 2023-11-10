import 'package:flutter/material.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';

@immutable
class AppThemeData {
  final Color primaryColor;
  final Color primaryVariant;
  final Color secondColor;
  final Color greenColor;
  final Color backgroundColor;
  final Color iconColor;
  final Color buttonEnableColor;
  final Color buttonDisableColor;
  final Color disableColor;
  final Color hintFieldColor;
  final Color borderColor;
  final Color titleColor;
  final Color greyColor;
  final Color redColor;
  final String? fontFamily;
  final TextStyle? appBarTextStyle;
  final TextTheme? textTheme;

  AppThemeData({
    required this.primaryColor,
    required this.primaryVariant,
    required this.secondColor,
    required this.greenColor,
    required this.backgroundColor,
    required this.iconColor,
    required this.buttonEnableColor,
    required this.buttonDisableColor,
    required this.disableColor,
    required this.hintFieldColor,
    required this.borderColor,
    required this.titleColor,
    required this.greyColor,
    required this.redColor,
    this.fontFamily,
    this.appBarTextStyle,
    this.textTheme,
  });

  late final theme = ThemeData(
    fontFamily: fontFamily,
    primaryColor: primaryColor,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: primaryColor,
      selectionHandleColor: primaryColor,
    ),
    appBarTheme: AppBarTheme(
      color: primaryColor,
      centerTitle: false,
      elevation: 8.0,
      titleTextStyle: appBarTextStyle,
    ),
    iconTheme: IconThemeData(
      color: iconColor,
    ),
    extensions: <ThemeExtension<dynamic>>[
      AppTheme(
        primaryColor: primaryColor,
        primaryVariant: primaryVariant,
        greenColor: greenColor,
        secondColor: secondColor,
        backgroundColor: backgroundColor,
        disableColor: disableColor,
        borderColor: borderColor,
        buttonEnableColor: buttonEnableColor,
        hintFieldColor: hintFieldColor,
        linearGradientBackground: LinearGradient(
          colors: [
            primaryColor,
            primaryVariant,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          tileMode: TileMode.mirror,
          stops: const [
            0.75,
            0.90,
          ],
        ),
        linearGradientButtonEnable: LinearGradient(
          colors: [
            secondColor,
            primaryColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          tileMode: TileMode.mirror,
          stops: const [
            0.05,
            0.55,
            0.75,
          ],
        ),
        appBarVariantTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
    ],
    textTheme: textTheme,
  );
}

@immutable
class AppTheme extends ThemeExtension<AppTheme> {
  final Color primaryVariant;
  final Color primaryColor;
  final Color secondColor;
  final Color greenColor;
  final Color buttonEnableColor;
  final Color buttonDisableColor;
  final Color backgroundColor;
  final Color disableColor;
  final Color hintFieldColor;
  final Color borderColor;
  final Color titleColor;
  final Color snackBarTextColor;
  final Color greyColor;
  final Color redColor;
  final LinearGradient linearGradientBackground;
  final LinearGradient linearGradientButtonEnable;
  final LinearGradient linearGradientButtonDisable;
  final LinearGradient linearGradientGreyColor;
  final LinearGradient circularGradient;
  final AppBarTheme appBarVariantTheme;
  AppTheme({
    required this.primaryColor,
    required this.primaryVariant,
    required this.secondColor,
    required this.greenColor,
    this.backgroundColor = Colors.white,
    required this.buttonEnableColor,
    Color? buttonDisableColor,
    required this.disableColor,
    required this.hintFieldColor,
    required this.borderColor,
    Color? titleColor,
    Color? snackBarTextColor,
    Color? greyColor,
    Color? redColor,
    required this.linearGradientBackground,
    required this.linearGradientButtonEnable,
    LinearGradient? linearGradientButtonDisable,
    LinearGradient? linearGradientGreyColor,
    required this.appBarVariantTheme,
  })  : linearGradientButtonDisable = linearGradientButtonDisable ??
            const LinearGradient(
              colors: [
                Color.fromARGB(255, 206, 204, 204),
                Color.fromARGB(255, 206, 204, 204),
                Colors.grey,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
        linearGradientGreyColor = linearGradientGreyColor ??
            LinearGradient(
              colors: [
                Colors.white,
                Colors.white,
                Colors.grey[100]!,
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
        titleColor = titleColor ?? const Color(0xFF0F1B2D),
        snackBarTextColor = snackBarTextColor ?? Colors.white,
        greyColor = greyColor ?? Colors.grey.shade400,
        buttonDisableColor = buttonDisableColor ?? Colors.grey.shade400,
        redColor = redColor ?? Colors.red.shade600,
        circularGradient = LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            primaryVariant,
            primaryColor,
            secondColor,
          ],
          stops: const [
            0.25,
            0.65,
            0.95,
          ],
          tileMode: TileMode.mirror,
        );

  @override
  ThemeExtension<AppTheme> copyWith({
    Color? primaryColor,
    Color? primaryVariant,
    Color? secondColor,
    Color? greenColor,
    Color? buttonEnableColor,
    Color? buttonDisableColor,
    Color? backgroundColor,
    Color? disableColor,
    Color? hintFieldColor,
    Color? borderColor,
    Color? titleColor,
    Color? snackBarTextColor,
    Color? greyColor,
    Color? redColor,
    LinearGradient? linearGradientBackground,
    LinearGradient? linearGradientButtonEnable,
    LinearGradient? linearGradientButtonDisable,
    LinearGradient? linearGradientGreyColor,
    AppBarTheme? appBarVariantTheme,
  }) {
    return AppTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      primaryVariant: primaryVariant ?? this.primaryVariant,
      secondColor: secondColor ?? this.secondColor,
      greenColor: greenColor ?? this.greenColor,
      buttonEnableColor: buttonEnableColor ?? this.buttonEnableColor,
      buttonDisableColor: buttonDisableColor ?? this.buttonDisableColor,
      disableColor: disableColor ?? this.disableColor,
      greyColor: greyColor ?? this.greyColor,
      titleColor: titleColor ?? this.titleColor,
      snackBarTextColor: snackBarTextColor ?? this.snackBarTextColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      redColor: redColor ?? this.redColor,
      hintFieldColor: hintFieldColor ?? this.hintFieldColor,
      borderColor: borderColor ?? this.borderColor,
      linearGradientBackground:
          linearGradientBackground ?? this.linearGradientBackground,
      linearGradientButtonEnable:
          linearGradientButtonEnable ?? this.linearGradientButtonEnable,
      linearGradientButtonDisable:
          linearGradientButtonDisable ?? this.linearGradientButtonDisable,
      linearGradientGreyColor:
          linearGradientGreyColor ?? this.linearGradientGreyColor,
      appBarVariantTheme: appBarVariantTheme ?? this.appBarVariantTheme,
    );
  }

  @override
  ThemeExtension<AppTheme> lerp(ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) {
      return this;
    }
    return AppTheme(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      primaryVariant: Color.lerp(primaryVariant, other.primaryVariant, t)!,
      secondColor: Color.lerp(secondColor, other.secondColor, t)!,
      greenColor: Color.lerp(greenColor, other.greenColor, t)!,
      buttonEnableColor:
          Color.lerp(buttonEnableColor, other.buttonEnableColor, t)!,
      buttonDisableColor:
          Color.lerp(buttonDisableColor, other.buttonDisableColor, t)!,
      disableColor: Color.lerp(disableColor, other.disableColor, t)!,
      greyColor: Color.lerp(greyColor, other.greyColor, t)!,
      titleColor: Color.lerp(titleColor, other.titleColor, t)!,
      redColor: Color.lerp(redColor, other.redColor, t)!,
      hintFieldColor: Color.lerp(hintFieldColor, other.hintFieldColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      snackBarTextColor:
          Color.lerp(snackBarTextColor, other.snackBarTextColor, t)!,
      linearGradientBackground: LinearGradient.lerp(
          linearGradientBackground, other.linearGradientBackground, t)!,
      linearGradientButtonEnable: LinearGradient.lerp(
          linearGradientButtonEnable, other.linearGradientButtonEnable, t)!,
      linearGradientButtonDisable: LinearGradient.lerp(
          linearGradientButtonDisable, other.linearGradientButtonDisable, t)!,
      linearGradientGreyColor: LinearGradient.lerp(
          linearGradientGreyColor, other.linearGradientGreyColor, t)!,
      appBarVariantTheme:
          AppBarTheme.lerp(appBarVariantTheme, other.appBarVariantTheme, t),
    );
  }
}
