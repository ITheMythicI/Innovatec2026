import 'package:innovatec_mobile/sync/sync_manager.dart';
import 'package:innovatec_mobile/features/shelters/domain/models/shelter.dart';
import 'package:innovatec_mobile/features/shelters/domain/repositories/shelter_repository.dart';
import 'package:innovatec_mobile/features/shelters/data/datasources/shelter_local_datasource.dart';
import 'package:innovatec_mobile/features/shelters/data/datasources/shelter_remote_datasource.dart';

class ShelterRepositoryImpl implements ShelterRepository {
  final ShelterLocalDataSource _localDataSource;
  final ShelterRemoteDataSource _remoteDataSource;
  final SyncManager _syncManager;

  ShelterRepositoryImpl({
    ShelterLocalDataSource? localDataSource,
    ShelterRemoteDataSource? remoteDataSource,
    SyncManager? syncManager,
  })  : _localDataSource = localDataSource ?? ShelterLocalDataSourceImpl(),
        _remoteDataSource = remoteDataSource ?? ShelterRemoteDataSourceImpl(),
        _syncManager = syncManager ?? SyncManager.instance;

  @override
  Future<List<Shelter>> getShelters({
    ShelterStatus? status,
    bool? onlyAvailable,
    bool forceRefresh = false,
  }) async {
    final localList = await _localDataSource.getShelters(status: status, onlyAvailable: onlyAvailable);
    if (localList.isNotEmpty && !forceRefresh) {
      _refreshRemote(status: status, onlyAvailable: onlyAvailable);
      return localList;
    }

    try {
      final remoteList = await _remoteDataSource.getShelters(status: status, onlyAvailable: onlyAvailable);
      if (remoteList.isNotEmpty) {
        await _localDataSource.saveShelters(remoteList);
        return remoteList;
      }
    } catch (_) {}

    return localList;
  }

  void _refreshRemote({ShelterStatus? status, bool? onlyAvailable}) async {
    try {
      final remoteList = await _remoteDataSource.getShelters(status: status, onlyAvailable: onlyAvailable);
      if (remoteList.isNotEmpty) {
        await _localDataSource.saveShelters(remoteList);
      }
    } catch (_) {}
  }

  @override
  Future<Shelter?> getShelterById(String id) async {
    final local = await _localDataSource.getShelterById(id);
    if (local != null) return local;

    try {
      final remote = await _remoteDataSource.getShelterById(id);
      await _localDataSource.saveShelter(remote);
      return remote;
    } catch (_) {
      return local;
    }
  }

  @override
  Future<Shelter> createShelter(Shelter shelter) async {
    final localShelter = Shelter(
      id: shelter.id,
      name: shelter.name,
      address: shelter.address,
      latitude: shelter.latitude,
      longitude: shelter.longitude,
      capacity: shelter.capacity,
      currentOccupancy: shelter.currentOccupancy,
      status: shelter.status,
      contactName: shelter.contactName,
      contactPhone: shelter.contactPhone,
      managedBy: shelter.managedBy,
      services: shelter.services,
      createdAt: shelter.createdAt,
      updatedAt: shelter.updatedAt,
      syncStatus: 'pending_create',
    );

    await _localDataSource.saveShelter(localShelter);
    await _syncManager.enqueueLocalMutation(
      entityType: 'shelter',
      entityId: shelter.id,
      operation: 'CREATE',
      payload: shelter.toJson(),
    );

    return localShelter;
  }

  @override
  Future<Shelter> updateShelter(Shelter shelter) async {
    final updated = Shelter(
      id: shelter.id,
      name: shelter.name,
      address: shelter.address,
      latitude: shelter.latitude,
      longitude: shelter.longitude,
      capacity: shelter.capacity,
      currentOccupancy: shelter.currentOccupancy,
      status: shelter.status,
      contactName: shelter.contactName,
      contactPhone: shelter.contactPhone,
      managedBy: shelter.managedBy,
      services: shelter.services,
      createdAt: shelter.createdAt,
      updatedAt: DateTime.now().toUtc(),
      syncStatus: 'pending_update',
    );

    await _localDataSource.saveShelter(updated);
    await _syncManager.enqueueLocalMutation(
      entityType: 'shelter',
      entityId: shelter.id,
      operation: 'UPDATE',
      payload: updated.toJson(),
    );

    return updated;
  }

  @override
  Future<void> syncShelters() async {
    await _syncManager.synchronizePendingEvents();
    final remoteList = await _remoteDataSource.getShelters();
    await _localDataSource.saveShelters(remoteList);
  }
}
