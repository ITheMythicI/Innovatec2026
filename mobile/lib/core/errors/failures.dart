/// Jerarquía base de fallos y excepciones para la aplicación.
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
