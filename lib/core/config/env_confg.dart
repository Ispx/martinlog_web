final class EnvConfig {
  static final EnvConfig _i = EnvConfig._();
  EnvConfig._();
  factory EnvConfig() => _i;
  static String get urlBase => const String.fromEnvironment("URL_BASE");
  static String get appName => const String.fromEnvironment("APP_NAME");
}
