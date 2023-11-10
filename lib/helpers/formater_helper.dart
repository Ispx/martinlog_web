import 'package:intl/intl.dart';
import 'package:martinlog_web/utils/utils.dart';

abstract class FormaterHelper {
  static String cpfOrCPNJ(String value, {bool autoCorrection = true}) {
    var valueClear =
        value.replaceAll('.', '').replaceAll('/', '').replaceAll('-', '');
    switch (valueClear.length) {
      case 14:
        return cnpj(value, autoCorrection: autoCorrection);
      case 11:
        return cpf(value, autoCorrection: autoCorrection);
      default:
        return value;
    }
  }

  static String real(double amount) => NumberFormat.simpleCurrency(
        locale: "pt_br",
        name: '',
      ).format(amount).trimLeft();

  static String telephone(String value) {
    try {
      value = Utils.clearMaskTelephone(value);
      if (value.length < 11) return value;
      value = value[0] == '0' ? value.substring(1) : value;
      value =
          value.substring(0, 3) == '550' ? "55${value.substring(3)}" : value;
      if (value.length == 11 && value[2] == '9') {
        return "(${value.substring(0, 2)}) ${value.substring(2, 7)}-${value.substring(7)}";
      } else if (value.length == 13 &&
          value.substring(0, 2) == '55' &&
          value[4] == '9') {
        return "+${value.substring(0, 2)} (${value.substring(2, 4)}) ${value.substring(4, 9)}-${value.substring(9)}";
      } else if (value.length == 14 &&
          value.substring(0, 2) == '55' &&
          value[3] == '0' &&
          value[5] == '9') {
        return "+${value.substring(0, 2)} (${value.substring(2, 4)}) ${value.substring(4, 9)}-${value.substring(9)}";
      }
      return value;
    } catch (e) {
      return value;
    }
  }

  static String cnpj(String value, {bool autoCorrection = true}) {
    try {
      var newValue = Utils.clearMaskDocument(value);
      if (newValue.length < 14) {
        if (newValue.length == 13 && autoCorrection) {
          newValue = '0' + newValue;
        } else {
          return value;
        }
      }
      var values = newValue.split('');
      String formated = '';
      // ##.###.###/####-##
      for (int i = 0; i < values.length; i++) {
        formated += values[i];
        if (i == 1 || i == 4) {
          formated += '.';
        } else if (i == 7) {
          formated += '/';
        } else if (i == 11) {
          formated += '-';
        }
      }
      return formated;
    } catch (e) {
      return value;
    }
  }

  static String cpf(String value, {bool autoCorrection = true}) {
    try {
      var newValue = Utils.clearMaskDocument(value);
      if (newValue.length < 11) {
        if (newValue.length == 10 && autoCorrection) {
          newValue = '0' + newValue;
        } else {
          return value;
        }
      }
      var values = newValue.split('');
      String formated = '';
      for (int i = 0; i < values.length; i++) {
        formated += values[i];
        if (i == 2 || i == 5) {
          formated += '.';
        }
        if (i == 8) {
          formated += '-';
        }
      }
      return formated;
    } catch (e) {
      return value;
    }
  }
}
