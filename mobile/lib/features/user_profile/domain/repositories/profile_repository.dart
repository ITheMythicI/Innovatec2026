import '../models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getUserProfile();
  Future<void> saveUserProfile(UserProfile profile);
  Future<void> syncProfile();
}
