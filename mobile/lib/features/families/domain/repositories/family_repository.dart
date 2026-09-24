import '../models/family_group.dart';

abstract class FamilyRepository {
  Future<FamilyGroup?> getFamilyGroup(String familyId, {bool forceRefresh = false});
  Future<FamilyGroup?> getPrimaryFamily();
  Future<void> saveFamilyGroup(FamilyGroup group);
  Future<void> updateMemberStatus(String familyId, String memberId, {required bool isSafe, required String status, required int batteryLevel, required String location});
  Future<void> syncFamily();
}
