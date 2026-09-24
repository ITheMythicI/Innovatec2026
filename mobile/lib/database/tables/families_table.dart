/// Definición del esquema DDL de la tabla `families` y `family_members` en SQLite local.
class FamiliesTable {
  static const String tableFamilies = 'families';
  static const String tableMembers = 'family_members';

  // Familias
  static const String columnId = 'id';
  static const String columnFamilyName = 'family_name';
  static const String columnEmergencyMeetingPoint = 'emergency_meeting_point';
  static const String columnRepresentativeContact = 'representative_contact';
  static const String columnNotes = 'notes';
  static const String columnLastStatusUpdate = 'last_status_update';
  static const String columnSyncStatus = 'sync_status';

  // Miembros
  static const String columnMemberId = 'id';
  static const String columnMemberFamilyId = 'family_id';
  static const String columnMemberName = 'name';
  static const String columnMemberAge = 'age';
  static const String columnMemberRelationship = 'relationship';
  static const String columnMemberStatus = 'status';
  static const String columnMemberLocation = 'location';
  static const String columnMemberLastCheckIn = 'last_check_in';
  static const String columnMemberBatteryLevel = 'battery_level';
  static const String columnMemberMeshHops = 'mesh_hops';
  static const String columnMemberMedicalAlert = 'medical_alert';
  static const String columnMemberIsSafe = 'is_safe';

  static const String createFamiliesTableSql = '''
    CREATE TABLE IF NOT EXISTS $tableFamilies (
      $columnId TEXT PRIMARY KEY,
      $columnFamilyName TEXT NOT NULL,
      $columnEmergencyMeetingPoint TEXT NOT NULL,
      $columnRepresentativeContact TEXT,
      $columnNotes TEXT,
      $columnLastStatusUpdate TEXT NOT NULL,
      $columnSyncStatus TEXT NOT NULL DEFAULT 'synced'
    );
  ''';

  static const String createMembersTableSql = '''
    CREATE TABLE IF NOT EXISTS $tableMembers (
      $columnMemberId TEXT PRIMARY KEY,
      $columnMemberFamilyId TEXT NOT NULL,
      $columnMemberName TEXT NOT NULL,
      $columnMemberAge INTEGER NOT NULL,
      $columnMemberRelationship TEXT NOT NULL,
      $columnMemberStatus TEXT NOT NULL,
      $columnMemberLocation TEXT NOT NULL,
      $columnMemberLastCheckIn TEXT NOT NULL,
      $columnMemberBatteryLevel INTEGER NOT NULL,
      $columnMemberMeshHops INTEGER NOT NULL DEFAULT 0,
      $columnMemberMedicalAlert TEXT,
      $columnMemberIsSafe INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY ($columnMemberFamilyId) REFERENCES $tableFamilies ($columnId) ON DELETE CASCADE
    );
  ''';
}
