class AppConfig {
  AppConfig._();

  // Set to own development device IP
  // Alternatively use launch command flag with own IP:
  // flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.101:8000/',
  );
}
