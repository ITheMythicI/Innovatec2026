import 'dart:convert';
import 'package:innovatec_mobile/database/app_database.dart';
import 'package:innovatec_mobile/features/user_profile/domain/models/user_profile.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfile?> getUserProfile();
  Future<void> saveUserProfile(UserProfile profile);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final AppDatabase _database;

  ProfileLocalDataSourceImpl({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  @override
  Future<UserProfile?> getUserProfile() async {
    final raw = await _database.medicalCardDao.getPrimaryCard();
    if (raw == null) return null;
    return UserProfile.fromJson(raw);
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    final map = {
      'id': profile.userId,
      'full_name': profile.fullName,
      'blood_type': profile.bloodType,
      'allergies_json': json.encode(profile.allergies),
      'chronic_conditions_json': json.encode(profile.chronicConditions),
      'current_medications_json': json.encode(profile.vitalMedications),
      'emergency_contacts_json': json.encode(profile.emergencyContacts.map((c) => c.toJson()).toList()),
      'organ_donor': profile.isOrganDonor ? 1 : 0,
      'last_updated': profile.lastUpdated.toUtc().toIso8601String(),
      'userId': profile.userId,
      'fullName': profile.fullName,
      'age': profile.age,
      'bloodType': profile.bloodType,
      'allergies': profile.allergies,
      'chronicConditions': profile.chronicConditions,
      'vitalMedications': profile.vitalMedications,
      'isOrganDonor': profile.isOrganDonor,
      'emergencyContacts': profile.emergencyContacts.map((c) => c.toJson()).toList(),
      'lastUpdated': profile.lastUpdated.toUtc().toIso8601String(),
    };
    await _database.medicalCardDao.saveMedicalCard(map);
  }
}
