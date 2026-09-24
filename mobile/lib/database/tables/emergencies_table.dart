/// Definición del esquema DDL de la tabla `emergencies` en SQLite local.
class EmergenciesTable {
  static const String tableName = 'emergencies';

  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnDescription = 'description';
  static const String columnType = 'type';
  static const String columnSeverity = 'severity';
  static const String columnStatus = 'status';
  static const String columnLatitude = 'latitude';
  static const String columnLongitude = 'longitude';
  static const String columnRadiusMeters = 'radius_meters';
  static const String columnStartedAt = 'started_at';
  static const String columnEndedAt = 'ended_at';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnSyncStatus = 'sync_status'; // synced, pending_create, pending_update

  static const String createTableSql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnTitle TEXT NOT NULL,
      $columnDescription TEXT,
      $columnType TEXT NOT NULL,
      $columnSeverity TEXT NOT NULL,
      $columnStatus TEXT NOT NULL,
      $columnLatitude REAL NOT NULL,
      $columnLongitude REAL NOT NULL,
      $columnRadiusMeters REAL,
      $columnStartedAt TEXT NOT NULL,
      $columnEndedAt TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      $columnSyncStatus TEXT NOT NULL DEFAULT 'synced'
    );
  ''';
}
