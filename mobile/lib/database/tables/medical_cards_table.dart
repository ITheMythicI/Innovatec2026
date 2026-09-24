/// Definición del esquema DDL de la tabla `medical_cards` en SQLite local.
class MedicalCardsTable {
  static const String tableName = 'medical_cards';

  static const String columnId = 'id';
  static const String columnFullName = 'full_name';
  static const String columnNationalId = 'national_id';
  static const String columnBloodType = 'blood_type';
  static const String columnAllergiesJson = 'allergies_json';
  static const String columnChronicConditionsJson = 'chronic_conditions_json';
  static const String columnCurrentMedicationsJson = 'current_medications_json';
  static const String columnEmergencyContactsJson = 'emergency_contacts_json';
  static const String columnSpecialInstructions = 'special_instructions';
  static const String columnOrganDonor = 'organ_donor';
  static const String columnLastTriageStatus = 'last_triage_status';
  static const String columnLastUpdated = 'last_updated';
  static const String columnSyncStatus = 'sync_status';

  static const String createTableSql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnFullName TEXT NOT NULL,
      $columnNationalId TEXT,
      $columnBloodType TEXT NOT NULL,
      $columnAllergiesJson TEXT,
      $columnChronicConditionsJson TEXT,
      $columnCurrentMedicationsJson TEXT,
      $columnEmergencyContactsJson TEXT,
      $columnSpecialInstructions TEXT,
      $columnOrganDonor INTEGER NOT NULL DEFAULT 0,
      $columnLastTriageStatus TEXT,
      $columnLastUpdated TEXT NOT NULL,
      $columnSyncStatus TEXT NOT NULL DEFAULT 'synced'
    );
  ''';
}
