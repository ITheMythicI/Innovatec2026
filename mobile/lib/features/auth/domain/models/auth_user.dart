import 'package:innovatec_mobile/core/security/roles_and_permissions.dart';

/// Usuario autenticado en el dispositivo (Soporta modo online y offline).
class AuthUser {
  final String id;
  final String fullName;
  final String emailOrPhone;
  final UserRole role;
  final String? organizationName;
  final String? officialBadgeId; // Número de placa o acreditación oficial
  final String devicePublicKey;
  final bool isOfflineEmergencyUser;
  final DateTime createdAt;

  AuthUser({
    required this.id,
    required this.fullName,
    required this.emailOrPhone,
    required this.role,
    this.organizationName,
    this.officialBadgeId,
    required this.devicePublicKey,
    this.isOfflineEmergencyUser = false,
    required this.createdAt,
  });

  bool hasPermission(AppPermission permission) {
    return RbacService.hasPermission(role, permission);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'emailOrPhone': emailOrPhone,
      'role': role.code,
      'organizationName': organizationName,
      'officialBadgeId': officialBadgeId,
      'devicePublicKey': devicePublicKey,
      'isOfflineEmergencyUser': isOfflineEmergencyUser,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      emailOrPhone: json['emailOrPhone'] as String,
      role: UserRoleExtension.fromCode(json['role'] as String),
      organizationName: json['organizationName'] as String?,
      officialBadgeId: json['officialBadgeId'] as String?,
      devicePublicKey: json['devicePublicKey'] as String,
      isOfflineEmergencyUser: json['isOfflineEmergencyUser'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
