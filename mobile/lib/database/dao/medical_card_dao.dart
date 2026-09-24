import '../tables/medical_cards_table.dart';

abstract class MedicalCardDao {
  Future<void> saveMedicalCard(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getMedicalCard(String id);
  Future<Map<String, dynamic>?> getPrimaryCard();
  Future<void> clear();
}

class InMemoryMedicalCardDao implements MedicalCardDao {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> saveMedicalCard(Map<String, dynamic> data) async {
    final id = data[MedicalCardsTable.columnId] as String;
    _storage[id] = Map<String, dynamic>.from(data);
  }

  @override
  Future<Map<String, dynamic>?> getMedicalCard(String id) async {
    return _storage[id];
  }

  @override
  Future<Map<String, dynamic>?> getPrimaryCard() async {
    if (_storage.isEmpty) return null;
    return _storage.values.first;
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }
}
