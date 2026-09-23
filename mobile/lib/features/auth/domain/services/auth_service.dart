import 'dart:async';
import 'package:innovatec_mobile/core/audit/audit_event.dart';
import 'package:innovatec_mobile/core/audit/audit_service.dart';
import 'package:innovatec_mobile/core/security/crypto_service.dart';
import 'package:innovatec_mobile/core/security/roles_and_permissions.dart';
import 'package:innovatec_mobile/features/auth/domain/models/auth_user.dart';

/// Servicio de Autenticación Híbrida (Online + Offline Resilience).
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal() {
    _initDefaultUser();
  }

  final _currentUserController = StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;

  Stream<AuthUser?> get currentUserStream => _currentUserController.stream;
  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  void _initDefaultUser() {
    _currentUser = AuthUser(
      id: 'USR-DEV-001',
      fullName: 'Carlos Mendoza Ruiz',
      emailOrPhone: '+52 55 9876 5432',
      role: UserRole.citizen,
      devicePublicKey: 'PUB-KEY-LOCAL-DEV-001',
      isOfflineEmergencyUser: true,
      createdAt: DateTime.now(),
    );
    _currentUserController.add(_currentUser);
  }

  Future<void> switchUserRole(UserRole newRole, {String? officialBadgeId, String? organizationName}) async {
    final updatedUser = AuthUser(
      id: _currentUser?.id ?? CryptoService.generateId(),
      fullName: _currentUser?.fullName ?? 'Operador de Emergencia',
      emailOrPhone: _currentUser?.emailOrPhone ?? '+52 55 0000 0000',
      role: newRole,
      officialBadgeId: officialBadgeId ?? (newRole == UserRole.authority ? 'PC-CDMX-4821' : null),
      organizationName: organizationName ?? (newRole == UserRole.shelterAdmin ? 'Refugio Polideportivo Norte' : null),
      devicePublicKey: _currentUser?.devicePublicKey ?? 'PUB-KEY-LOCAL',
      isOfflineEmergencyUser: _currentUser?.isOfflineEmergencyUser ?? true,
      createdAt: _currentUser?.createdAt ?? DateTime.now(),
    );

    _currentUser = updatedUser;
    _currentUserController.add(_currentUser);

    await AuditService().logEvent(
      eventType: AuditEventType.authLogin,
      actorUserId: updatedUser.id,
      actorRole: updatedUser.role.code,
      entityId: updatedUser.id,
      metadata: {
        'action': 'ROLE_SWITCH',
        'newRole': newRole.code,
        'badgeId': updatedUser.officialBadgeId,
        'org': updatedUser.organizationName,
      },
    );
  }

  Future<AuthUser> createQuickOfflineProfile({
    required String fullName,
    required String phone,
    required UserRole role,
  }) async {
    final newUser = AuthUser(
      id: CryptoService.generateId(),
      fullName: fullName,
      emailOrPhone: phone,
      role: role,
      devicePublicKey: CryptoService.sha256Hash(fullName + DateTime.now().toIso8601String()),
      isOfflineEmergencyUser: true,
      createdAt: DateTime.now(),
    );

    _currentUser = newUser;
    _currentUserController.add(_currentUser);

    await AuditService().logEvent(
      eventType: AuditEventType.emergencyProfileCreated,
      actorUserId: newUser.id,
      actorRole: newUser.role.code,
      entityId: newUser.id,
      metadata: {
        'fullName': fullName,
        'phone': phone,
        'mode': 'OFFLINE_QUICK_BOOT',
      },
    );

    return newUser;
  }

  Future<void> logout() async {
    if (_currentUser != null) {
      await AuditService().logEvent(
        eventType: AuditEventType.authLogout,
        actorUserId: _currentUser!.id,
        actorRole: _currentUser!.role.code,
        entityId: _currentUser!.id,
        metadata: {'action': 'LOGOUT'},
      );
    }
    _currentUser = null;
    _currentUserController.add(null);
  }
}
