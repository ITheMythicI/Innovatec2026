import 'family_member.dart';

/// Representa el núcleo familiar o círculo de confianza de un usuario.
class FamilyGroup {
  final String id;
  final String familyName;
  final String headOfHouseholdUserId;
  final String meetingPointLocation; // Punto de encuentro preacordado en caso de desastre
  final List<FamilyMember> members;
  final DateTime createdAt;

  FamilyGroup({
    required this.id,
    required this.familyName,
    required this.headOfHouseholdUserId,
    required this.meetingPointLocation,
    required this.members,
    required this.createdAt,
  });

  /// Total de miembros a salvo
  int get safeCount => members.where((m) => m.status == MemberEmergencyStatus.safe).length;

  /// Total de miembros en refugios
  int get shelterCount => members.where((m) => m.status == MemberEmergencyStatus.inShelter).length;

  /// Total de miembros con urgencia / heridos
  int get urgentCount => members.where((m) => m.status == MemberEmergencyStatus.injured).length;

  /// Total de miembros sin contacto
  int get unreachableCount => members.where((m) => m.status == MemberEmergencyStatus.unreachable).length;

  FamilyGroup copyWith({
    String? familyName,
    String? meetingPointLocation,
    List<FamilyMember>? members,
  }) {
    return FamilyGroup(
      id: id,
      familyName: familyName ?? this.familyName,
      headOfHouseholdUserId: headOfHouseholdUserId,
      meetingPointLocation: meetingPointLocation ?? this.meetingPointLocation,
      members: members ?? this.members,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'familyName': familyName,
    'headOfHouseholdUserId': headOfHouseholdUserId,
    'meetingPointLocation': meetingPointLocation,
    'members': members.map((m) => m.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory FamilyGroup.fromJson(Map<String, dynamic> json) => FamilyGroup(
    id: json['id'] as String,
    familyName: json['familyName'] as String,
    headOfHouseholdUserId: json['headOfHouseholdUserId'] as String,
    meetingPointLocation: json['meetingPointLocation'] as String? ?? 'Punto de reunión acordado',
    members: (json['members'] as List<dynamic>?)
            ?.map((e) => FamilyMember.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
