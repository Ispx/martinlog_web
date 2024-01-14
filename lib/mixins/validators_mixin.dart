import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:martinlog_web/helpers/formater_helper.dart';
import 'package:martinlog_web/utils/utils.dart';

mixin ValidatorsMixin {
  String? isNotLiscensePlate(String? value, [String? message]) {
    if (!Utils.isLiscensePlate(value ?? '')) {
      return message ?? 'Placa inválida';
    }
    return null;
  }

  String? isNotEmpity(String? value, [String? message]) {
    if ((value?.isEmpty ?? true)) {
      return message ?? 'Campo não pode estar em branco';
    }
    return null;
  }

  String? isNotCPFOrCNPJ(String? value, [String? message]) {
    value = FormaterHelper.cpfOrCPNJ(value ?? '');
    if (GetUtils.isCpf(value) == false && GetUtils.isCnpj(value) == false) {
      return message ?? 'CPF ou CNPJ inválido';
    }
    return null;
  }

  String? isNotCNPJ(String? value, [String? message]) {
    value = FormaterHelper.cnpj(value ?? '');
    if (GetUtils.isCnpj(value) == false) {
      return message ?? 'CNPJ inválido';
    }
    return null;
  }

  String? isNotCPF(String? value, [String? message]) {
    value = FormaterHelper.cpf(value ?? '');
    if (GetUtils.isCpf(value) == false) {
      return message ?? 'CPF inválido';
    }
    return null;
  }

  String? hasFourChars(String? value, [String? message]) {
    if ((value?.length ?? 0) < 4) {
      return message ?? 'Tem que ter 4 caracteres';
    }
    return null;
  }

  String? hasSixChars(String? value, [String? message]) {
    if ((value?.length ?? 0) < 6) {
      return message ?? 'Tem que ter 6 caracteres';
    }
    return null;
  }

  String? isNotFullName(String? value, [String? message]) {
    if (value?.split(' ').length == 1) {
      return message ?? 'Informe o nome completo do titular';
    }
    return null;
  }

  String? isNotEmail(String? value, [String? message]) {
    if (!(value?.contains('@') ?? false)) {
      return message ?? 'Informe o nome completo do titular';
    }
    return null;
  }

  String? onCombine(List<String? Function()> validators) {
    for (var function in validators) {
      final validator = function();
      if (validator != null) return validator;
      return null;
    }
    return null;
  }
}
