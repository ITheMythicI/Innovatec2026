import '../tables/reports_table.dart';

abstract class ReportsDao {
  Future<void> insertOrUpdate(Map<String, dynamic> data);
  Future<void> insertOrUpdateAll(List<Map<String, dynamic>> list);
  Future<List<Map<String, dynamic>>> getAll({String? status, String? category, String? emergencyId});
  Future<Map<String, dynamic>?> getById(String id);
  Future<void> deleteById(String id);
  Future<void> clear();
}

class InMemoryReportsDao implements ReportsDao {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> insertOrUpdate(Map<String, dynamic> data) async {
    final id = data[ReportsTable.columnId] as String;
    _storage[id] = Map<String, dynamic>.from(data);
  }

  @override
  Future<void> insertOrUpdateAll(List<Map<String, dynamic>> list) async {
    for (final item in list) {
      await insertOrUpdate(item);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAll({String? status, String? category, String? emergencyId}) async {
    var result = _storage.values.toList();
    if (status != null && status.isNotEmpty) {
      result = result.where((e) => e[ReportsTable.columnStatus] == status).toList();
    }
    if (category != null && category.isNotEmpty) {
      result = result.where((e) => e[ReportsTable.columnCategory] == category).toList();
    }
    if (emergencyId != null && emergencyId.isNotEmpty) {
      result = result.where((e) => e[ReportsTable.columnEmergencyId] == emergencyId).toList();
    }
    result.sort((a, b) {
      final aDate = a[ReportsTable.columnCreatedAt] ?? '';
      final bDate = b[ReportsTable.columnCreatedAt] ?? '';
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
