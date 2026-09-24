import '../tables/families_table.dart';

abstract class FamiliesDao {
  Future<void> insertOrUpdateFamily(Map<String, dynamic> familyData);
  Future<void> insertOrUpdateMembers(String familyId, List<Map<String, dynamic>> members);
  Future<Map<String, dynamic>?> getFamilyWithMembers(String familyId);
  Future<List<Map<String, dynamic>>> getAllFamilies();
  Future<void> updateMemberStatus(String memberId, {required bool isSafe, required String status, required int batteryLevel, required String location});
  Future<void> clear();
}

class InMemoryFamiliesDao implements FamiliesDao {
  final Map<String, Map<String, dynamic>> _families = {};
  final Map<String, List<Map<String, dynamic>>> _members = {};

  @override
  Future<void> insertOrUpdateFamily(Map<String, dynamic> familyData) async {
    final id = familyData[FamiliesTable.columnId] as String;
    _families[id] = Map<String, dynamic>.from(familyData);
  }

  @override
  Future<void> insertOrUpdateMembers(String familyId, List<Map<String, dynamic>> members) async {
    _members[familyId] = members.map((m) => Map<String, dynamic>.from(m)).toList();
  }

  @override
  Future<Map<String, dynamic>?> getFamilyWithMembers(String familyId) async {
    final family = _families[familyId];
    if (family == null) return null;
    final copy = Map<String, dynamic>.from(family);
    copy['members'] = (_members[familyId] ?? []).map((m) => Map<String, dynamic>.from(m)).toList();
    return copy;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllFamilies() async {
    final list = <Map<String, dynamic>>[];
    for (final famId in _families.keys) {
      final fam = await getFamilyWithMembers(famId);
      if (fam != null) list.add(fam);
    }
    return list;
  }

  @override
  Future<void> updateMemberStatus(
    String memberId, {
    required bool isSafe,
    required String status,
    required int batteryLevel,
    required String location,
  }) async {
    for (final famId in _members.keys) {
      final membersList = _members[famId]!;
      for (int i = 0; i < membersList.length; i++) {
        if (membersList[i][FamiliesTable.columnMemberId] == memberId) {
          membersList[i][FamiliesTable.columnMemberIsSafe] = isSafe ? 1 : 0;
          membersList[i][FamiliesTable.columnMemberStatus] = status;
          membersList[i][FamiliesTable.columnMemberBatteryLevel] = batteryLevel;
          membersList[i][FamiliesTable.columnMemberLocation] = location;
          membersList[i][FamiliesTable.columnMemberLastCheckIn] = DateTime.now().toUtc().toIso8601String();
          return;
        }
      }
    }
  }

  @override
  Future<void> clear() async {
    _families.clear();
    _members.clear();
  }
}
