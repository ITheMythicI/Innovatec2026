import '../tables/emergencies_table.dart';

abstract class EmergenciesDao {
  Future<void> insertOrUpdate(Map<String, dynamic> data);
  Future<void> insertOrUpdateAll(List<Map<String, dynamic>> list);
  Future<List<Map<String, dynamic>>> getAll({String? status, String? severity});
  Future<Map<String, dynamic>?> getById(String id);
  Future<void> deleteById(String id);
  Future<void> clear();
}

class InMemoryEmergenciesDao implements EmergenciesDao {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> insertOrUpdate(Map<String, dynamic> data) async {
    final id = data[EmergenciesTable.columnId] as String;
    _storage[id] = Map<String, dynamic>.from(data);
  }

  @override
  Future<void> insertOrUpdateAll(List<Map<String, dynamic>> list) async {
    for (final item in list) {
      await insertOrUpdate(item);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAll({String? status, String? severity}) async {
    var result = _storage.values.toList();
    if (status != null && status.isNotEmpty) {
      result = result.where((e) => e[EmergenciesTable.columnStatus] == status).toList();
    }
    if (severity != null && severity.isNotEmpty) {
      result = result.where((e) => e[EmergenciesTable.columnSeverity] == severity).toList();
    }
    result.sort((a, b) {
      final aDate = a[EmergenciesTable.columnStartedAt] ?? '';
      final bDate = b[EmergenciesTable.columnStartedAt] ?? '';
      return bDate.compareTo(aDate);
    });
    return result;
  }

  @override
  Future<Map<String, dynamic>?> getById(String id) async {
    return _storage[id];
  }

  @override
  Future<void> deleteById(String id) async {
    _storage.remove(id);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }
}
