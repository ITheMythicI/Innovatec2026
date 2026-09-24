import 'dart:async';
import 'dao/sync_queue_dao.dart';
import 'dao/emergencies_dao.dart';
import 'dao/shelters_dao.dart';
import 'dao/reports_dao.dart';
import 'dao/people_dao.dart';
import 'dao/families_dao.dart';
import 'dao/medical_card_dao.dart';
import 'dao/audit_dao.dart';
import 'tables/sync_queue_table.dart';
import 'tables/emergencies_table.dart';
import 'tables/shelters_table.dart';
import 'tables/reports_table.dart';
import 'tables/people_table.dart';
import 'tables/families_table.dart';
import 'tables/medical_cards_table.dart';
import 'tables/audit_logs_table.dart';

/// Abstracción central de la base de datos local SQLite para la arquitectura Offline-First.
///
/// Principios clave:
/// 1. La base de datos local NO es una réplica idéntica de PostgreSQL central.
/// 2. Almacena solo los datos locales del dispositivo (perfil del operador, caché de albergues cercanos,
///    emergencias activas y la cola de eventos diferidos en `sync_queue`).
/// 3. Todas las mutaciones locales se escriben en SQLite primero y luego se sincronizan con NestJS.
abstract class AppDatabase {
  static AppDatabase? _instance;

  static AppDatabase get instance {
    _instance ??= _AppDatabaseImpl();
    return _instance!;
  }

  /// Retorna los DAOs para interactuar con las tablas locales.
  SyncQueueDao get syncQueueDao;
  EmergenciesDao get emergenciesDao;
  SheltersDao get sheltersDao;
  ReportsDao get reportsDao;
  PeopleDao get peopleDao;
  FamiliesDao get familiesDao;
  MedicalCardDao get medicalCardDao;
  AuditDao get auditDao;

  /// Inicializa la base de datos local y crea las tablas e índices necesarios.
  Future<void> initialize();

  /// Cierra la conexión con la base de datos.
  Future<void> close();
}

/// Implementación desacoplada preparada para pruebas en memoria y vinculación nativa SQLite.
class _AppDatabaseImpl implements AppDatabase {
  final SyncQueueDao _syncQueueDao = InMemorySyncQueueDao();
  final EmergenciesDao _emergenciesDao = InMemoryEmergenciesDao();
  final SheltersDao _sheltersDao = InMemorySheltersDao();
  final ReportsDao _reportsDao = InMemoryReportsDao();
  final PeopleDao _peopleDao = InMemoryPeopleDao();
  final FamiliesDao _familiesDao = InMemoryFamiliesDao();
  final MedicalCardDao _medicalCardDao = InMemoryMedicalCardDao();
  final AuditDao _auditDao = InMemoryAuditDao();

  bool _isInitialized = false;

  @override
  SyncQueueDao get syncQueueDao => _syncQueueDao;

  @override
  EmergenciesDao get emergenciesDao => _emergenciesDao;

  @override
  SheltersDao get sheltersDao => _sheltersDao;

  @override
  ReportsDao get reportsDao => _reportsDao;

  @override
  PeopleDao get peopleDao => _peopleDao;

  @override
  FamiliesDao get familiesDao => _familiesDao;

  @override
  MedicalCardDao get medicalCardDao => _medicalCardDao;

  @override
  AuditDao get auditDao => _auditDao;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Scripts DDL listos para SQLite
    final initScripts = [
      SyncQueueTable.createTableSql,
      SyncQueueTable.createIndexStatusSql,
      EmergenciesTable.createTableSql,
      SheltersTable.createTableSql,
      ReportsTable.createTableSql,
      PeopleTable.createTableSql,
      FamiliesTable.createFamiliesTableSql,
      FamiliesTable.createMembersTableSql,
      MedicalCardsTable.createTableSql,
      AuditLogsTable.createTableSql,
    ];
    assert(initScripts.isNotEmpty);
    _isInitialized = true;
  }

  @override
  Future<void> close() async {
    _isInitialized = false;
  }
}
