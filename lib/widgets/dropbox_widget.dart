import 'package:flutter/material.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DropBoxWidget<T> extends StatelessWidget {
  final TextEditingController controller;
  final bool enable;

  final List<DropdownMenuEntry<T>> dropdownMenuEntries;
  final Function(T?) onSelected;
  final double? width;
  final String? label;
  const DropBoxWidget({
    super.key,
    required this.controller,
    required this.dropdownMenuEntries,
    this.enable = true,
    this.width,
    required this.onSelected,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      controller: controller,
      enabled: enable,
      width: width ?? 10.w,
      label: label != null ? Text(label!) : null,
      onSelected: (value) => onSelected(value),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.white,
        filled: true,
        hintStyle: AppTextStyle.displayMedium(context).copyWith(
          fontWeight: FontWeight.bold,
        ),
        labelStyle: AppTextStyle.displayMedium(context).copyWith(
          fontWeight: FontWeight.bold,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            width: 0.5,
            color: context.appTheme.borderColor,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            width: 0.5,
            color: context.appTheme.borderColor.withOpacity(0.1),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            width: 0.5,
            color: context.appTheme.borderColor,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            width: 1,
            color: context.appTheme.redColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            width: 1,
            color: context.appTheme.borderColor,
          ),
        ),
      ),
      dropdownMenuEntries: dropdownMenuEntries,
    );
  }
}
