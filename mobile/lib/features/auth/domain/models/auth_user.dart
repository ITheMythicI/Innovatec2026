import 'package:innovatec_mobile/core/security/roles_and_permissions.dart';

/// Usuario autenticado en el dispositivo (Soporta modo online y offline).
class AuthUser {
  final String id;
  final String fullName;
  final String emailOrPhone;
  final UserRole role;
  final String uniqueCitizenCode; // Código QR Único Nacional: NOVA-MX-2026-XXXX
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
    String? uniqueCitizenCode,
    this.organizationName,
    this.officialBadgeId,
    required this.devicePublicKey,
    this.isOfflineEmergencyUser = false,
    required this.createdAt,
  }) : uniqueCitizenCode = uniqueCitizenCode ?? 'NOVA-MX-2026-${id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').padRight(6, 'X').substring(0, 6).toUpperCase()}';

  bool hasPermission(AppPermission permission) {
    return RbacService.hasPermission(role, permission);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'emailOrPhone': emailOrPhone,
      'role': role.code,
      'uniqueCitizenCode': uniqueCitizenCode,
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
      uniqueCitizenCode: json['uniqueCitizenCode'] as String?,
      organizationName: json['organizationName'] as String?,
      officialBadgeId: json['officialBadgeId'] as String?,
      devicePublicKey: json['devicePublicKey'] as String,
      isOfflineEmergencyUser: json['isOfflineEmergencyUser'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
