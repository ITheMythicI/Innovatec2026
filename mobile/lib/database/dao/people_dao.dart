import '../tables/people_table.dart';

abstract class PeopleDao {
  Future<void> insertOrUpdate(Map<String, dynamic> data);
  Future<void> insertOrUpdateAll(List<Map<String, dynamic>> list);
  Future<List<Map<String, dynamic>>> getAll({String? query, String? type, bool? minorsOnly});
  Future<Map<String, dynamic>?> getById(String id);
  Future<void> deleteById(String id);
  Future<void> clear();
}

class InMemoryPeopleDao implements PeopleDao {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> insertOrUpdate(Map<String, dynamic> data) async {
    final id = data[PeopleTable.columnId] as String;
    _storage[id] = Map<String, dynamic>.from(data);
  }

  @override
  Future<void> insertOrUpdateAll(List<Map<String, dynamic>> list) async {
    for (final item in list) {
      await insertOrUpdate(item);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAll({String? query, String? type, bool? minorsOnly}) async {
    var result = _storage.values.toList();
    if (type != null && type.isNotEmpty) {
      result = result.where((e) => e[PeopleTable.columnType] == type).toList();
    }
    if (minorsOnly == true) {
      result = result.where((e) => (e[PeopleTable.columnIsMinor] == 1 || e[PeopleTable.columnIsMinor] == true)).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((e) {
        final name = (e[PeopleTable.columnFullName] ?? '').toString().toLowerCase();
        final desc = (e[PeopleTable.columnPhysicalDescription] ?? '').toString().toLowerCase();
        final loc = (e[PeopleTable.columnLastKnownLocation] ?? '').toString().toLowerCase();
        final shelter = (e[PeopleTable.columnCurrentShelterName] ?? '').toString().toLowerCase();
        return name.contains(q) || desc.contains(q) || loc.contains(q) || shelter.contains(q);
      }).toList();
    }
    result.sort((a, b) {
      final aDate = a[PeopleTable.columnUpdatedAt] ?? '';
      final bDate = b[PeopleTable.columnUpdatedAt] ?? '';
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
