import 'dart:math';

/// Utilidades de fecha y hora estandarizadas.
/// Todas las fechas que se almacenen localmente o se envíen al servidor
/// DEBEN estar en formato UTC (ISO 8601).
class DateTimeUtils {
  /// Obtiene la marca de tiempo actual en formato ISO 8601 UTC.
  static String nowUtcIso() {
    return DateTime.now().toUtc().toIso8601String();
  }

  /// Parsea una cadena ISO 8601 a DateTime en UTC.
  static DateTime parseToUtc(String isoString) {
    return DateTime.parse(isoString).toUtc();
  }
}

/// Generador de identificadores únicos UUID v4 para uso offline.
/// Permite generar IDs en el dispositivo sin depender del backend ni generar colisiones.
class UuidUtils {
  static final Random _random = Random.secure();

  /// Genera un UUID v4 criptográficamente pseudoaleatorio compatible con RFC 4122.
  static String generateUuidV4() {
    final values = List<int>.generate(16, (i) => _random.nextInt(256));
    // Set version 4 (bits 12-15 of time_hi_and_version to 0100)
    values[6] = (values[6] & 0x0f) | 0x40;
    // Set variant to RFC 4122 (bits 6-7 of clock_seq_hi_and_reserved to 10)
    values[8] = (values[8] & 0x3f) | 0x80;

    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }
}
