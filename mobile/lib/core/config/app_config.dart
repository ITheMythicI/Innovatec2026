import 'package:flutter/foundation.dart';

/// Configuración general de la aplicación móvil y enlace con el Backend.
class AppConfig {
  static const String appName = 'Resguardo - Innovatec 2026';
  static const String appVersion = '1.0.0';

  /// URL base para el Backend NestJS según la plataforma.
  static String get defaultApiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3001/api';
    }
    // En emulador Android o dispositivo local
    return 'http://10.0.2.2:3001/api';
  }

  static const Duration connectTimeout = Duration(seconds: 8);
  static const Duration receiveTimeout = Duration(seconds: 12);
  static const Duration defaultSyncInterval = Duration(seconds: 30);
}
