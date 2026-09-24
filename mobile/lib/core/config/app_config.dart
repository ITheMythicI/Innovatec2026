import 'package:flutter/foundation.dart';

/// Configuración general de la aplicación móvil y enlace con el Backend.
class AppConfig {
  static const String appName = 'Resguardo - Innovatec 2026';
  static const String appVersion = '1.0.0';

  /// URL base principal para el Backend NestJS.
  static String get defaultApiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3001/api';
    }
    // IP directa Wi-Fi de la estación de desarrollo para dispositivos Android físicos y emuladores
    return 'http://172.16.160.167:3001/api';
  }

  /// Lista de hosts candidatos para conexión resiliente (dispositivo físico, emulador, loopback)
  static List<String> get candidateApiBaseUrls => [
        'http://172.16.160.167:3001/api',
        'http://10.0.2.2:3001/api',
        'http://localhost:3001/api',
        'http://127.0.0.1:3001/api',
      ];

  static const Duration connectTimeout = Duration(seconds: 6);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration defaultSyncInterval = Duration(seconds: 30);
}

