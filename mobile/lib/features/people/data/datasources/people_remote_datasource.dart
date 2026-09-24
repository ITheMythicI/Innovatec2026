import 'package:innovatec_mobile/core/network/api_client.dart';
import 'package:innovatec_mobile/features/people/domain/models/person_report.dart';

abstract class PeopleRemoteDataSource {
  Future<List<PersonReport>> getPersonReports();
  Future<PersonReport> getReportById(String id);
  Future<PersonReport> createPersonReport(PersonReport report);
}

class PeopleRemoteDataSourceImpl implements PeopleRemoteDataSource {
  final ApiClient _apiClient;

  PeopleRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<List<PersonReport>> getPersonReports() async {
    final response = await _apiClient.get('/people');
    if (response is List) {
      return response.map((item) {
        final map = item as Map<String, dynamic>;
        return PersonReport(
          id: map['id'] as String,
          type: PersonReportType.missing,
          fullName: '${map['first_name'] ?? map['firstName'] ?? ''} ${map['last_name'] ?? map['lastName'] ?? ''}'.trim(),
          age: 30,
          isMinor: false,
          gender: map['gender'] as String? ?? 'Desconocido',
          physicalDescription: map['medical_notes'] as String? ?? 'Sin descripción adicional',
          lastKnownLocation: 'Zona de Emergencia',
          contactPhone: 'No disponible',
          reporterName: 'Registro Central',
          reporterRelationship: 'Oficial',
          status: VerificationStatus.verifiedByAuthority,
          createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
          updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
        );
      }).toList();
    }
    return [];
  }

  @override
  Future<PersonReport> getReportById(String id) async {
    final response = await _apiClient.get('/people/$id');
    final map = response as Map<String, dynamic>;
    return PersonReport(
      id: map['id'] as String,
      type: PersonReportType.missing,
      fullName: '${map['first_name'] ?? map['firstName'] ?? ''} ${map['last_name'] ?? map['lastName'] ?? ''}'.trim(),
      age: 30,
      isMinor: false,
      gender: map['gender'] as String? ?? 'Desconocido',
      physicalDescription: map['medical_notes'] as String? ?? '',
      lastKnownLocation: 'Zona de Emergencia',
      contactPhone: 'No disponible',
      reporterName: 'Registro Central',
      reporterRelationship: 'Oficial',
      status: VerificationStatus.verifiedByAuthority,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
    );
  }

  @override
  Future<PersonReport> createPersonReport(PersonReport report) async {
    final response = await _apiClient.post('/people', body: report.toJson());
    return PersonReport.fromJson(response as Map<String, dynamic>);
  }
}
