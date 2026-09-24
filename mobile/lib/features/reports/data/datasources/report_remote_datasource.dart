import 'package:innovatec_mobile/core/network/api_client.dart';
import 'package:innovatec_mobile/features/reports/domain/models/report.dart';

abstract class ReportRemoteDataSource {
  Future<List<Report>> getReports({ReportStatus? status, ReportCategory? category, String? emergencyId});
  Future<Report> getReportById(String id);
  Future<Report> createReport(Report report);
  Future<Report> updateReportStatus(String reportId, ReportStatus status);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiClient _apiClient;

  ReportRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<List<Report>> getReports({ReportStatus? status, ReportCategory? category, String? emergencyId}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status.toBackendString();
    if (category != null) queryParams['category'] = category.toBackendString();
    if (emergencyId != null) queryParams['emergencyId'] = emergencyId;

    final response = await _apiClient.get('/reports', queryParams: queryParams);
    if (response is List) {
      return response.map((item) => Report.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<Report> getReportById(String id) async {
    final response = await _apiClient.get('/reports/$id');
    return Report.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Report> createReport(Report report) async {
    final response = await _apiClient.post('/reports', body: report.toCreatePayload());
    return Report.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Report> updateReportStatus(String reportId, ReportStatus status) async {
    final response = await _apiClient.patch('/reports/$reportId/status', body: {
      'status': status.toBackendString(),
    });
    return Report.fromJson(response as Map<String, dynamic>);
  }
}
