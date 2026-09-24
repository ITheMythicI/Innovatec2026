import 'package:innovatec_mobile/core/network/api_client.dart';
import 'package:innovatec_mobile/features/shelters/domain/models/shelter.dart';

abstract class ShelterRemoteDataSource {
  Future<List<Shelter>> getShelters({ShelterStatus? status, bool? onlyAvailable});
  Future<Shelter> getShelterById(String id);
  Future<Shelter> createShelter(Shelter shelter);
  Future<Shelter> updateShelter(Shelter shelter);
}

class ShelterRemoteDataSourceImpl implements ShelterRemoteDataSource {
  final ApiClient _apiClient;

  ShelterRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<List<Shelter>> getShelters({ShelterStatus? status, bool? onlyAvailable}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status.toBackendString();
    if (onlyAvailable != null) queryParams['onlyAvailable'] = onlyAvailable;

    final response = await _apiClient.get('/shelters', queryParams: queryParams);
    if (response is List) {
      return response.map((item) => Shelter.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<Shelter> getShelterById(String id) async {
    final response = await _apiClient.get('/shelters/$id');
    return Shelter.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Shelter> createShelter(Shelter shelter) async {
    final response = await _apiClient.post('/shelters', body: shelter.toJson());
    return Shelter.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Shelter> updateShelter(Shelter shelter) async {
    final response = await _apiClient.patch('/shelters/${shelter.id}', body: shelter.toJson());
    return Shelter.fromJson(response as Map<String, dynamic>);
  }
}
