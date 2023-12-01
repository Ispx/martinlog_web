import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';

class TextFormFieldWidget<T extends InputBorder> extends StatelessWidget {
  final String? Function(String?)? validator;
  final String? Function(String?)? submited;
  final Function(String e)? onChange;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final VoidCallback? onTap;
  final bool? enable;
  final bool? autofocus;
  final bool? obscure;
  final int? maxLength;
  final OverlayVisibilityMode? prefixMode;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? sufix;
  final String? prefixText;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final void Function(String value)? onSaved;
  final String? initialValue;
  final String? helpText;
  final TextAlign? textAlign;
  final int? minLines;
  final int? maxLines;
  final String? counterText;
  final Color? fillColor;

  const TextFormFieldWidget({
    super.key,
    this.initialValue,
    this.fillColor,
    this.label = '',
    this.autofocus = false,
    this.controller,
    this.enable = true,
    this.maxLength,
    this.focusNode,
    this.hint,
    this.prefixMode = OverlayVisibilityMode.editing,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.keyboardType,
    this.obscure = false,
    this.prefixText,
    this.onChange,
    this.onTap,
    this.submited,
    this.sufix,
    this.textInputAction,
    this.validator,
    this.onSaved,
    this.helpText,
    this.textAlign,
    this.minLines,
    this.maxLines,
    this.counterText = '',
  });

  @override
  Widget build(BuildContext context) {
    final digitalAccountTheme = context.appTheme;

    return TextFormField(
      initialValue: initialValue,
      validator: (e) {
        if (validator == null) return null;
        return validator!(e);
      },
      onSaved: (value) => onSaved?.call(value ?? ''),
      textAlign: textAlign ?? TextAlign.start,
      autofocus: autofocus ?? false,
      keyboardType: keyboardType,
      cursorColor: Theme.of(context).primaryColor,
      controller: controller,
      obscureText: obscure ?? false,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      onTap: onTap,
      focusNode: focusNode,
      textInputAction: textInputAction,
      enabled: enable,
      onFieldSubmitted: submited,
      inputFormatters: inputFormatters,
      style: AppTextStyle.displayMedium(context).copyWith(
        fontWeight: FontWeight.bold,
      ),
      onChanged: onChange,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor ?? Colors.white,
        helperText: helpText,
        counterText: counterText,
        errorStyle: const TextStyle(
          color: Colors.red,
        ),
        labelText: label,
        prefixStyle: AppTextStyle.displayMedium(context).copyWith(
          fontWeight: FontWeight.bold,
        ),
        labelStyle: AppTextStyle.displayMedium(context).copyWith(
          fontWeight: FontWeight.bold,
        ),
        prefixText: prefixText,
        hintText: hint,
        hintStyle: AppTextStyle.displayMedium(context).copyWith(
          fontWeight: FontWeight.bold,
          color: digitalAccountTheme.hintFieldColor,
        ),
        suffixIcon: sufix != null
            ? Padding(
                padding: EdgeInsets.all(AppSize.padding),
                child: sufix,
              )
            : sufix,
        enabledBorder: T == null
            ? InputBorder.none
            : T == OutlineInputBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      width: 0.5,
                      color: digitalAccountTheme.borderColor,
                    ),
                  )
                : UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 0.5,
                      color: digitalAccountTheme.borderColor,
                    ),
                  ),
        disabledBorder: T == null
            ? InputBorder.none
            : T == OutlineInputBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      width: 0.5,
                      color: digitalAccountTheme.borderColor.withOpacity(0.5),
                    ),
                  )
                : UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 0.5,
                      color: digitalAccountTheme.borderColor.withOpacity(0.5),
                    ),
                  ),
        border: T == null
            ? UnderlineInputBorder(
                borderSide: BorderSide(
                    width: 1, color: digitalAccountTheme.borderColor),
              )
            : T == OutlineInputBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      width: 0.5,
                      color: digitalAccountTheme.borderColor,
                    ),
                  )
                : UnderlineInputBorder(
                    borderSide: BorderSide(
                        width: 0.5, color: digitalAccountTheme.borderColor),
                  ),
        focusedBorder: T == null
            ? InputBorder.none
            : T == OutlineInputBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      width: 0.5,
                      color: digitalAccountTheme.borderColor,
                    ),
                  )
                : UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 0.5,
                      color: digitalAccountTheme.borderColor,
                    ),
                  ),
        errorBorder: T == null
            ? InputBorder.none
            : T == OutlineInputBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      width: 0.5,
                      color: digitalAccountTheme.redColor,
                    ),
                  )
                : UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 0.5,
                      color: digitalAccountTheme.redColor,
                    ),
                  ),
      ),
    );
  }
}
