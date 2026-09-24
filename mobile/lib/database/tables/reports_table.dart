/// Definición del esquema DDL de la tabla `reports` en SQLite local.
class ReportsTable {
  static const String tableName = 'reports';

  static const String columnId = 'id';
  static const String columnReporterUserId = 'reporter_user_id';
  static const String columnReporterName = 'reporter_name';
  static const String columnReporterContact = 'reporter_contact';
  static const String columnEmergencyId = 'emergency_id';
  static const String columnTitle = 'title';
  static const String columnDescription = 'description';
  static const String columnCategory = 'category';
  static const String columnPriority = 'priority';
  static const String columnStatus = 'status';
  static const String columnLatitude = 'latitude';
  static const String columnLongitude = 'longitude';
  static const String columnAddress = 'address';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnSyncStatus = 'sync_status';

  static const String createTableSql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnReporterUserId TEXT,
      $columnReporterName TEXT,
      $columnReporterContact TEXT,
      $columnEmergencyId TEXT,
      $columnTitle TEXT NOT NULL,
      $columnDescription TEXT NOT NULL,
      $columnCategory TEXT NOT NULL,
      $columnPriority TEXT NOT NULL,
      $columnStatus TEXT NOT NULL,
      $columnLatitude REAL,
      $columnLongitude REAL,
      $columnAddress TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      $columnSyncStatus TEXT NOT NULL DEFAULT 'synced'
    );
  ''';
}
