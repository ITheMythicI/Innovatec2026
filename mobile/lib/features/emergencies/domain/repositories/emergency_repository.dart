import '../models/emergency.dart';

abstract class EmergencyRepository {
  Future<List<Emergency>> getEmergencies({EmergencyStatus? status, EmergencySeverity? severity, bool forceRefresh = false});
  Future<Emergency?> getEmergencyById(String id);
  Future<Emergency> createEmergency(Emergency emergency);
  Future<Emergency> updateEmergency(Emergency emergency);
  Future<void> syncEmergencies();
}
