import 'package:innovatec_mobile/sync/sync_manager.dart';
import 'package:innovatec_mobile/features/user_profile/domain/models/user_profile.dart';
import 'package:innovatec_mobile/features/user_profile/domain/repositories/profile_repository.dart';
import 'package:innovatec_mobile/features/user_profile/data/datasources/profile_local_datasource.dart';
import 'package:innovatec_mobile/features/user_profile/data/datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource _localDataSource;
  final ProfileRemoteDataSource _remoteDataSource;
  final SyncManager _syncManager;

  ProfileRepositoryImpl({
    ProfileLocalDataSource? localDataSource,
    ProfileRemoteDataSource? remoteDataSource,
    SyncManager? syncManager,
  })  : _localDataSource = localDataSource ?? ProfileLocalDataSourceImpl(),
        _remoteDataSource = remoteDataSource ?? ProfileRemoteDataSourceImpl(),
        _syncManager = syncManager ?? SyncManager.instance;

  @override
  Future<UserProfile> getUserProfile() async {
    final local = await _localDataSource.getUserProfile();
    if (local != null) return local;

    final defaultProfile = UserProfile(
      userId: 'usr-offline-operator-01',
      fullName: 'Dr. Alejandro Soto Valdés',
      age: 38,
      bloodType: 'O+',
      allergies: ['Penicilina', 'Sulfas'],
      chronicConditions: ['Hipertensión Leve'],
      vitalMedications: ['Losartán 50mg (1 cada 24h)'],
      isOrganDonor: true,
      medicalNotes: 'Cirugía de rodilla derecha en 2022. Esquema de vacunación completo.',
      emergencyContacts: [
        EmergencyContact(
          name: 'Dra. Sofía Mendoza',
          relationship: 'Esposa / Contacto Principal',
          phone: '+52 55 1234 5678',
          isPriorityAlert: true,
        ),
        EmergencyContact(
          name: 'Crio. Fernando Soto',
          relationship: 'Hermano / Enlace Familiar',
          phone: '+52 55 8765 4321',
          isPriorityAlert: false,
        ),
      ],
      lastUpdated: DateTime.now(),
    );

    await _localDataSource.saveUserProfile(defaultProfile);
    return defaultProfile;
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    await _localDataSource.saveUserProfile(profile);
    await _syncManager.enqueueLocalMutation(
      entityType: 'user_profile',
      entityId: profile.userId,
      operation: 'UPDATE',
      payload: profile.toJson(),
    );
  }

  @override
  Future<void> syncProfile() async {
    await _syncManager.synchronizePendingEvents();
  }
}
