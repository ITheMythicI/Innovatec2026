import 'package:innovatec_mobile/database/app_database.dart';
import 'package:innovatec_mobile/features/emergencies/domain/models/emergency.dart';

abstract class EmergencyLocalDataSource {
  Future<List<Emergency>> getEmergencies({EmergencyStatus? status, EmergencySeverity? severity});
  Future<Emergency?> getEmergencyById(String id);
  Future<void> saveEmergency(Emergency emergency);
  Future<void> saveEmergencies(List<Emergency> emergencies);
  Future<void> deleteEmergency(String id);
}

class EmergencyLocalDataSourceImpl implements EmergencyLocalDataSource {
  final AppDatabase _database;

  EmergencyLocalDataSourceImpl({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  @override
  Future<List<Emergency>> getEmergencies({EmergencyStatus? status, EmergencySeverity? severity}) async {
    final rawList = await _database.emergenciesDao.getAll(
      status: status?.toBackendString(),
      severity: severity?.toBackendString(),
    );
    return rawList.map((e) => Emergency.fromJson(e)).toList();
  }

  @override
  Future<Emergency?> getEmergencyById(String id) async {
    final raw = await _database.emergenciesDao.getById(id);
    if (raw == null) return null;
    return Emergency.fromJson(raw);
  }

  @override
  Future<void> saveEmergency(Emergency emergency) async {
    await _database.emergenciesDao.insertOrUpdate(emergency.toDatabaseMap());
  }

  @override
  Future<void> saveEmergencies(List<Emergency> emergencies) async {
    await _database.emergenciesDao.insertOrUpdateAll(
      emergencies.map((e) => e.toDatabaseMap()).toList(),
    );
  }

  @override
  Future<void> deleteEmergency(String id) async {
    await _database.emergenciesDao.deleteById(id);
  }
}
