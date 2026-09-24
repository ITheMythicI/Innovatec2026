import 'package:innovatec_mobile/core/network/api_client.dart';
import 'package:innovatec_mobile/features/audit/domain/models/audit_log_entry.dart';

abstract class AuditRemoteDataSource {
  Future<void> sendLog(AuditLogEntry entry);
}

class AuditRemoteDataSourceImpl implements AuditRemoteDataSource {
  final ApiClient _apiClient;

  AuditRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<void> sendLog(AuditLogEntry entry) async {
    try {
      await _apiClient.post('/audit', body: entry.toJson());
    } catch (_) {}
  }
}
