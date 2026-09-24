/// Modelo de datos para eventos de sincronización offline-first.
/// Representa una mutación atómica e idempotente realizada en el cliente.
enum SyncStatus {
  pending,
  syncing,
  synced,
  failed,
  conflict,
}

class SyncEvent {
  /// Identificador único del evento (UUID v4 generado en el dispositivo).
  final String eventId;

  /// Identificador único del dispositivo emisor.
  final String deviceId;

  /// Tipo de entidad afectada (ej: 'person', 'family', 'emergency', 'report', 'shelter', 'profile').
  final String entityType;

  /// Identificador único (UUID) de la entidad afectada.
  final String entityId;

  /// Operación realizada: CREATE, UPDATE o DELETE.
  final String operation;

  /// Versión incremental de la entidad para resolución de conflictos.
  final int version;

  /// Carga útil en formato JSON (datos de la entidad).
  final Map<String, dynamic> payload;

  /// Marca de tiempo UTC en que ocurrió el evento en el dispositivo.
  final String createdAt;

  /// Marca de tiempo UTC en que el backend confirmó la recepción y persistencia.
  final String? syncedAt;

  /// Estado de sincronización.
  final SyncStatus status;

  /// Cantidad de reintentos fallidos.
  final int retryCount;

  /// Último error registrado.
  final String? lastError;

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
    this.status = SyncStatus.pending,
    this.retryCount = 0,
    this.lastError,
  });

  SyncEvent copyWith({
    String? syncedAt,
    SyncStatus? status,
    int? retryCount,
    String? lastError,
  }) {
    return SyncEvent(
      eventId: eventId,
      deviceId: deviceId,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      version: version,
      payload: payload,
      createdAt: createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  /// Formato requerido por el backend NestJS `/api/sync/events`.
  Map<String, dynamic> toBackendJson() => {
    'event_id': eventId,
    'device_id': deviceId,
    'entity_type': entityType,
    'entity_id': entityId,
    'operation': operation,
    'version': version,
    'payload': payload,
    'created_at': createdAt,
  };

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
    'status': status.name,
    'retryCount': retryCount,
    'lastError': lastError,
  };

  factory SyncEvent.fromJson(Map<String, dynamic> json) => SyncEvent(
    eventId: (json['eventId'] ?? json['event_id']) as String,
    deviceId: (json['deviceId'] ?? json['device_id']) as String,
    entityType: (json['entityType'] ?? json['entity_type']) as String,
    entityId: (json['entityId'] ?? json['entity_id']) as String,
    operation: (json['operation'] as String).toUpperCase(),
    version: (json['version'] as num?)?.toInt() ?? 1,
    payload: (json['payload'] as Map<String, dynamic>?) ?? {},
    createdAt: (json['createdAt'] ?? json['created_at']) as String,
    syncedAt: (json['syncedAt'] ?? json['synced_at']) as String?,
    status: SyncStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == (json['status'] ?? 'pending').toString().toLowerCase(),
      orElse: () => SyncStatus.pending,
    ),
    retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
    lastError: json['lastError'] as String?,
  );
}
