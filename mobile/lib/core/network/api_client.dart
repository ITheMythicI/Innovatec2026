import 'dart:convert';
import 'dart:io';
import '../config/app_config.dart';
import '../errors/failures.dart';

/// Cliente HTTP base para la comunicación con el Backend NestJS.
/// Utiliza `dart:io HttpClient` como base nativa, permitiendo que el equipo
/// pueda utilizarlo directamente o reemplazarlo posteriormente por `http` o `dio`.
class ApiClient {
  final String baseUrl;
  final HttpClient _httpClient;

  ApiClient({
    String? baseUrl,
    HttpClient? httpClient,
  })  : baseUrl = baseUrl ?? AppConfig.defaultApiBaseUrl,
        _httpClient = httpClient ?? HttpClient()
          ..connectionTimeout = AppConfig.connectTimeout;

  /// Realiza una petición GET al backend.
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = await _httpClient.getUrl(uri);

      headers?.forEach((key, value) {
        request.headers.set(key, value);
      });
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseBody.isEmpty) return {};
        return json.decode(responseBody) as Map<String, dynamic>;
      } else {
        throw ServerFailure('HTTP Error ${response.statusCode}: $responseBody', response.statusCode);
      }
    } on SocketException catch (e) {
      throw NetworkFailure('No fue posible contactar al backend', e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Error inesperado de comunicación', null, e);
    }
  }

  /// Realiza una petición POST al backend.
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = await _httpClient.postUrl(uri);

      headers?.forEach((key, value) {
        request.headers.set(key, value);
      });
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');

      if (body != null) {
        request.write(json.encode(body));
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseBody.isEmpty) return {};
        return json.decode(responseBody) as Map<String, dynamic>;
      } else {
        throw ServerFailure('HTTP Error ${response.statusCode}: $responseBody', response.statusCode);
      }
    } on SocketException catch (e) {
      throw NetworkFailure('No fue posible contactar al backend', e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Error inesperado de comunicación', null, e);
    }
  }
}
