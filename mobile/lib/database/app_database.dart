import 'dart:async';
import 'dao/sync_queue_dao.dart';
import 'tables/sync_queue_table.dart';

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
    _instance ??= _AppDatabaseStub();
    return _instance!;
  }

  /// Retorna el DAO para interactuar con la cola de sincronización.
  SyncQueueDao get syncQueueDao;

  /// Inicializa la base de datos local y crea las tablas e índices necesarios.
  Future<void> initialize();

  /// Cierra la conexión con SQLite.
  Future<void> close();
}

/// Implementación stub preparada para conectarse con `sqflite` o `drift` según decida el equipo.
class _AppDatabaseStub implements AppDatabase {
  final SyncQueueDao _syncQueueDao = InMemorySyncQueueDao();
  bool _isInitialized = false;

  @override
  SyncQueueDao get syncQueueDao => _syncQueueDao;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    // Scripts de inicialización listos para SQLite
    final initScripts = [
      SyncQueueTable.createTableSql,
      SyncQueueTable.createIndexStatusSql,
    ];
    // Cuando el equipo vincule `sqflite`, aquí se ejecutará db.execute(script)
    assert(initScripts.isNotEmpty);
    _isInitialized = true;
  }

  @override
  Future<void> close() async {
    _isInitialized = false;
  }
}
