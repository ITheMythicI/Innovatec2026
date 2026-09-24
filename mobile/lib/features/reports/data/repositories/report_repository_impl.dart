import 'package:innovatec_mobile/sync/sync_manager.dart';
import 'package:innovatec_mobile/features/reports/domain/models/report.dart';
import 'package:innovatec_mobile/features/reports/domain/repositories/report_repository.dart';
import 'package:innovatec_mobile/features/reports/data/datasources/report_local_datasource.dart';
import 'package:innovatec_mobile/features/reports/data/datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportLocalDataSource _localDataSource;
  final ReportRemoteDataSource _remoteDataSource;
  final SyncManager _syncManager;

  ReportRepositoryImpl({
    ReportLocalDataSource? localDataSource,
    ReportRemoteDataSource? remoteDataSource,
    SyncManager? syncManager,
  })  : _localDataSource = localDataSource ?? ReportLocalDataSourceImpl(),
        _remoteDataSource = remoteDataSource ?? ReportRemoteDataSourceImpl(),
        _syncManager = syncManager ?? SyncManager.instance;

  @override
  Future<List<Report>> getReports({
    ReportStatus? status,
    ReportCategory? category,
    String? emergencyId,
    bool forceRefresh = false,
  }) async {
    final localList = await _localDataSource.getReports(status: status, category: category, emergencyId: emergencyId);
    if (localList.isNotEmpty && !forceRefresh) {
      _refreshRemote(status: status, category: category, emergencyId: emergencyId);
      return localList;
    }

    try {
      final remoteList = await _remoteDataSource.getReports(status: status, category: category, emergencyId: emergencyId);
      if (remoteList.isNotEmpty) {
        await _localDataSource.saveReports(remoteList);
        return remoteList;
      }
    } catch (_) {}

    return localList;
  }

  void _refreshRemote({ReportStatus? status, ReportCategory? category, String? emergencyId}) async {
    try {
      final remoteList = await _remoteDataSource.getReports(status: status, category: category, emergencyId: emergencyId);
      if (remoteList.isNotEmpty) {
        await _localDataSource.saveReports(remoteList);
      }
    } catch (_) {}
  }

  @override
  Future<Report?> getReportById(String id) async {
    final local = await _localDataSource.getReportById(id);
    if (local != null) return local;

    try {
      final remote = await _remoteDataSource.getReportById(id);
      await _localDataSource.saveReport(remote);
      return remote;
    } catch (_) {
      return local;
    }
  }

  @override
  Future<Report> createReport(Report report) async {
    final localReport = Report(
      id: report.id,
      reporterUserId: report.reporterUserId,
      reporterName: report.reporterName,
      reporterContact: report.reporterContact,
      emergencyId: report.emergencyId,
      title: report.title,
      description: report.description,
      category: report.category,
      priority: report.priority,
      status: report.status,
      latitude: report.latitude,
      longitude: report.longitude,
      address: report.address,
      createdAt: report.createdAt,
      updatedAt: report.updatedAt,
      syncStatus: 'pending_create',
    );

    await _localDataSource.saveReport(localReport);
    await _syncManager.enqueueLocalMutation(
      entityType: 'report',
      entityId: report.id,
      operation: 'CREATE',
      payload: report.toJson(),
    );

    return localReport;
  }

  @override
  Future<Report> updateReportStatus(String reportId, ReportStatus status) async {
    final existing = await getReportById(reportId);
    final updated = Report(
      id: reportId,
      reporterUserId: existing?.reporterUserId,
      reporterName: existing?.reporterName,
      reporterContact: existing?.reporterContact,
      emergencyId: existing?.emergencyId,
      title: existing?.title ?? 'Reporte',
      description: existing?.description ?? '',
      category: existing?.category ?? ReportCategory.other,
      priority: existing?.priority ?? ReportPriority.medium,
      status: status,
      latitude: existing?.latitude,
      longitude: existing?.longitude,
      address: existing?.address,
      createdAt: existing?.createdAt ?? DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
      syncStatus: 'pending_update',
    );

    await _localDataSource.saveReport(updated);
    await _syncManager.enqueueLocalMutation(
      entityType: 'report',
      entityId: reportId,
      operation: 'UPDATE',
      payload: {'status': status.toBackendString()},
    );

    return updated;
  }

  @override
  Future<void> syncReports() async {
    await _syncManager.synchronizePendingEvents();
    final remoteList = await _remoteDataSource.getReports();
    await _localDataSource.saveReports(remoteList);
  }
}
