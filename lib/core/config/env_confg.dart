final class EnvConfig {
  static final EnvConfig _i = EnvConfig._();
  EnvConfig._();
  factory EnvConfig() => _i;
  static String get urlBase =>
      'http://192.168.100.96:8080'; //const String.fromEnvironment("URL_BASE");
  static String get appName =>
      'Plataforma Martin log'; //const String.fromEnvironment("APP_NAME");
}
