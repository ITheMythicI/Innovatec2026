import 'package:innovatec_mobile/core/network/api_client.dart';
import 'package:innovatec_mobile/features/emergencies/domain/models/emergency.dart';

abstract class EmergencyRemoteDataSource {
  Future<List<Emergency>> getEmergencies({EmergencyStatus? status, EmergencySeverity? severity});
  Future<Emergency> getEmergencyById(String id);
  Future<Emergency> createEmergency(Emergency emergency);
  Future<Emergency> updateEmergency(Emergency emergency);
}

class EmergencyRemoteDataSourceImpl implements EmergencyRemoteDataSource {
  final ApiClient _apiClient;

  EmergencyRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<List<Emergency>> getEmergencies({EmergencyStatus? status, EmergencySeverity? severity}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status.toBackendString();
    if (severity != null) queryParams['severity'] = severity.toBackendString();

    final response = await _apiClient.get('/emergencies', queryParams: queryParams);
    if (response is List) {
      return response.map((item) => Emergency.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<Emergency> getEmergencyById(String id) async {
    final response = await _apiClient.get('/emergencies/$id');
    return Emergency.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Emergency> createEmergency(Emergency emergency) async {
    final response = await _apiClient.post('/emergencies', body: emergency.toJson());
    return Emergency.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Emergency> updateEmergency(Emergency emergency) async {
    final response = await _apiClient.patch('/emergencies/${emergency.id}', body: emergency.toJson());
    return Emergency.fromJson(response as Map<String, dynamic>);
  }
}
