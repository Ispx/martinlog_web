import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';

class IconButtonWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;
  final Icon icon;
  final double radius;
  final Color? buttomColor;
  const IconButtonWidget({
    super.key,
    required this.icon,
    required this.onTap,
    required this.title,
    this.radius = 10,
    this.buttomColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: onTap == null
              ? context.appTheme.disableColor
              : buttomColor ?? context.appTheme.buttonEnableColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppSize.padding,
            horizontal: AppSize.padding * 1.5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                title,
                style: kIsWeb
                    ? AppTextStyle.displayMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.appTheme.titleColor,
                      )
                    : AppTextStyle.mobileDisplayMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.appTheme.titleColor,
                      ),
              ),
              icon
            ],
          ),
        ),
      ),
    );
  }
}
