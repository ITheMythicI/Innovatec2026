import '../tables/shelters_table.dart';

abstract class SheltersDao {
  Future<void> insertOrUpdate(Map<String, dynamic> data);
  Future<void> insertOrUpdateAll(List<Map<String, dynamic>> list);
  Future<List<Map<String, dynamic>>> getAll({String? status, bool? onlyAvailable});
  Future<Map<String, dynamic>?> getById(String id);
  Future<void> deleteById(String id);
  Future<void> clear();
}

class InMemorySheltersDao implements SheltersDao {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> insertOrUpdate(Map<String, dynamic> data) async {
    final id = data[SheltersTable.columnId] as String;
    _storage[id] = Map<String, dynamic>.from(data);
  }

  @override
  Future<void> insertOrUpdateAll(List<Map<String, dynamic>> list) async {
    for (final item in list) {
      await insertOrUpdate(item);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAll({String? status, bool? onlyAvailable}) async {
    var result = _storage.values.toList();
    if (status != null && status.isNotEmpty) {
      result = result.where((e) => e[SheltersTable.columnStatus] == status).toList();
    }
    if (onlyAvailable == true) {
      result = result.where((e) {
        final cap = (e[SheltersTable.columnCapacity] as num?)?.toInt() ?? 0;
        final occ = (e[SheltersTable.columnCurrentOccupancy] as num?)?.toInt() ?? 0;
        return (cap - occ) > 0;
      }).toList();
    }
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
