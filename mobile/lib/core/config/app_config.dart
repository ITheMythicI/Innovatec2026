/// Configuración general de la aplicación móvil.
class AppConfig {
  static const String appName = 'Innovatec 2026';
  static const String appVersion = '1.0.0';

  /// URL base predeterminada para el Backend NestJS.
  /// En emulador Android, 10.0.2.2 apunta al localhost de la máquina host.
  /// Para dispositivos físicos, utilizar la IP local de la red LAN (ej: 192.168.1.X:3001/api).
  static const String defaultApiBaseUrl = 'http://10.0.2.2:3001/api';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration defaultSyncInterval = Duration(minutes: 5);
}
