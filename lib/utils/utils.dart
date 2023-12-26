import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:martinlog_web/extensions/string_extension.dart';
import 'package:martinlog_web/helpers/formater_helper.dart';

abstract class Utils {
  static bool isCEP(String cep) {
    var value = cep.replaceAll(RegExp(r'[,./-\s]'), '');
    return value.length == '00000-000'.length;
  }

  static bool isLiscensePlate(String liscensePlate) => RegExp(
          r'[A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9]|[A-Z][A-Z][A-Z][0-9][0-9A-Z][0-9][0-9]')
      .hasMatch(liscensePlate);

  static bool isDocument(String document) => RegExp(
          r'(^\d{3}\.\d{3}\.\d{3}\-\d{2}$)|(^\d{2}\.\d{3}\.\d{3}\/\d{4}\-\d{2}$)')
      .hasMatch(document);
  static bool isEmail(String source) => RegExp(
          r'^[a-zA-Z0-9.!#$%&’*+=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$')
      .hasMatch(source);
  static bool isCPF(String source) => RegExp(r'(^\d{3}\.\d{3}\.\d{3}\-\d{2}$)')
      .hasMatch(FormaterHelper.cpf(source));
  static bool isQrCodePix(String barcode) {
    return barcode.toUpperCase().contains("BR.GOV.BCB.PIX");
  }

  static bool isValidDate(String exp) {
    try {
      var values = exp.split(RegExp(r'[\s]'));
      var date = values.first.split(RegExp(r'[/-]'));
      var year = date.length == 4 ? date.first : date.last;
      var month = date[1];
      var day = date.first.length == 4 ? date.last : date.first;
      final dateTime = DateTime.tryParse("$year-$month-$day");
      return dateTime!.year.compareTo(int.parse(year)) == 0 &&
          dateTime.month.compareTo(int.parse(month)) == 0 &&
          dateTime.day.compareTo(int.parse(day)) == 0;
    } catch (e) {
      return false;
    }
  }

  static Color color(String hex) {
    return Color(hex.replaceAll("#", "0xFF").parseToType<int>());
  }

  static bool containsChar(String source) =>
      RegExp(r'[a-zA-Z!@#$%^&*()_+\-=\[\]{};:\\|,.<>\/?]').hasMatch(source);

  static bool isBarcode(String barcode) {
    barcode = clearMaskBarcode(barcode);
    try {
      if (barcode.length >= 30) return true;

      return RegExp(r'\d{5}\d{5}\d{5}\d{6}\d{5}\d{6}\d\d{14}')
          .hasMatch(barcode);
    } catch (e) {
      return false;
    }
  }

  @visibleForTesting
  static bool isPasswordNotContainsSixNumbers(String password) {
    final onlyNumbers = RegExp(r'^[0-9]{6}$');
    return !onlyNumbers.hasMatch(password);
  }

  // Verifica se em 3 dígitos em sequência contém no CNPJ/CPF.
  @visibleForTesting
  static bool isPasswordContainsDocument({
    required String password,
    required String document,
  }) {
    for (int startIndex = 0, endIndex = 3;
        endIndex <= password.length;
        startIndex++, endIndex++) {
      final values = password.substring(startIndex, endIndex);
      if (document.contains(values)) {
        return true;
      }
    }
    return false;
  }

  // Analisa a senha por grupos(unidade, dezena, centena...).
  // Verifica se há repetição ou se há uma sequência.
  // Exemplo: 1|2|3|4|5|6 - 12|13|14
  static bool isPasswordSequentialOrRepetition(String password) {
    assert(password.length.isEven, 'tamanho da senha deve ser um número par');
    final valuesInUnity = _generateSplitPassword(password).toList();
    final valuesInDecimal =
        _generateSplitPassword(password, isDecimal: true).toList();
    if (isPasswordDecimalSequential(values: valuesInDecimal)) return true;
    for (int index = 0; index <= password.length ~/ 2; index++) {
      if (_isPasswordUnitySequentialOrRepetition(
        values: valuesInUnity,
        currentIndex: index,
      )) return true;
    }
    return false;
  }

  static Iterable<int> _generateSplitPassword(String password,
      {bool isDecimal = false}) sync* {
    final passwordSize = password.length;
    final groupIndex = passwordSize ~/ 2;
    final values = password.split('');
    if (!isDecimal) {
      for (var value in values) {
        yield int.parse(value);
      }
      return;
    }
    for (int i = 0; i <= groupIndex + 1; i += isDecimal ? 2 : 1) {
      final result = values.sublist(i, i + (isDecimal ? 2 : 1)).join('');

      yield int.parse(result);
    }
  }

  static bool _isPasswordUnitySequentialOrRepetition(
      {required List<int> values, required int currentIndex}) {
    int endIndex = currentIndex + values.length ~/ 2;
    var split = values.sublist(currentIndex, endIndex);
    int previousValue = split.first;
    int currentValue = split[1];
    int nextValue = split.last;
    bool isSequential = (currentValue - previousValue) == 1 &&
        (currentValue - nextValue).abs() == 1 &&
        nextValue > currentValue;
    bool isRepetition = (currentValue - previousValue).abs() == 0 &&
        (currentValue - nextValue).abs() == 0;
    return isSequential || isRepetition;
  }

  static bool isPasswordDecimalSequential({
    required List<int> values,
  }) {
    int firstValue = values.first;
    int secondValue = values[1];
    int lastValue = values.last;
    var absRef = (firstValue - secondValue).abs();
    bool isSequential = (secondValue - lastValue).abs() == absRef;
    return isSequential;
  }

  static List<Widget> getWidgetsByPage({
    required int totalByPage,
    required int currentIndexPage,
    required List<Widget> widgets,
  }) {
    try {
      int totalPages = widgets.length ~/ totalByPage +
          (widgets.length % totalByPage > 0 ? 1 : 0);
      int startIndex = currentIndexPage * totalByPage;
      int? lastIndex = currentIndexPage == totalPages - 1
          ? null
          : (currentIndexPage * totalByPage) + totalByPage;
      return widgets.sublist(startIndex, lastIndex);
    } catch (e) {
      return [];
    }
  }

  static String resolveDocumentTypeMask(String source) =>
      source.replaceAll(RegExp(r'[)()}{,.^?~=+\-_\/\-+.\|\s]'), '').length <= 11
          ? 'CPF'
          : 'CNPJ';
  static bool isCNPJ(String source) =>
      RegExp(r'(^\d{2}\.\d{3}\.\d{3}\/\d{4}\-\d{2}$)')
          .hasMatch(FormaterHelper.cnpj(source));
  static bool isNumberPhone(
    String source,
  ) =>
      RegExp(r'^(?:(?:\+|00)?(55)\s?)?\((?:[14689][1-9]|2[12478]|3[1234578]|5[1345]|7[134579])\) (?:[2-8]|9[1-9])[0-9]{3}\-[0-9]{4}$')
          .hasMatch(source);

  static bool isName(String source) => RegExp(
          r"^(?![ ])(?!.*[ ]{2})((?:e|da|do|das|dos|de|d'|D'|la|las|el|los)\s*?|(?:[A-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð'][^\s]*\s*?)(?!.*[ ]$))+$")
      .hasMatch(source);
  static String clearMaskDocument(String document) =>
      document.replaceAll(RegExp(r'[}{,.^?~=+\-_\/*\-+.\|\s()]'), '');
  static String clearMaskTelephone(String value) =>
      value.replaceAll(RegExp(r'[)()}{,.^?~=+\-_\/*\-+.\|\s]'), '');

  static String transactionDate(DateTime dateTime) =>
      dateTime.day == DateTime.now().day &&
              dateTime.month == DateTime.now().month &&
              dateTime.year == DateTime.now().year
          ? 'Hoje'
          : ddMMMyyyy(dateTime);

  static String ddMMMyyyy(DateTime data) =>
      DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(data);
  static String longDate(DateTime dateTime) =>
      DateFormat("dd 'de' MMMM 'de' yyyy 'às' HH:mm:ss", 'pt_BR')
          .format(dateTime);
  static String yyyyMMdd(DateTime dateTime) =>
      DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime);

  static String shortDate(DateTime dateTime) =>
      DateFormat("dd MMM yyyy", 'pt_Br').format(dateTime);

  static DateTime fromServerToLocal(String value) {
    final date = DateTime.parse(value);
    final utcDate = DateTime.utc(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
    final localDate = utcDate.toLocal();
    return localDate;
  }

  static String maskDocument(String document) {
    document = document.replaceAll('.', '');
    document = document.replaceAll('-', '');
    document = document.replaceAll('/', '');
    if (document.length < 10) {
      return document;
    }
    if (document.length <= 11) {
      if (document.length == 10) {
        document = '0$document';
      }
      var splits = document.split('');
      return '***.${splits[3]}${splits[4]}${splits[5]}.${splits[6]}${splits[7]}${splits[8]}-**';
    } else if (document.length <= 14) {
      if (document.length == 13) {
        document = '0$document';
      }
      var splits = document.split('');
      return '${splits[0]}${splits[1]}.***.${splits[5]}${splits[6]}${splits[7]}/${splits[8]}${splits[9]}${splits[10]}${splits[11]}-**';
    } else {
      return document;
    }
  }

  static String maskEmail(String email) {
    String sub = email.substring(0, email.indexOf('@'));
    String mask = List.generate(sub.length - 2, (index) => '*')
        .toString()
        .replaceAll(',', '')
        .replaceAll(']', '')
        .replaceAll('[', '');
    return '${email[0]}$mask${sub[sub.length - 1]}${email.substring(email.indexOf('@'))}';
  }

  static String getInitials(String fullName) {
    if (fullName.trim().isEmpty) return '';
    List<String> split = fullName.trimLeft().trimRight().split(' ');
    if (split.length == 1) return split.first[0].toUpperCase();
    return "${split.first[0]}${split.last[0]}".toUpperCase();
  }

  static String clearMaskBarcode(String barcode) =>
      barcode.replaceAll(RegExp(r'[.\s]'), '');
}
