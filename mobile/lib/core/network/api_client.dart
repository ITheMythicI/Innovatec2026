import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../errors/failures.dart';

/// Cliente HTTP centralizado y multiplataforma (Móvil y Web).
/// Implementa manejo estructurado de errores, timeouts e inyección de encabezados.
class ApiClient {
  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient();

  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  ApiClient({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? AppConfig.defaultApiBaseUrl,
        _client = client ?? http.Client();

  void setAuthToken(String? token) {
    _authToken = token;
  }

  String? get authToken => _authToken;

  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  /// Realiza una petición GET al backend. Retorna `dynamic` (Map o List).
  Future<dynamic> get(String endpoint, {Map<String, String>? headers, Map<String, dynamic>? queryParams}) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        final stringParams = queryParams.map((k, v) => MapEntry(k, v.toString()));
        uri = uri.replace(queryParameters: stringParams);
      }

      final response = await _client
          .get(uri, headers: _buildHeaders(headers))
          .timeout(AppConfig.connectTimeout);

      return _processResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkFailure('No fue posible conectar con el servidor backend ($baseUrl)', e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Error inesperado de comunicación', null, e);
    }
  }

  /// Realiza una petición POST al backend.
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final encodedBody = body != null ? json.encode(body) : null;

      final response = await _client
          .post(uri, headers: _buildHeaders(headers), body: encodedBody)
          .timeout(AppConfig.connectTimeout);

      return _processResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkFailure('No fue posible conectar con el servidor backend', e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Error inesperado de comunicación', null, e);
    }
  }

  /// Realiza una petición PATCH al backend.
  Future<dynamic> patch(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final encodedBody = body != null ? json.encode(body) : null;

      final response = await _client
          .patch(uri, headers: _buildHeaders(headers), body: encodedBody)
          .timeout(AppConfig.connectTimeout);

      return _processResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkFailure('No fue posible conectar con el servidor backend', e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Error inesperado de comunicación', null, e);
    }
  }

  /// Realiza una petición DELETE al backend.
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await _client
          .delete(uri, headers: _buildHeaders(headers))
          .timeout(AppConfig.connectTimeout);

      return _processResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkFailure('No fue posible conectar con el servidor backend', e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Error inesperado de comunicación', null, e);
    }
  }

  Future<dynamic> _processResponse(http.Response response) async {
    final responseBody = response.body;
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (responseBody.trim().isEmpty) return <String, dynamic>{};
      return json.decode(responseBody);
    } else if (statusCode == 401 || statusCode == 403) {
      throw AuthFailure('Acceso denegado o sesión expirada ($statusCode)');
    } else if (statusCode == 404) {
      throw NotFoundFailure('El recurso solicitado no existe ($statusCode)');
    } else if (statusCode == 409) {
      throw ConflictFailure('Conflicto detectado en la operación ($statusCode)');
    } else if (statusCode >= 400 && statusCode < 500) {
      throw ValidationFailure('Error de validación en la solicitud: $responseBody');
    } else {
      throw ServerFailure('Error en el servidor backend ($statusCode): $responseBody', statusCode);
    }
  }
}
