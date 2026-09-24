import 'package:innovatec_mobile/database/app_database.dart';
import 'package:innovatec_mobile/features/shelters/domain/models/shelter.dart';

abstract class ShelterLocalDataSource {
  Future<List<Shelter>> getShelters({ShelterStatus? status, bool? onlyAvailable});
  Future<Shelter?> getShelterById(String id);
  Future<void> saveShelter(Shelter shelter);
  Future<void> saveShelters(List<Shelter> shelters);
}

class ShelterLocalDataSourceImpl implements ShelterLocalDataSource {
  final AppDatabase _database;

  ShelterLocalDataSourceImpl({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  @override
  Future<List<Shelter>> getShelters({ShelterStatus? status, bool? onlyAvailable}) async {
    final rawList = await _database.sheltersDao.getAll(
      status: status?.toBackendString(),
      onlyAvailable: onlyAvailable,
    );
    return rawList.map((e) => Shelter.fromJson(e)).toList();
  }

  @override
  Future<Shelter?> getShelterById(String id) async {
    final raw = await _database.sheltersDao.getById(id);
    if (raw == null) return null;
    return Shelter.fromJson(raw);
  }

  @override
  Future<void> saveShelter(Shelter shelter) async {
    await _database.sheltersDao.insertOrUpdate(shelter.toDatabaseMap());
  }

  @override
  Future<void> saveShelters(List<Shelter> shelters) async {
    await _database.sheltersDao.insertOrUpdateAll(
      shelters.map((e) => e.toDatabaseMap()).toList(),
    );
  }
}
