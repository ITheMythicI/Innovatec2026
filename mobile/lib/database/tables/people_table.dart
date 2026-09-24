/// Definición del esquema DDL de la tabla `people` y reportes de desaparecidos en SQLite local.
class PeopleTable {
  static const String tableName = 'people';

  static const String columnId = 'id';
  static const String columnType = 'type';
  static const String columnFullName = 'full_name';
  static const String columnAge = 'age';
  static const String columnIsMinor = 'is_minor';
  static const String columnGender = 'gender';
  static const String columnPhysicalDescription = 'physical_description';
  static const String columnPrivateDistinctiveMarks = 'private_distinctive_marks';
  static const String columnLastKnownLocation = 'last_known_location';
  static const String columnLatitude = 'latitude';
  static const String columnLongitude = 'longitude';
  static const String columnCurrentShelterName = 'current_shelter_name';
  static const String columnContactPhone = 'contact_phone';
  static const String columnReporterName = 'reporter_name';
  static const String columnReporterRelationship = 'reporter_relationship';
  static const String columnStatus = 'status';
  static const String columnVerifiedByOfficialId = 'verified_by_official_id';
  static const String columnVerifiedByOfficialName = 'verified_by_official_name';
  static const String columnOfficialReunificationNotes = 'official_reunification_notes';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnSyncStatus = 'sync_status';

  static const String createTableSql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnType TEXT NOT NULL,
      $columnFullName TEXT NOT NULL,
      $columnAge INTEGER NOT NULL,
      $columnIsMinor INTEGER NOT NULL DEFAULT 0,
      $columnGender TEXT NOT NULL,
      $columnPhysicalDescription TEXT NOT NULL,
      $columnPrivateDistinctiveMarks TEXT,
      $columnLastKnownLocation TEXT NOT NULL,
      $columnLatitude REAL,
      $columnLongitude REAL,
      $columnCurrentShelterName TEXT,
      $columnContactPhone TEXT NOT NULL,
      $columnReporterName TEXT NOT NULL,
      $columnReporterRelationship TEXT NOT NULL,
      $columnStatus TEXT NOT NULL,
      $columnVerifiedByOfficialId TEXT,
      $columnVerifiedByOfficialName TEXT,
      $columnOfficialReunificationNotes TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      $columnSyncStatus TEXT NOT NULL DEFAULT 'synced'
    );
  ''';
}
