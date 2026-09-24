import 'package:innovatec_mobile/core/network/api_client.dart';
import 'package:innovatec_mobile/features/families/domain/models/family_group.dart';

abstract class FamilyRemoteDataSource {
  Future<FamilyGroup?> getFamilyById(String id);
  Future<void> syncFamily(FamilyGroup group);
}

class FamilyRemoteDataSourceImpl implements FamilyRemoteDataSource {
  final ApiClient _apiClient;

  FamilyRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<FamilyGroup?> getFamilyById(String id) async {
    try {
      final response = await _apiClient.get('/families/$id');
      return FamilyGroup.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> syncFamily(FamilyGroup group) async {
    await _apiClient.post('/families', body: group.toJson());
  }
}
