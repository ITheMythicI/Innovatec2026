import 'package:innovatec_mobile/database/app_database.dart';
import 'package:innovatec_mobile/features/families/domain/models/family_group.dart';

abstract class FamilyLocalDataSource {
  Future<FamilyGroup?> getFamilyGroup(String familyId);
  Future<FamilyGroup?> getPrimaryFamily();
  Future<void> saveFamilyGroup(FamilyGroup group);
  Future<void> updateMemberStatus(String memberId, {required bool isSafe, required String status, required int batteryLevel, required String location});
}

class FamilyLocalDataSourceImpl implements FamilyLocalDataSource {
  final AppDatabase _database;

  FamilyLocalDataSourceImpl({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  @override
  Future<FamilyGroup?> getFamilyGroup(String familyId) async {
    final raw = await _database.familiesDao.getFamilyWithMembers(familyId);
    if (raw == null) return null;
    return FamilyGroup.fromJson(raw);
  }

  @override
  Future<FamilyGroup?> getPrimaryFamily() async {
    final all = await _database.familiesDao.getAllFamilies();
    if (all.isEmpty) return null;
    return FamilyGroup.fromJson(all.first);
  }

  @override
  Future<void> saveFamilyGroup(FamilyGroup group) async {
    await _database.familiesDao.insertOrUpdateFamily({
      'id': group.id,
      'family_name': group.familyName,
      'emergency_meeting_point': group.meetingPointLocation,
      'representative_contact': group.headOfHouseholdUserId,
      'notes': '',
      'last_status_update': DateTime.now().toUtc().toIso8601String(),
    });
    await _database.familiesDao.insertOrUpdateMembers(
      group.id,
      group.members.map((m) => m.toJson()).toList(),
    );
  }

  @override
  Future<void> updateMemberStatus(
    String memberId, {
    required bool isSafe,
    required String status,
    required int batteryLevel,
    required String location,
  }) async {
    await _database.familiesDao.updateMemberStatus(
      memberId,
      isSafe: isSafe,
      status: status,
      batteryLevel: batteryLevel,
      location: location,
    );
  }
}
