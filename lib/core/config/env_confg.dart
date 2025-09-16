final class EnvConfig {
  static final EnvConfig _i = EnvConfig._();
  EnvConfig._();
  factory EnvConfig() => _i;
  static String get urlBase => 'https://api.martinlog.com.br';
  static String get wsBase => 'wss://ws-api.martinlog.com.br';
  static String get appName =>
      'Plataforma Martin log';
}
