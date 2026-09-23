/// Definición del esquema DDL de la tabla `sync_queue` para SQLite local.
///
/// Cada cambio realizado en modo offline (crear persona, reportar emergencia, etc.)
/// debe registrarse en esta cola antes de intentar ser enviado al servidor.
class SyncQueueTable {
  static const String tableName = 'sync_queue';

  static const String columnEventId = 'event_id';
  static const String columnDeviceId = 'device_id';
  static const String columnEntityType = 'entity_type';
  static const String columnEntityId = 'entity_id';
  static const String columnOperation = 'operation';
  static const String columnVersion = 'version';
  static const String columnPayload = 'payload';
  static const String columnCreatedAt = 'created_at';
  static const String columnSyncedAt = 'synced_at';
  static const String columnStatus = 'status';

  /// Script SQL para crear la tabla de eventos de sincronización.
  static const String createTableSql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnEventId TEXT PRIMARY KEY,
      $columnDeviceId TEXT NOT NULL,
      $columnEntityType TEXT NOT NULL,
      $columnEntityId TEXT NOT NULL,
      $columnOperation TEXT NOT NULL,
      $columnVersion INTEGER NOT NULL DEFAULT 1,
      $columnPayload TEXT NOT NULL,
      $columnCreatedAt TEXT NOT NULL,
      $columnSyncedAt TEXT,
      $columnStatus TEXT NOT NULL DEFAULT 'PENDING'
    );
  ''';

  /// Índices para optimizar consultas de pendientes de envío.
  static const String createIndexStatusSql = '''
    CREATE INDEX IF NOT EXISTS idx_sync_queue_status ON $tableName ($columnStatus, $columnCreatedAt);
  ''';
}
