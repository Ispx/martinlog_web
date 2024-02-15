import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';

import '../style/text/app_text_style.dart';

class ButtomWidget extends StatelessWidget {
  final String? title;
  final VoidCallback? onTap;
  final bool? isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? radius;
  final double? elevation;

  final bool? bottomSafeArea;
  final Widget? trainling;

  const ButtomWidget({
    super.key,
    required this.title,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.bottomSafeArea = false,
    this.isLoading = false,
    this.trainling,
    this.radius = 0,
    this.elevation,
  });
  @override
  Widget build(BuildContext context) {
    final digitalAccountTheme = context.appTheme;
    final buttomEnableColor =
        backgroundColor ?? digitalAccountTheme.buttonEnableColor;
    return Material(
      elevation: elevation ?? 6.0,
      borderRadius: BorderRadius.circular(radius!),
      type: MaterialType.button,
      color: (isLoading ?? false)
          ? digitalAccountTheme.buttonDisableColor
          : onTap != null
              ? buttomEnableColor
              : digitalAccountTheme.buttonDisableColor,
      child: InkWell(
        radius: radius!,
        splashColor: digitalAccountTheme.greenColor,
        borderRadius: BorderRadius.circular(
          radius!,
        ),
        onTap: onTap != null ? () => onTap!() : null,
        child: SafeArea(
          bottom: bottomSafeArea ?? false,
          top: false,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                radius!,
              ),
            ),
            constraints: const BoxConstraints(maxHeight: 55),
            child: isLoading == true
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      title!,
                      style: kIsWeb ? AppTextStyle.displayMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor ?? digitalAccountTheme.titleColor,
                      ) : AppTextStyle.mobileDisplayMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor ?? digitalAccountTheme.titleColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
