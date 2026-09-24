import 'package:innovatec_mobile/core/network/api_client.dart';
import 'package:innovatec_mobile/features/user_profile/domain/models/user_profile.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfile?> getUserProfile(String userId);
  Future<void> syncProfile(UserProfile profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _apiClient.get('/people/$userId');
      return UserProfile.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> syncProfile(UserProfile profile) async {
    await _apiClient.post('/people', body: profile.toJson());
  }
}
