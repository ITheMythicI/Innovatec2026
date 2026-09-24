import 'package:innovatec_mobile/sync/sync_manager.dart';
import 'package:innovatec_mobile/features/audit/domain/models/audit_log_entry.dart';
import 'package:innovatec_mobile/features/audit/domain/repositories/audit_repository.dart';
import 'package:innovatec_mobile/features/audit/data/datasources/audit_local_datasource.dart';
import 'package:innovatec_mobile/features/audit/data/datasources/audit_remote_datasource.dart';

class AuditRepositoryImpl implements AuditRepository {
  final AuditLocalDataSource _localDataSource;
  final AuditRemoteDataSource _remoteDataSource;
  final SyncManager _syncManager;

  AuditRepositoryImpl({
    AuditLocalDataSource? localDataSource,
    AuditRemoteDataSource? remoteDataSource,
    SyncManager? syncManager,
  })  : _localDataSource = localDataSource ?? AuditLocalDataSourceImpl(),
        _remoteDataSource = remoteDataSource ?? AuditRemoteDataSourceImpl(),
        _syncManager = syncManager ?? SyncManager.instance;

  @override
  Future<List<AuditLogEntry>> getLogs({int limit = 100}) async {
    return _localDataSource.getLogs(limit: limit);
  }

  @override
  Future<void> recordLog(AuditLogEntry entry) async {
    await _localDataSource.saveLog(entry);
    await _syncManager.enqueueLocalMutation(
      entityType: 'audit_log',
      entityId: entry.id,
      operation: 'CREATE',
      payload: entry.toJson(),
    );
  }

  @override
  Future<void> syncLogs() async {
    await _syncManager.synchronizePendingEvents();
  }
}
