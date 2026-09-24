import 'package:innovatec_mobile/database/app_database.dart';
import 'package:innovatec_mobile/features/audit/domain/models/audit_log_entry.dart';

abstract class AuditLocalDataSource {
  Future<List<AuditLogEntry>> getLogs({int limit = 100});
  Future<void> saveLog(AuditLogEntry entry);
}

class AuditLocalDataSourceImpl implements AuditLocalDataSource {
  final AppDatabase _database;

  AuditLocalDataSourceImpl({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  @override
  Future<List<AuditLogEntry>> getLogs({int limit = 100}) async {
    final rawList = await _database.auditDao.getLogs(limit: limit);
    return rawList.map((e) => AuditLogEntry.fromJson(e)).toList();
  }

  @override
  Future<void> saveLog(AuditLogEntry entry) async {
    await _database.auditDao.insertLog(entry.toDatabaseMap());
  }
}
