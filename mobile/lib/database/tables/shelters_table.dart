/// Definición del esquema DDL de la tabla `shelters` en SQLite local.
class SheltersTable {
  static const String tableName = 'shelters';

  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnAddress = 'address';
  static const String columnLatitude = 'latitude';
  static const String columnLongitude = 'longitude';
  static const String columnCapacity = 'capacity';
  static const String columnCurrentOccupancy = 'current_occupancy';
  static const String columnStatus = 'status';
  static const String columnContactName = 'contact_name';
  static const String columnContactPhone = 'contact_phone';
  static const String columnManagedBy = 'managed_by';
  static const String columnServicesJson = 'services_json';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnSyncStatus = 'sync_status';

  static const String createTableSql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnAddress TEXT,
      $columnLatitude REAL NOT NULL,
      $columnLongitude REAL NOT NULL,
      $columnCapacity INTEGER NOT NULL,
      $columnCurrentOccupancy INTEGER NOT NULL DEFAULT 0,
      $columnStatus TEXT NOT NULL,
      $columnContactName TEXT,
      $columnContactPhone TEXT,
      $columnManagedBy TEXT,
      $columnServicesJson TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      $columnSyncStatus TEXT NOT NULL DEFAULT 'synced'
    );
  ''';
}
