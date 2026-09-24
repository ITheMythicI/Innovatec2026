import 'package:flutter/foundation.dart';
import '../../domain/models/shelter.dart';
import '../../domain/repositories/shelter_repository.dart';
import '../../data/repositories/shelter_repository_impl.dart';

enum ShelterStateStatus { initial, loading, success, error, empty }

class ShelterController extends ChangeNotifier {
  final ShelterRepository _repository;

  ShelterController({ShelterRepository? repository})
      : _repository = repository ?? ShelterRepositoryImpl();

  ShelterStateStatus _status = ShelterStateStatus.initial;
  List<Shelter> _shelters = [];
  String? _errorMessage;
  bool _onlyAvailable = false;
  ShelterStatus? _selectedStatus;

  ShelterStateStatus get status => _status;
  List<Shelter> get shelters => _shelters;
  String? get errorMessage => _errorMessage;
  bool get onlyAvailable => _onlyAvailable;
  ShelterStatus? get selectedStatus => _selectedStatus;

  Future<void> loadShelters({bool forceRefresh = false}) async {
    _status = ShelterStateStatus.loading;
    notifyListeners();

    try {
      _shelters = await _repository.getShelters(
        status: _selectedStatus,
        onlyAvailable: _onlyAvailable ? true : null,
        forceRefresh: forceRefresh,
      );
      _status = _shelters.isEmpty ? ShelterStateStatus.empty : ShelterStateStatus.success;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ShelterStateStatus.error;
    }
    notifyListeners();
  }

  void toggleOnlyAvailable(bool val) {
    _onlyAvailable = val;
    loadShelters();
  }

  void filterByStatus(ShelterStatus? status) {
    _selectedStatus = status;
    loadShelters();
  }

  Future<void> createShelter(Shelter shelter) async {
    try {
      final created = await _repository.createShelter(shelter);
      _shelters.insert(0, created);
      _status = ShelterStateStatus.success;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> sync() async {
    await _repository.syncShelters();
    await loadShelters(forceRefresh: true);
  }
}
