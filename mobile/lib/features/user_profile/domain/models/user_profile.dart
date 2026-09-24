import 'dart:convert';

/// Información de contacto de emergencia de prioridad alta.
class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;
  final bool isPriorityAlert;

  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
    this.isPriorityAlert = true,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'relationship': relationship,
    'phone': phone,
    'isPriorityAlert': isPriorityAlert,
  };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
    name: json['name'] as String,
    relationship: json['relationship'] as String,
    phone: json['phone'] as String,
    isPriorityAlert: json['isPriorityAlert'] as bool? ?? true,
  );
}

/// Ficha Médica y Perfil de Rescate del Usuario.
class UserProfile {
  final String userId;
  final String fullName;
  final int age;
  final String bloodType; // O+, O-, A+, A-, B+, B-, AB+, AB-
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<String> vitalMedications;
  final bool isOrganDonor;
  final String? medicalNotes;
  final List<EmergencyContact> emergencyContacts;
  final DateTime lastUpdated;

  UserProfile({
    required this.userId,
    required this.fullName,
    required this.age,
    required this.bloodType,
    required this.allergies,
    required this.chronicConditions,
    required this.vitalMedications,
    this.isOrganDonor = true,
    this.medicalNotes,
    required this.emergencyContacts,
    required this.lastUpdated,
  });

  /// Genera un payload ultracompacto para transmisión por código QR o BLE Triage.
  String toCompactTriagePayload() {
    final payload = {
      'uid': userId,
      'name': fullName,
      'bt': bloodType,
      'alg': allergies.join(','),
      'cnd': chronicConditions.join(','),
      'med': vitalMedications.join(','),
      'ctc': emergencyContacts.map((c) => '${c.name}:${c.phone}').join(';'),
    };
    return jsonEncode(payload);
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'fullName': fullName,
    'age': age,
    'bloodType': bloodType,
    'allergies': allergies,
    'chronicConditions': chronicConditions,
    'vitalMedications': vitalMedications,
    'isOrganDonor': isOrganDonor,
    'medicalNotes': medicalNotes,
    'emergencyContacts': emergencyContacts.map((c) => c.toJson()).toList(),
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    userId: json['userId'] as String,
    fullName: json['fullName'] as String,
    age: json['age'] as int? ?? 30,
    bloodType: json['bloodType'] as String? ?? 'O+',
    allergies: (json['allergies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    chronicConditions: (json['chronicConditions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    vitalMedications: (json['vitalMedications'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    isOrganDonor: json['isOrganDonor'] as bool? ?? true,
    medicalNotes: json['medicalNotes'] as String?,
    emergencyContacts: (json['emergencyContacts'] as List<dynamic>?)
            ?.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    lastUpdated: DateTime.tryParse(json['lastUpdated']?.toString() ?? '') ?? DateTime.now(),
  );
}
