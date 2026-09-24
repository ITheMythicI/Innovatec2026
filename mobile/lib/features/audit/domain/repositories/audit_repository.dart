import '../models/audit_log_entry.dart';

abstract class AuditRepository {
  Future<List<AuditLogEntry>> getLogs({int limit = 100});
  Future<void> recordLog(AuditLogEntry entry);
  Future<void> syncLogs();
}
