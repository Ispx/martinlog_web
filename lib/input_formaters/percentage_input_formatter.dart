import 'package:flutter/services.dart';

class PercentageInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset < oldValue.selection.baseOffset) {
      return newValue.copyWith(
        text: newValue.text,
        selection: TextSelection.fromPosition(
          TextPosition(offset: newValue.text.length),
        ),
      );
    }
    var value = RegExp(r'[0-9]')
        .allMatches(newValue.text)
        .map((e) => e[0])
        .join()
        .toString();

    value = value.isEmpty ? '' : "$value%";
    return newValue.copyWith(
      text: value,
      selection: TextSelection.fromPosition(TextPosition(offset: value.length)),
    );
  }
}
