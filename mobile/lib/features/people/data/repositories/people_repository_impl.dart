import 'package:innovatec_mobile/sync/sync_manager.dart';
import 'package:innovatec_mobile/features/people/domain/models/person_report.dart';
import 'package:innovatec_mobile/features/people/domain/repositories/people_repository.dart';
import 'package:innovatec_mobile/features/people/data/datasources/people_local_datasource.dart';
import 'package:innovatec_mobile/features/people/data/datasources/people_remote_datasource.dart';

class PeopleRepositoryImpl implements PeopleRepository {
  final PeopleLocalDataSource _localDataSource;
  final PeopleRemoteDataSource _remoteDataSource;
  final SyncManager _syncManager;

  PeopleRepositoryImpl({
    PeopleLocalDataSource? localDataSource,
    PeopleRemoteDataSource? remoteDataSource,
    SyncManager? syncManager,
  })  : _localDataSource = localDataSource ?? PeopleLocalDataSourceImpl(),
        _remoteDataSource = remoteDataSource ?? PeopleRemoteDataSourceImpl(),
        _syncManager = syncManager ?? SyncManager.instance;

  @override
  Future<List<PersonReport>> getPersonReports({
    String? query,
    PersonReportType? type,
    bool? minorsOnly,
    bool forceRefresh = false,
  }) async {
    final localList = await _localDataSource.getPersonReports(query: query, type: type, minorsOnly: minorsOnly);
    if (localList.isNotEmpty && !forceRefresh) {
      _refreshRemote();
      return localList;
    }

    try {
      final remoteList = await _remoteDataSource.getPersonReports();
      if (remoteList.isNotEmpty) {
        await _localDataSource.saveReports(remoteList);
        return await _localDataSource.getPersonReports(query: query, type: type, minorsOnly: minorsOnly);
      }
    } catch (_) {}

    return localList;
  }

  void _refreshRemote() async {
    try {
      final remoteList = await _remoteDataSource.getPersonReports();
      if (remoteList.isNotEmpty) {
        await _localDataSource.saveReports(remoteList);
      }
    } catch (_) {}
  }

  @override
  Future<PersonReport?> getReportById(String id) async {
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
  Future<PersonReport> createPersonReport(PersonReport report) async {
    await _localDataSource.saveReport(report);
    await _syncManager.enqueueLocalMutation(
      entityType: 'person_report',
      entityId: report.id,
      operation: 'CREATE',
      payload: report.toJson(),
    );
    return report;
  }

  @override
  Future<PersonReport> updateReportVerification(PersonReport report) async {
    await _localDataSource.saveReport(report);
    await _syncManager.enqueueLocalMutation(
      entityType: 'person_report',
      entityId: report.id,
      operation: 'UPDATE',
      payload: report.toJson(),
    );
    return report;
  }

  @override
  Future<void> syncReports() async {
    await _syncManager.synchronizePendingEvents();
    final remoteList = await _remoteDataSource.getPersonReports();
    await _localDataSource.saveReports(remoteList);
  }
}
