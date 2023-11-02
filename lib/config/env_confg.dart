import 'dart:io';

import 'package:martinlog_web/extensions/string_extension.dart';

abstract interface class EnvConfig {
  Future<void> read(String path);
}

final class EnvConfigImp implements EnvConfig {
  static final EnvConfigImp _i = EnvConfigImp._();
  EnvConfigImp._();
  factory EnvConfigImp() => _i;
  String get urlBase => _getValue<String>("URL_BASE");

  var _data = {};
  T _getValue<T>(String key) => _data[key].toString().parseToType<T>();
  @override
  Future<void> read(String path) async {
    try {
      final fileEnv = File(path);
      var rows = await fileEnv.readAsLines();
      _data = {for (var row in rows) row.split("=").first: row.split("=").last};
    } catch (e) {
      rethrow;
    }
  }
}
