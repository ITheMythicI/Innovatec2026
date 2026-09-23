import 'dart:async';
import '../core/network/api_client.dart';
import '../database/app_database.dart';
import 'sync_event.dart';

/// Gestor de sincronización offline-first de la aplicación.
///
/// Flujo de trabajo:
/// 1. Los módulos de la aplicación encolan eventos a través de [enqueueLocalMutation].
/// 2. El evento se guarda primero en SQLite (`sync_queue`) con estado PENDING.
/// 3. Cuando se dispone de conectividad (o periódicamente), [synchronizePendingEvents]
///    procesa los eventos y los transmite al Backend NestJS (`/api/sync/events`).
/// 4. El backend procesa de manera idempotente por `eventId` y confirma la persistencia.
/// 5. El evento local se marca como COMPLETED.
/// 6. En contingencia extrema, este gestor podrá enrutar eventos a través de BLE o SMS.
class SyncManager {
  final AppDatabase _database;
  final ApiClient _apiClient;
  bool _isSyncing = false;

  SyncManager({
    AppDatabase? database,
    ApiClient? apiClient,
  })  : _database = database ?? AppDatabase.instance,
        _apiClient = apiClient ?? ApiClient();

  /// Encola una mutación local generada en el dispositivo móvil.
  Future<void> enqueueLocalMutation(SyncEvent event) async {
    await _database.syncQueueDao.enqueueEvent(
      eventId: event.eventId,
      deviceId: event.deviceId,
      entityType: event.entityType,
      entityId: event.entityId,
      operation: event.operation,
      version: event.version,
      payloadJson: event.payload.toString(),
      createdAtUtc: event.createdAt,
    );
  }

  /// Procesa los eventos pendientes y los envía al backend.
  Future<int> synchronizePendingEvents() async {
    if (_isSyncing) return 0;
    _isSyncing = true;

    int syncedCount = 0;
    try {
      final pendingList = await _database.syncQueueDao.getPendingEvents();
      if (pendingList.isEmpty) return 0;

      for (final eventMap in pendingList) {
        final eventId = eventMap['event_id'] as String;
        try {
          // Envío vía HTTPS al endpoint del backend
          await _apiClient.post('/sync/events', body: eventMap);
          final nowUtc = DateTime.now().toUtc().toIso8601String();
          await _database.syncQueueDao.markEventCompleted(eventId, nowUtc);
          syncedCount++;
        } catch (e) {
          await _database.syncQueueDao.markEventFailed(eventId, e.toString());
          // Detener el bucle en caso de fallo de red para evitar reintentos en vano
          break;
        }
      }
    } finally {
      _isSyncing = false;
    }

    return syncedCount;
  }
}
