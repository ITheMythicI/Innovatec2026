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
    // 1. Intentar obtener desde el backend en tiempo real
    try {
      final remoteList = await _remoteDataSource.getShelters(status: status, onlyAvailable: onlyAvailable);
      if (remoteList.isNotEmpty) {
        await _localDataSource.saveShelters(remoteList);
        return remoteList;
      }
    } catch (_) {}

    // 2. Si no hay conexión, recuperar de la base de datos local SQLite
    final localList = await _localDataSource.getShelters(status: status, onlyAvailable: onlyAvailable);
    if (localList.isNotEmpty) {
      return localList;
    }

    // 3. Contingencia inicial si aún no se ha sincronizado y no hay red
    final defaultShelters = _getDefaultEmergencyShelters();
    await _localDataSource.saveShelters(defaultShelters);
    return defaultShelters;
  }

  List<Shelter> _getDefaultEmergencyShelters() => [
        Shelter(
          id: 'SH-01',
          name: 'Gimnasio Municipal Benito Juárez',
          address: 'Calle República de Brasil #42, Centro',
          latitude: 19.4385,
          longitude: -99.1295,
          capacity: 450,
          currentOccupancy: 288,
          status: ShelterStatus.open,
          contactName: 'Dra. Elena Ramos',
          contactPhone: '+52 55 1234 5678',
          managedBy: 'Cruz Roja Mexicana / Protección Civil',
          services: ['Agua potable', 'Atención médica 24/7', 'Energía solar', 'Raciones calientes'],
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
        ),
        Shelter(
          id: 'SH-02',
          name: 'Estadio Jesús Martínez "Palillo"',
          address: 'Av. Río Churubusco s/n, Magdalena Mixhuca',
          latitude: 19.4080,
          longitude: -99.1020,
          capacity: 800,
          currentOccupancy: 410,
          status: ShelterStatus.open,
          contactName: 'Ing. Carlos Mendoza',
          contactPhone: '+52 55 8765 4321',
          managedBy: 'Plan DN-III-E / Sedena',
          services: ['Comedor comunitario', 'Pabellón pediátrico', 'Dormitorios familiares'],
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now(),
        ),
      ];

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
