import '../tables/sync_queue_table.dart';

/// Contrato e interfaz Data Access Object (DAO) para la cola de sincronización SQLite.
abstract class SyncQueueDao {
  /// Inserta un nuevo evento pendiente de sincronización.
  Future<void> enqueueEvent({
    required String eventId,
    required String deviceId,
    required String entityType,
    required String entityId,
    required String operation,
    required int version,
    required String payloadJson,
    required String createdAtUtc,
  });

  /// Obtiene los eventos en estado 'PENDING' ordenados cronológicamente.
  Future<List<Map<String, dynamic>>> getPendingEvents({int limit = 50});

  /// Marca un evento como completado tras confirmación del backend.
  Future<void> markEventCompleted(String eventId, String syncedAtUtc);

  /// Marca un evento como fallido para reintento posterior.
  Future<void> markEventFailed(String eventId, String reason);
}

/// Implementación en memoria / stub para desarrollo y pruebas antes de enlazar el plugin nativo SQLite.
class InMemorySyncQueueDao implements SyncQueueDao {
  final List<Map<String, dynamic>> _storage = [];

  @override
  Future<void> enqueueEvent({
    required String eventId,
    required String deviceId,
    required String entityType,
    required String entityId,
    required String operation,
    required int version,
    required String payloadJson,
    required String createdAtUtc,
  }) async {
    _storage.add({
      SyncQueueTable.columnEventId: eventId,
      SyncQueueTable.columnDeviceId: deviceId,
      SyncQueueTable.columnEntityType: entityType,
      SyncQueueTable.columnEntityId: entityId,
      SyncQueueTable.columnOperation: operation,
      SyncQueueTable.columnVersion: version,
      SyncQueueTable.columnPayload: payloadJson,
      SyncQueueTable.columnCreatedAt: createdAtUtc,
      SyncQueueTable.columnSyncedAt: null,
      SyncQueueTable.columnStatus: 'PENDING',
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingEvents({int limit = 50}) async {
    return _storage
        .where((e) => e[SyncQueueTable.columnStatus] == 'PENDING')
        .take(limit)
        .toList();
  }

  @override
  Future<void> markEventCompleted(String eventId, String syncedAtUtc) async {
    final index = _storage.indexWhere((e) => e[SyncQueueTable.columnEventId] == eventId);
    if (index != -1) {
      _storage[index][SyncQueueTable.columnStatus] = 'COMPLETED';
      _storage[index][SyncQueueTable.columnSyncedAt] = syncedAtUtc;
    }
  }

  @override
  Future<void> markEventFailed(String eventId, String reason) async {
    final index = _storage.indexWhere((e) => e[SyncQueueTable.columnEventId] == eventId);
    if (index != -1) {
      _storage[index][SyncQueueTable.columnStatus] = 'FAILED';
    }
  }
}
