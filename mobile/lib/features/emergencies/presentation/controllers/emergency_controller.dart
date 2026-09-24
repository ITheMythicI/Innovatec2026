import 'package:flutter/foundation.dart';
import '../../domain/models/emergency.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../../data/repositories/emergency_repository_impl.dart';

enum EmergencyStateStatus { initial, loading, success, error, empty }

class EmergencyController extends ChangeNotifier {
  final EmergencyRepository _repository;

  EmergencyController({EmergencyRepository? repository})
      : _repository = repository ?? EmergencyRepositoryImpl();

  EmergencyStateStatus _status = EmergencyStateStatus.initial;
  List<Emergency> _emergencies = [];
  String? _errorMessage;
  EmergencySeverity? _selectedSeverity;
  EmergencyStatus? _selectedStatus;

  EmergencyStateStatus get status => _status;
  List<Emergency> get emergencies => _emergencies;
  String? get errorMessage => _errorMessage;
  EmergencySeverity? get selectedSeverity => _selectedSeverity;
  EmergencyStatus? get selectedStatus => _selectedStatus;

  Future<void> loadEmergencies({bool forceRefresh = false}) async {
    _status = EmergencyStateStatus.loading;
    notifyListeners();

    try {
      _emergencies = await _repository.getEmergencies(
        severity: _selectedSeverity,
        status: _selectedStatus,
        forceRefresh: forceRefresh,
      );
      _status = _emergencies.isEmpty ? EmergencyStateStatus.empty : EmergencyStateStatus.success;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _status = EmergencyStateStatus.error;
    }
    notifyListeners();
  }

  void filterBySeverity(EmergencySeverity? severity) {
    _selectedSeverity = severity;
    loadEmergencies();
  }

  void filterByStatus(EmergencyStatus? status) {
    _selectedStatus = status;
    loadEmergencies();
  }

  Future<void> createEmergency(Emergency emergency) async {
    try {
      final created = await _repository.createEmergency(emergency);
      _emergencies.insert(0, created);
      _status = EmergencyStateStatus.success;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> sync() async {
    await _repository.syncEmergencies();
    await loadEmergencies(forceRefresh: true);
  }
}
