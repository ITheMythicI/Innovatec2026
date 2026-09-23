/// Modelo de datos para eventos de sincronización offline-first.
/// Representa una mutación atómica e idempotente realizada en el cliente.
class SyncEvent {
  /// Identificador único del evento (UUID v4 generado en el dispositivo).
  final String eventId;

  /// Identificador único del dispositivo emisor.
  final String deviceId;

  /// Tipo de entidad afectada (ej: 'person', 'family', 'emergency', 'report').
  final String entityType;

  /// Identificador único (UUID) de la entidad afectada.
  final String entityId;

  /// Operación realizada: CREATE, UPDATE o DELETE.
  final String operation;

  /// Versión incremental de la entidad para resolución de conflictos (optimistic concurrency).
  final int version;

  /// Carga útil en formato JSON (datos de la entidad).
  final Map<String, dynamic> payload;

  /// Marca de tiempo UTC en que ocurrió el evento en el dispositivo.
  final String createdAt;

  /// Marca de tiempo UTC en que el backend confirmó la recepción y persistencia.
  final String? syncedAt;

  /// Estado de sincronización: PENDING, PROCESSING, COMPLETED, FAILED.
  final String status;

  const SyncEvent({
    required this.eventId,
    required this.deviceId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.version,
    required this.payload,
    required this.createdAt,
    this.syncedAt,
    this.status = 'PENDING',
  });

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'deviceId': deviceId,
        'entityType': entityType,
        'entityId': entityId,
        'operation': operation,
        'version': version,
        'payload': payload,
        'createdAt': createdAt,
        'syncedAt': syncedAt,
        'status': status,
      };

  factory SyncEvent.fromJson(Map<String, dynamic> json) => SyncEvent(
        eventId: json['eventId'] as String,
        deviceId: json['deviceId'] as String,
        entityType: json['entityType'] as String,
        entityId: json['entityId'] as String,
        operation: json['operation'] as String,
        version: (json['version'] as num?)?.toInt() ?? 1,
        payload: json['payload'] as Map<String, dynamic>,
        createdAt: json['createdAt'] as String,
        syncedAt: json['syncedAt'] as String?,
        status: json['status'] as String? ?? 'PENDING',
      );
}
