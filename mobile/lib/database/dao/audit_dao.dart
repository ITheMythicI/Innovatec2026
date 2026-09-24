import '../tables/audit_logs_table.dart';

abstract class AuditDao {
  Future<void> insertLog(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getLogs({int limit = 100});
  Future<void> clear();
}

class InMemoryAuditDao implements AuditDao {
  final List<Map<String, dynamic>> _storage = [];

  @override
  Future<void> insertLog(Map<String, dynamic> data) async {
    _storage.insert(0, Map<String, dynamic>.from(data));
  }

  @override
  Future<List<Map<String, dynamic>>> getLogs({int limit = 100}) async {
    return _storage.take(limit).toList();
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }
}
