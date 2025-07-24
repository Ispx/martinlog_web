import 'package:flutter/services.dart';

class LiscensePlateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    RegExp prefixExp = RegExp(r'[A-Z]{1}|[A-Z]{2}|[A-Z]{3}');

    var prefixText = newValue.text.split('-').firstOrNull ?? newValue.text;
    var sufixText = newValue.text.split('-').lastOrNull ?? '';
    if (newValue.text.length > 7) {
      newValue = newValue.copyWith(
        text: newValue.text.replaceAll('-', ''),
        selection: TextSelection.collapsed(offset: newValue.text.length),
      );
    }
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    if (newValue.selection.baseOffset < oldValue.selection.baseOffset) {
      return newValue.copyWith(
        text: newValue.text,
        selection: TextSelection.collapsed(offset: newValue.text.length),
      );
    }

    if (newValue.text.length <= 3) {
      if (prefixExp.allMatches(prefixText).length == prefixText.length) {
        return newValue.copyWith(
          text: prefixText,
          selection: TextSelection.fromPosition(
            TextPosition(
              offset: prefixText.length,
            ),
          ),
        );
      } else {
        return oldValue;
      }
    } else if (prefixText.length == 4) {
      if (RegExp(r'[0-9]').hasMatch(prefixText[prefixText.length - 1])) {
        return newValue;
      }
      return newValue;
    } else if (prefixText.length == 5) {
      if (RegExp(r'[0-9]').hasMatch(sufixText[sufixText.length - 1])) {
        prefixText = newValue.text.substring(0, 3);
        sufixText = newValue.text.substring(3);
        var newText = '$prefixText-$sufixText';
        return newValue.copyWith(
          text: newText,
          selection: TextSelection.fromPosition(
            TextPosition(
              offset: newText.length,
            ),
          ),
        );
      } else if (RegExp(r'[A-Z]').hasMatch(sufixText[sufixText.length - 1])) {
        return newValue;
      } else {
        return oldValue;
      }
    } else {
      if (RegExp(r'[0-9]').hasMatch(newValue.text[newValue.text.length - 1])) {
        return newValue;
      }
      return oldValue;
    }
  }
}
