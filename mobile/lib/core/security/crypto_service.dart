import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

/// Servicio de utilidades criptográficas para la app móvil offline-first.
/// 
/// Responsabilidades:
/// - Cálculo de hashes SHA-256 para integridad de datos.
/// - Firma criptográfica local de reportes y eventos de auditoría.
/// - Generación de identificadores únicos UUID v4/v7.
/// - Verificación de cadenas de hash (Hash Chains).
class CryptoService {
  static const Uuid _uuid = Uuid();

  /// Genera un identificador único para reportes y transacciones locales.
  static String generateId() {
    return _uuid.v4();
  }

  /// Calcula el hash SHA-256 de una cadena de texto.
  static String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Calcula el hash de un mapa de datos serializado.
  static String hashData(Map<String, dynamic> data) {
    final sortedJson = jsonEncode(_sortMap(data));
    return sha256Hash(sortedJson);
  }

  /// Firma digital local basada en HMAC-SHA256 para entornos desconectados.
  /// En producción se vincula con la clave privada Ed25519 en FlutterSecureStorage.
  static String signPayload(String payload, String privateKeyOrSecret) {
    final key = utf8.encode(privateKeyOrSecret);
    final bytes = utf8.encode(payload);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  /// Verifica la validez de una firma.
  static bool verifySignature({
    required String payload,
    required String signature,
    required String publicKeyOrSecret,
  }) {
    final expectedSignature = signPayload(payload, publicKeyOrSecret);
    return expectedSignature == signature;
  }

  /// Ordena recursivamente un mapa para asegurar hashes deterministas.
  static Map<String, dynamic> _sortMap(Map<String, dynamic> map) {
    final sortedKeys = map.keys.toList()..sort();
    final result = <String, dynamic>{};
    for (final key in sortedKeys) {
      final value = map[key];
      if (value is Map<String, dynamic>) {
        result[key] = _sortMap(value);
      } else if (value is List) {
        result[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _sortMap(item);
          }
          return item;
        }).toList();
      } else {
        result[key] = value;
      }
    }
    return result;
  }
}
