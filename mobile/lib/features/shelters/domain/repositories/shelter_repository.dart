import '../models/shelter.dart';

abstract class ShelterRepository {
  Future<List<Shelter>> getShelters({ShelterStatus? status, bool? onlyAvailable, bool forceRefresh = false});
  Future<Shelter?> getShelterById(String id);
  Future<Shelter> createShelter(Shelter shelter);
  Future<Shelter> updateShelter(Shelter shelter);
  Future<void> syncShelters();
}
