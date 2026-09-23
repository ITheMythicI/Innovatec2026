/// Estado de supervivencia y localización de un integrante familiar.
enum MemberEmergencyStatus {
  safe,
  inShelter,
  injured,
  unreachable,
}

extension MemberEmergencyStatusExtension on MemberEmergencyStatus {
  String get label {
    switch (this) {
      case MemberEmergencyStatus.safe:
        return 'A Salvo';
      case MemberEmergencyStatus.inShelter:
        return 'En Refugio';
      case MemberEmergencyStatus.injured:
        return 'Herido / Requiere Ayuda';
      case MemberEmergencyStatus.unreachable:
        return 'Sin Contacto';
    }
  }

  String get emoji {
    switch (this) {
      case MemberEmergencyStatus.safe:
        return '🟢';
      case MemberEmergencyStatus.inShelter:
        return '🟡';
      case MemberEmergencyStatus.injured:
        return '🔴';
      case MemberEmergencyStatus.unreachable:
        return '⚪';
    }
  }
}

/// Representa a un integrante de un círculo familiar o de confianza.
class FamilyMember {
  final String id;
  final String fullName;
  final String relationship; // Madre, Hijo, Cónyuge, Hermano, etc.
  final int age;
  final bool isMinor;
  final MemberEmergencyStatus status;
  final String? shelterName;
  final String? lastKnownLocation;
  final String? notes;
  final DateTime lastStatusUpdate;

  FamilyMember({
    required this.id,
    required this.fullName,
    required this.relationship,
    required this.age,
    required this.isMinor,
    required this.status,
    this.shelterName,
    this.lastKnownLocation,
    this.notes,
    required this.lastStatusUpdate,
  });

  FamilyMember copyWith({
    String? fullName,
    String? relationship,
    int? age,
    bool? isMinor,
    MemberEmergencyStatus? status,
    String? shelterName,
    String? lastKnownLocation,
    String? notes,
    DateTime? lastStatusUpdate,
  }) {
    return FamilyMember(
      id: id,
      fullName: fullName ?? this.fullName,
      relationship: relationship ?? this.relationship,
      age: age ?? this.age,
      isMinor: isMinor ?? this.isMinor,
      status: status ?? this.status,
      shelterName: shelterName ?? this.shelterName,
      lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
      notes: notes ?? this.notes,
      lastStatusUpdate: lastStatusUpdate ?? this.lastStatusUpdate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'relationship': relationship,
    'age': age,
    'isMinor': isMinor,
    'status': status.name,
    'shelterName': shelterName,
    'lastKnownLocation': lastKnownLocation,
    'notes': notes,
    'lastStatusUpdate': lastStatusUpdate.toIso8601String(),
  };

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    relationship: json['relationship'] as String,
    age: json['age'] as int? ?? 18,
    isMinor: json['isMinor'] as bool? ?? false,
    status: MemberEmergencyStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => MemberEmergencyStatus.unreachable,
    ),
    shelterName: json['shelterName'] as String?,
    lastKnownLocation: json['lastKnownLocation'] as String?,
    notes: json['notes'] as String?,
    lastStatusUpdate: DateTime.parse(json['lastStatusUpdate'] as String),
  );
}
