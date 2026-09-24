/// Jerarquía base de fallos y excepciones para la aplicación móvil.
abstract class Failure {
  final String message;
  final dynamic cause;

  const Failure(this.message, [this.cause]);

  @override
  String toString() => '$runtimeType: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Fallo por falta de conexión a red o servidor no disponible.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No hay conexión de red disponible', super.cause]);
}

/// Fallo originado en el servidor backend (códigos 4xx / 5xx).
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure([super.message = 'Error en el servidor backend', this.statusCode, super.cause]);
}

/// Fallo en operaciones de base de datos local (SQLite).
class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Error en la base de datos local SQLite', super.cause]);
}

/// Fallo en el proceso de sincronización offline.
class SyncFailure extends Failure {
  const SyncFailure([super.message = 'Error al sincronizar datos', super.cause]);
}

/// Fallo por falta de permisos o sesión inválida/expirada.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'No autorizado o sesión expirada', super.cause]);
}

/// Fallo de validación de campos obligatorios o formato incorrecto.
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Datos de entrada inválidos', super.cause]);
}

/// Fallo cuando un recurso no fue encontrado.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado', super.cause]);
}

/// Fallo por conflicto de versiones en concurrencia offline/online.
class ConflictFailure extends Failure {
  const ConflictFailure([super.message = 'Conflicto de sincronización detectado', super.cause]);
}
