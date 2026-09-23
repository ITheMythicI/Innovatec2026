/// Constantes globales de la aplicación móvil Innovatec 2026.
class AppConstants {
  // Configuración de SQLite local
  static const String databaseName = 'innovatec_emergency.db';
  static const int databaseVersion = 1;

  // Tipos de entidades sincronizables
  static const String entityPerson = 'person';
  static const String entityFamily = 'family';
  static const String entityEmergency = 'emergency';
  static const String entityShelter = 'shelter';
  static const String entityReport = 'report';
  static const String entityLocationEvent = 'location_event';

  // Operaciones de sincronización
  static const String operationCreate = 'CREATE';
  static const String operationUpdate = 'UPDATE';
  static const String operationDelete = 'DELETE';

  // Estados de sincronización local
  static const String syncStatusPending = 'PENDING';
  static const String syncStatusProcessing = 'PROCESSING';
  static const String syncStatusCompleted = 'COMPLETED';
  static const String syncStatusFailed = 'FAILED';

  // Canales de transporte para sincronización en contingencia
  static const String transportHttp = 'HTTPS';
  static const String transportBle = 'BLE';
  static const String transportSms = 'SMS';
}
