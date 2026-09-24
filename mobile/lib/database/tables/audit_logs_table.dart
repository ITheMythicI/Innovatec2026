/// Definición del esquema DDL de la tabla `audit_logs` en SQLite local.
class AuditLogsTable {
  static const String tableName = 'audit_logs';

  static const String columnId = 'id';
  static const String columnAction = 'action';
  static const String columnRole = 'role';
  static const String columnResourceType = 'resource_type';
  static const String columnResourceId = 'resource_id';
  static const String columnDetails = 'details';
  static const String columnTimestamp = 'timestamp';
  static const String columnSyncStatus = 'sync_status';

  static const String createTableSql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnAction TEXT NOT NULL,
      $columnRole TEXT NOT NULL,
      $columnResourceType TEXT NOT NULL,
      $columnResourceId TEXT,
      $columnDetails TEXT,
      $columnTimestamp TEXT NOT NULL,
      $columnSyncStatus TEXT NOT NULL DEFAULT 'synced'
    );
  ''';
}
