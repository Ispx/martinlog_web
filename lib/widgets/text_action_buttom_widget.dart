import 'package:flutter/material.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';

class TextActionButtomWidget extends StatelessWidget {
  final String title;
  final VoidCallback onAction;
  final Color? backgroundColor;
  final bool isLoading;
  final bool isEnable;
  final Color? titleColor;
  final EdgeInsets? padding;
  const TextActionButtomWidget({
    super.key,
    required this.title,
    required this.onAction,
    this.padding,
    this.isLoading = false,
    this.isEnable = true,
    this.backgroundColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading || !isEnable ? null : () => onAction(),
      style: ButtonStyle(
        shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
          (states) => RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        backgroundColor: MaterialStateProperty.resolveWith(
          (states) => isLoading || !isEnable
              ? Colors.grey
              : backgroundColor ?? Colors.transparent,
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(4),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              )
            : Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.displayMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? Colors.white,
                ),
              ),
      ),
    );
  }
}
