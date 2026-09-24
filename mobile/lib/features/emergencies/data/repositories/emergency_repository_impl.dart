import 'package:innovatec_mobile/sync/sync_manager.dart';
import 'package:innovatec_mobile/features/emergencies/domain/models/emergency.dart';
import 'package:innovatec_mobile/features/emergencies/domain/repositories/emergency_repository.dart';
import 'package:innovatec_mobile/features/emergencies/data/datasources/emergency_local_datasource.dart';
import 'package:innovatec_mobile/features/emergencies/data/datasources/emergency_remote_datasource.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  final EmergencyLocalDataSource _localDataSource;
  final EmergencyRemoteDataSource _remoteDataSource;
  final SyncManager _syncManager;

  EmergencyRepositoryImpl({
    EmergencyLocalDataSource? localDataSource,
    EmergencyRemoteDataSource? remoteDataSource,
    SyncManager? syncManager,
  })  : _localDataSource = localDataSource ?? EmergencyLocalDataSourceImpl(),
        _remoteDataSource = remoteDataSource ?? EmergencyRemoteDataSourceImpl(),
        _syncManager = syncManager ?? SyncManager.instance;

  @override
  Future<List<Emergency>> getEmergencies({
    EmergencyStatus? status,
    EmergencySeverity? severity,
    bool forceRefresh = false,
  }) async {
    final localData = await _localDataSource.getEmergencies(status: status, severity: severity);

    if (localData.isNotEmpty && !forceRefresh) {
      _refreshRemote(status: status, severity: severity);
      return localData;
    }

    try {
      final remoteList = await _remoteDataSource.getEmergencies(status: status, severity: severity);
      if (remoteList.isNotEmpty) {
        await _localDataSource.saveEmergencies(remoteList);
        return remoteList;
      }
    } catch (_) {}

    return localData;
  }

  void _refreshRemote({EmergencyStatus? status, EmergencySeverity? severity}) async {
    try {
      final remoteList = await _remoteDataSource.getEmergencies(status: status, severity: severity);
      if (remoteList.isNotEmpty) {
        await _localDataSource.saveEmergencies(remoteList);
      }
    } catch (_) {}
  }

  @override
  Future<Emergency?> getEmergencyById(String id) async {
    final local = await _localDataSource.getEmergencyById(id);
    if (local != null) return local;

    try {
      final remote = await _remoteDataSource.getEmergencyById(id);
      await _localDataSource.saveEmergency(remote);
      return remote;
    } catch (_) {
      return local;
    }
  }

  @override
  Future<Emergency> createEmergency(Emergency emergency) async {
    final localEmergency = Emergency(
      id: emergency.id,
      title: emergency.title,
      description: emergency.description,
      type: emergency.type,
      severity: emergency.severity,
      status: emergency.status,
      latitude: emergency.latitude,
      longitude: emergency.longitude,
      radiusMeters: emergency.radiusMeters,
      startedAt: emergency.startedAt,
      endedAt: emergency.endedAt,
      createdAt: emergency.createdAt,
      updatedAt: emergency.updatedAt,
      syncStatus: 'pending_create',
    );
    await _localDataSource.saveEmergency(localEmergency);

    await _syncManager.enqueueLocalMutation(
      entityType: 'emergency',
      entityId: emergency.id,
      operation: 'CREATE',
      payload: emergency.toJson(),
    );

    return localEmergency;
  }

  @override
  Future<Emergency> updateEmergency(Emergency emergency) async {
    final updated = Emergency(
      id: emergency.id,
      title: emergency.title,
      description: emergency.description,
      type: emergency.type,
      severity: emergency.severity,
      status: emergency.status,
      latitude: emergency.latitude,
      longitude: emergency.longitude,
      radiusMeters: emergency.radiusMeters,
      startedAt: emergency.startedAt,
      endedAt: emergency.endedAt,
      createdAt: emergency.createdAt,
      updatedAt: DateTime.now().toUtc(),
      syncStatus: 'pending_update',
    );

    await _localDataSource.saveEmergency(updated);
    await _syncManager.enqueueLocalMutation(
      entityType: 'emergency',
      entityId: emergency.id,
      operation: 'UPDATE',
      payload: updated.toJson(),
    );

    return updated;
  }

  @override
  Future<void> syncEmergencies() async {
    await _syncManager.synchronizePendingEvents();
    final remoteList = await _remoteDataSource.getEmergencies();
    await _localDataSource.saveEmergencies(remoteList);
  }
}
