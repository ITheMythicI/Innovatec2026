import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../database/app_database.dart';
import '../database/tables/sync_queue_table.dart';
import 'sync_event.dart';

/// Gestor central de sincronización offline-first.
/// Coordina la persistencia en `sync_queue` y la retransmisión idempotente al backend.
class SyncManager {
  static SyncManager? _instance;
  static SyncManager get instance => _instance ??= SyncManager();

  final AppDatabase _database;
  final ApiClient _apiClient;
  final String _deviceId;

  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  final _pendingCountController = StreamController<int>.broadcast();
  Timer? _periodicTimer;
  bool _isSyncing = false;

  SyncManager({
    AppDatabase? database,
    ApiClient? apiClient,
    String? deviceId,
    bool enablePeriodicSync = true,
  })  : _database = database ?? AppDatabase.instance,
        _apiClient = apiClient ?? ApiClient.instance,
        _deviceId = deviceId ?? 'dev-mobile-${const Uuid().v4().substring(0, 8)}' {
    if (enablePeriodicSync) {
      _startPeriodicSync();
    }
  }

  String get deviceId => _deviceId;
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  Stream<int> get pendingCountStream => _pendingCountController.stream;
  bool get isSyncing => _isSyncing;

  void _startPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(AppConfig.defaultSyncInterval, (_) {
      synchronizePendingEvents();
    });
  }

  /// Encola una mutación local generada en el dispositivo móvil.
  Future<SyncEvent> enqueueLocalMutation({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
    int version = 1,
  }) async {
    final event = SyncEvent(
      eventId: const Uuid().v4(),
      deviceId: _deviceId,
      entityType: entityType,
      entityId: entityId,
      operation: operation.toUpperCase(),
      version: version,
      payload: payload,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      status: SyncStatus.pending,
    );

    await _database.syncQueueDao.enqueueEvent(
      eventId: event.eventId,
      deviceId: event.deviceId,
      entityType: event.entityType,
      entityId: event.entityId,
      operation: event.operation,
      version: event.version,
      payloadJson: json.encode(event.payload),
      createdAtUtc: event.createdAt,
    );

    _updatePendingCount();

    // Intenta enviar de inmediato si hay conectividad
    unawaited(synchronizePendingEvents());

    return event;
  }

  /// Procesa los eventos pendientes y los envía al backend garantizando idempotencia.
  Future<int> synchronizePendingEvents() async {
    if (_isSyncing) return 0;
    _isSyncing = true;
    if (!_syncStatusController.isClosed) {
      _syncStatusController.add(SyncStatus.syncing);
    }

    int syncedCount = 0;
    try {
      final pendingList = await _database.syncQueueDao.getPendingEvents();
      if (!_pendingCountController.isClosed) {
        _pendingCountController.add(pendingList.length);
      }

      if (pendingList.isEmpty) {
        if (!_syncStatusController.isClosed) {
          _syncStatusController.add(SyncStatus.synced);
        }
        return 0;
      }

      for (final eventMap in pendingList) {
        final eventId = eventMap[SyncQueueTable.columnEventId] as String;
        try {
          dynamic payloadData = eventMap[SyncQueueTable.columnPayload];
          if (payloadData is String) {
            try {
              payloadData = json.decode(payloadData);
            } catch (_) {}
          }

          final backendPayload = {
            'event_id': eventId,
            'device_id': eventMap[SyncQueueTable.columnDeviceId],
            'entity_type': eventMap[SyncQueueTable.columnEntityType],
            'entity_id': eventMap[SyncQueueTable.columnEntityId],
            'operation': eventMap[SyncQueueTable.columnOperation],
            'version': eventMap[SyncQueueTable.columnVersion],
            'payload': payloadData,
            'created_at': eventMap[SyncQueueTable.columnCreatedAt],
          };

          // Envío vía HTTPS al endpoint del backend
          await _apiClient.post('/sync/events', body: backendPayload);
          final nowUtc = DateTime.now().toUtc().toIso8601String();
          await _database.syncQueueDao.markEventCompleted(eventId, nowUtc);
          syncedCount++;
        } catch (e) {
          await _database.syncQueueDao.markEventFailed(eventId, e.toString());
          if (!_syncStatusController.isClosed) {
            _syncStatusController.add(SyncStatus.failed);
          }
          break;
        }
      }

      if (syncedCount > 0 && !_syncStatusController.isClosed) {
        _syncStatusController.add(SyncStatus.synced);
      }
    } finally {
      _isSyncing = false;
      _updatePendingCount();
    }

    return syncedCount;
  }

  Future<void> _updatePendingCount() async {
    if (_pendingCountController.isClosed) return;
    final pending = await _database.syncQueueDao.getPendingEvents();
    if (!_pendingCountController.isClosed) {
      _pendingCountController.add(pending.length);
    }
  }

  void stopPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  void dispose() {
    stopPeriodicSync();
    _syncStatusController.close();
    _pendingCountController.close();
  }
}
