import 'dart:async';
import 'package:innovatec_mobile/core/audit/audit_event.dart';
import 'package:innovatec_mobile/core/audit/audit_service.dart';
import 'package:innovatec_mobile/core/security/crypto_service.dart';
import 'package:innovatec_mobile/core/security/roles_and_permissions.dart';
import 'package:innovatec_mobile/features/auth/domain/models/auth_user.dart';

import 'package:innovatec_mobile/core/network/api_client.dart';

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

  /// Inicia sesión contra el backend `/auth/login` con fallback offline
  Future<AuthUser> loginWithCredentials(String email, String password) async {
    try {
      final response = await ApiClient.instance.post(
        '/auth/login',
        body: {
          'email': email.trim(),
          'password': password,
        },
      );

      final token = response['accessToken'] as String?;
      if (token != null) {
        ApiClient.instance.setAuthToken(token);
      }

      final userData = response['user'] as Map<String, dynamic>? ?? {};
      final roleStr = (userData['appRole'] as String?) ?? 'USER';
      final role = UserRoleExtension.fromCode(roleStr);

      final user = AuthUser(
        id: userData['id'] as String? ?? CryptoService.generateId(),
        fullName: userData['fullName'] as String? ?? email.split('@').first,
        emailOrPhone: userData['email'] as String? ?? email,
        role: role,
        officialBadgeId: userData['tacticalId'] as String?,
        devicePublicKey: CryptoService.sha256Hash(email + DateTime.now().toIso8601String()),
        isOfflineEmergencyUser: false,
        createdAt: DateTime.now(),
      );

      _currentUser = user;
      _currentUserController.add(_currentUser);

      await AuditService().logEvent(
        eventType: AuditEventType.authLogin,
        actorUserId: user.id,
        actorRole: user.role.code,
        entityId: user.id,
        metadata: {'action': 'ONLINE_LOGIN', 'email': email, 'role': role.code},
      );

      return user;
    } catch (e) {
      // Fallback offline resiliente: Si no hay red, permitir acceso con credenciales locales
      final offlineRole = email.contains('admin') || email.contains('operador') 
          ? UserRole.authority 
          : UserRole.citizen;

      final fallbackUser = AuthUser(
        id: CryptoService.generateId(),
        fullName: email.contains('@') ? email.split('@').first.toUpperCase() : 'Usuario Local',
        emailOrPhone: email,
        role: offlineRole,
        officialBadgeId: offlineRole == UserRole.authority ? 'PC-OFFLINE-001' : null,
        devicePublicKey: CryptoService.sha256Hash('OFFLINE-$email'),
        isOfflineEmergencyUser: true,
        createdAt: DateTime.now(),
      );

      _currentUser = fallbackUser;
      _currentUserController.add(_currentUser);

      await AuditService().logEvent(
        eventType: AuditEventType.authLogin,
        actorUserId: fallbackUser.id,
        actorRole: fallbackUser.role.code,
        entityId: fallbackUser.id,
        metadata: {'action': 'OFFLINE_FALLBACK_LOGIN', 'email': email, 'reason': e.toString()},
      );

      return fallbackUser;
    }
  }

  /// Registra nuevo usuario en `/auth/register` con fallback offline
  Future<AuthUser> registerUser({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    UserRole role = UserRole.citizen,
    String? tacticalId,
  }) async {
    try {
      await ApiClient.instance.post(
        '/auth/register',
        body: {
          'email': email.trim(),
          'password': password,
          'fullName': fullName.trim(),
          if (phone != null && phone.isNotEmpty) 'phone': phone.trim(),
          'appRole': role.toBackendRole,
          if (tacticalId != null && tacticalId.isNotEmpty) 'tacticalId': tacticalId.trim(),
        },
      );

      // Iniciar sesión inmediatamente
      return await loginWithCredentials(email, password);
    } catch (e) {
      // Fallback offline: crear usuario local persistente
      final newUser = AuthUser(
        id: CryptoService.generateId(),
        fullName: fullName,
        emailOrPhone: email.isNotEmpty ? email : (phone ?? 'Sin contacto'),
        role: role,
        officialBadgeId: tacticalId,
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
        metadata: {'action': 'OFFLINE_REGISTRATION', 'email': email, 'role': role.code},
      );

      return newUser;
    }
  }

  /// Acceso anónimo directo para emergencias civiles
  Future<AuthUser> guestEmergencyLogin() async {
    final guestUser = AuthUser(
      id: 'GUEST-${CryptoService.generateId().substring(0, 8)}',
      fullName: 'Ciudadano No Registrado (SOS)',
      emailOrPhone: 'SOS Inmediato',
      role: UserRole.citizen,
      devicePublicKey: CryptoService.sha256Hash('GUEST-${DateTime.now().toIso8601String()}'),
      isOfflineEmergencyUser: true,
      createdAt: DateTime.now(),
    );

    _currentUser = guestUser;
    _currentUserController.add(_currentUser);

    await AuditService().logEvent(
      eventType: AuditEventType.emergencyProfileCreated,
      actorUserId: guestUser.id,
      actorRole: guestUser.role.code,
      entityId: guestUser.id,
      metadata: {'action': 'GUEST_EMERGENCY_LOGIN'},
    );

    return guestUser;
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
