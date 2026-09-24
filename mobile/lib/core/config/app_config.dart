/// Configuración general de la aplicación móvil.
class AppConfig {
  static const String appName = 'Innovatec 2026';
  static const String appVersion = '1.0.0';

  /// URL base predeterminada para el Backend NestJS.
  /// En Linux Desktop o emulador/navegador web, http://localhost:3001/api.
  static String get defaultApiBaseUrl {
    // Si estamos en Linux Desktop o Web, localhost directo:
    return 'http://localhost:3001/api';
  }

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration defaultSyncInterval = Duration(minutes: 5);
}
