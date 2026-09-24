import 'package:innovatec_mobile/sync/sync_manager.dart';
import 'package:innovatec_mobile/features/families/domain/models/family_group.dart';
import 'package:innovatec_mobile/features/families/domain/repositories/family_repository.dart';
import 'package:innovatec_mobile/features/families/data/datasources/family_local_datasource.dart';
import 'package:innovatec_mobile/features/families/data/datasources/family_remote_datasource.dart';

class FamilyRepositoryImpl implements FamilyRepository {
  final FamilyLocalDataSource _localDataSource;
  final FamilyRemoteDataSource _remoteDataSource;
  final SyncManager _syncManager;

  FamilyRepositoryImpl({
    FamilyLocalDataSource? localDataSource,
    FamilyRemoteDataSource? remoteDataSource,
    SyncManager? syncManager,
  })  : _localDataSource = localDataSource ?? FamilyLocalDataSourceImpl(),
        _remoteDataSource = remoteDataSource ?? FamilyRemoteDataSourceImpl(),
        _syncManager = syncManager ?? SyncManager.instance;

  @override
  Future<FamilyGroup?> getFamilyGroup(String familyId, {bool forceRefresh = false}) async {
    final local = await _localDataSource.getFamilyGroup(familyId);
    if (local != null && !forceRefresh) return local;

    try {
      final remote = await _remoteDataSource.getFamilyById(familyId);
      if (remote != null) {
        await _localDataSource.saveFamilyGroup(remote);
        return remote;
      }
    } catch (_) {}

    return local;
  }

  @override
  Future<FamilyGroup?> getPrimaryFamily() async {
    return _localDataSource.getPrimaryFamily();
  }

  @override
  Future<void> saveFamilyGroup(FamilyGroup group) async {
    await _localDataSource.saveFamilyGroup(group);
    await _syncManager.enqueueLocalMutation(
      entityType: 'family',
      entityId: group.id,
      operation: 'UPDATE',
      payload: group.toJson(),
    );
  }

  @override
  Future<void> updateMemberStatus(
    String familyId,
    String memberId, {
    required bool isSafe,
    required String status,
    required int batteryLevel,
    required String location,
  }) async {
    await _localDataSource.updateMemberStatus(
      memberId,
      isSafe: isSafe,
      status: status,
      batteryLevel: batteryLevel,
      location: location,
    );

    await _syncManager.enqueueLocalMutation(
      entityType: 'family_member_status',
      entityId: memberId,
      operation: 'UPDATE',
      payload: {
        'familyId': familyId,
        'memberId': memberId,
        'isSafe': isSafe,
        'status': status,
        'batteryLevel': batteryLevel,
        'location': location,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      },
    );
  }

  @override
  Future<void> syncFamily() async {
    await _syncManager.synchronizePendingEvents();
  }
}
