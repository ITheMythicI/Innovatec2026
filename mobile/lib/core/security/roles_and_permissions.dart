/// Roles del sistema en situaciones de desastre y emergencia.
enum UserRole {
  /// Ciudadano civil afectado o familiar
  citizen,

  /// Voluntario acreditado / Brigadista
  volunteer,

  /// Encargado o Administrador de un Refugio/Albergue
  shelterAdmin,

  /// Personal de Organización Civil o Cruz Roja / ONG
  organizationWorker,

  /// Autoridad Oficial (Protección Civil, Sedena, Policía, Marina)
  authority,

  /// Administrador Central del Sistema
  systemAdmin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.citizen:
        return 'Ciudadano';
      case UserRole.volunteer:
        return 'Voluntario / Brigadista';
      case UserRole.shelterAdmin:
        return 'Administrador de Refugio';
      case UserRole.organizationWorker:
        return 'Personal ONG / Cruz Roja';
      case UserRole.authority:
        return 'Autoridad Oficial (Protección Civil)';
      case UserRole.systemAdmin:
        return 'Administrador del Sistema';
    }
  }

  String get code {
    switch (this) {
      case UserRole.citizen:
        return 'CITIZEN';
      case UserRole.volunteer:
        return 'VOLUNTEER';
      case UserRole.shelterAdmin:
        return 'SHELTER_ADMIN';
      case UserRole.organizationWorker:
        return 'NGO_WORKER';
      case UserRole.authority:
        return 'AUTHORITY';
      case UserRole.systemAdmin:
        return 'SYS_ADMIN';
    }
  }

  String get toBackendRole {
    switch (this) {
      case UserRole.citizen:
        return 'USER';
      case UserRole.volunteer:
        return 'USER';
      case UserRole.shelterAdmin:
        return 'OPERATOR';
      case UserRole.organizationWorker:
        return 'OPERATOR';
      case UserRole.authority:
        return 'COMMANDER';
      case UserRole.systemAdmin:
        return 'SUPER_ADMIN';
    }
  }

  static UserRole fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'CITIZEN':
      case 'USER':
        return UserRole.citizen;
      case 'VOLUNTEER':
        return UserRole.volunteer;
      case 'SHELTER_ADMIN':
        return UserRole.shelterAdmin;
      case 'NGO_WORKER':
        return UserRole.organizationWorker;
      case 'AUTHORITY':
      case 'COMMANDER':
      case 'OPERATOR':
        return UserRole.authority;
      case 'SYS_ADMIN':
      case 'SUPER_ADMIN':
        return UserRole.systemAdmin;
      case 'VIEWER':
        return UserRole.citizen;
      default:
        return UserRole.citizen;
    }
  }
}

/// Permisos específicos del sistema (RBAC Granular).
enum AppPermission {
  // --- Perfil y Familia ---
  createEmergencyProfile,
  manageOwnFamily,

  // --- Desaparecidos y Personas ---
  reportMissingPerson,
  reportFoundPerson,
  viewPublicMissingList,
  viewSensitiveMinorDetails, // Protegido: Solo albergue / autoridad
  verifyMissingPersonReport, // Protegido: Marcar como verificado oficial
  authorizeMinorReunification, // Protegido: Validación y entrega de menores

  // --- Refugios y Operación ---
  manageShelterCapacity,
  registerShelterArrival,

  // --- Auditoría y Seguridad ---
  viewAuditLog,
  verifyAuditChainIntegrity,
  exportAuditData,
}

/// Matriz de control de acceso basada en roles (RBAC Service).
class RbacService {
  static final Map<UserRole, Set<AppPermission>> _matrix = {
    UserRole.citizen: {
      AppPermission.createEmergencyProfile,
      AppPermission.manageOwnFamily,
      AppPermission.reportMissingPerson,
      AppPermission.reportFoundPerson,
      AppPermission.viewPublicMissingList,
    },
    UserRole.volunteer: {
      AppPermission.createEmergencyProfile,
      AppPermission.manageOwnFamily,
      AppPermission.reportMissingPerson,
      AppPermission.reportFoundPerson,
      AppPermission.viewPublicMissingList,
      AppPermission.registerShelterArrival,
    },
    UserRole.shelterAdmin: {
      AppPermission.createEmergencyProfile,
      AppPermission.manageOwnFamily,
      AppPermission.reportMissingPerson,
      AppPermission.reportFoundPerson,
      AppPermission.viewPublicMissingList,
      AppPermission.viewSensitiveMinorDetails,
      AppPermission.verifyMissingPersonReport,
      AppPermission.authorizeMinorReunification,
      AppPermission.manageShelterCapacity,
      AppPermission.registerShelterArrival,
      AppPermission.viewAuditLog,
      AppPermission.verifyAuditChainIntegrity,
    },
    UserRole.organizationWorker: {
      AppPermission.createEmergencyProfile,
      AppPermission.manageOwnFamily,
      AppPermission.reportMissingPerson,
      AppPermission.reportFoundPerson,
      AppPermission.viewPublicMissingList,
      AppPermission.viewSensitiveMinorDetails,
      AppPermission.verifyMissingPersonReport,
      AppPermission.registerShelterArrival,
      AppPermission.viewAuditLog,
    },
    UserRole.authority: {
      AppPermission.createEmergencyProfile,
      AppPermission.manageOwnFamily,
      AppPermission.reportMissingPerson,
      AppPermission.reportFoundPerson,
      AppPermission.viewPublicMissingList,
      AppPermission.viewSensitiveMinorDetails,
      AppPermission.verifyMissingPersonReport,
      AppPermission.authorizeMinorReunification,
      AppPermission.manageShelterCapacity,
      AppPermission.registerShelterArrival,
      AppPermission.viewAuditLog,
      AppPermission.verifyAuditChainIntegrity,
      AppPermission.exportAuditData,
    },
    UserRole.systemAdmin: AppPermission.values.toSet(),
  };

  /// Valida si un rol cuenta con un permiso específico.
  static bool hasPermission(UserRole role, AppPermission permission) {
    final permissions = _matrix[role] ?? {};
    return permissions.contains(permission);
  }

  /// Retorna todos los permisos asociados a un rol.
  static Set<AppPermission> getPermissions(UserRole role) {
    return _matrix[role] ?? {};
  }
}
