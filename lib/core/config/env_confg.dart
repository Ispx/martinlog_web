import 'dart:io';

import 'package:martinlog_web/extensions/string_extension.dart';

abstract interface class IEnvConfig {
  Future<void> read(String path);
}

final class EnvConfig implements IEnvConfig {
  static final EnvConfig _i = EnvConfig._();
  EnvConfig._();
  factory EnvConfig() => _i;
  String get urlBase => _getValue<String>("URL_BASE");
  String get environment => _getValue<String>("ENVIRONMENT");

  var _data = {};
  T _getValue<T>(String key) => _data[key].toString().parseToType<T>();
  @override
  Future<void> read(String? env) async {
    try {
      String? path = env == "PROD" ? ".env_prod" : ".env_dev";
      final fileEnv = File(path);
      var rows = await fileEnv.readAsLines();
      _data = {for (var row in rows) row.split("=").first: row.split("=").last};
    } catch (e) {
      rethrow;
    }
  }
}
