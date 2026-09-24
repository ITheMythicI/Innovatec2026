enum ReportCategory {
  casualties,
  trappedPersons,
  structuralDamage,
  fireHazard,
  flooding,
  roadBlocked,
  supplyNeed,
  medicalEmergency,
  other,
}

enum ReportPriority {
  low,
  medium,
  high,
  critical,
}

enum ReportStatus {
  pending,
  verified,
  inProgress,
  resolved,
  dismissed,
}

extension ReportCategoryExtension on ReportCategory {
  String get displayName {
    switch (this) {
      case ReportCategory.casualties:
        return 'Víctimas / Heridos';
      case ReportCategory.trappedPersons:
        return 'Personas Atrapadas';
      case ReportCategory.structuralDamage:
        return 'Daño Estructural';
      case ReportCategory.fireHazard:
        return 'Fuego / Incendio';
      case ReportCategory.flooding:
        return 'Inundación';
      case ReportCategory.roadBlocked:
        return 'Vía / Calle Bloqueada';
      case ReportCategory.supplyNeed:
        return 'Necesidad de Víveres';
      case ReportCategory.medicalEmergency:
        return 'Emergencia Médica';
      case ReportCategory.other:
        return 'Otro Incidente';
    }
  }

  String toBackendString() {
    switch (this) {
      case ReportCategory.casualties:
        return 'CASUALTIES';
      case ReportCategory.trappedPersons:
        return 'TRAPPED_PERSONS';
      case ReportCategory.structuralDamage:
        return 'STRUCTURAL_DAMAGE';
      case ReportCategory.fireHazard:
        return 'FIRE_HAZARD';
      case ReportCategory.flooding:
        return 'FLOODING';
      case ReportCategory.roadBlocked:
        return 'ROAD_BLOCKED';
      case ReportCategory.supplyNeed:
        return 'SUPPLY_NEED';
      case ReportCategory.medicalEmergency:
        return 'MEDICAL_EMERGENCY';
      case ReportCategory.other:
        return 'OTHER';
    }
  }

  static ReportCategory fromString(String? val) {
    if (val == null) return ReportCategory.other;
    final norm = val.toUpperCase();
    for (final c in ReportCategory.values) {
      if (c.toBackendString() == norm || c.name.toUpperCase() == norm) return c;
    }
    return ReportCategory.other;
  }
}

extension ReportPriorityExtension on ReportPriority {
  String get displayName {
    switch (this) {
      case ReportPriority.low:
        return 'Baja';
      case ReportPriority.medium:
        return 'Media';
      case ReportPriority.high:
        return 'Alta';
      case ReportPriority.critical:
        return 'Crítica';
    }
  }

  String toBackendString() => name.toUpperCase();

  static ReportPriority fromString(String? val) {
    if (val == null) return ReportPriority.medium;
    final norm = val.toUpperCase();
    for (final p in ReportPriority.values) {
      if (p.name.toUpperCase() == norm) return p;
    }
    return ReportPriority.medium;
  }
}

extension ReportStatusExtension on ReportStatus {
  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Pendiente';
      case ReportStatus.verified:
        return 'Verificado';
      case ReportStatus.inProgress:
        return 'En Atención';
      case ReportStatus.resolved:
        return 'Resuelto';
      case ReportStatus.dismissed:
        return 'Desestimado';
    }
  }

  String toBackendString() {
    switch (this) {
      case ReportStatus.pending:
        return 'PENDING';
      case ReportStatus.verified:
        return 'VERIFIED';
      case ReportStatus.inProgress:
        return 'IN_PROGRESS';
      case ReportStatus.resolved:
        return 'RESOLVED';
      case ReportStatus.dismissed:
        return 'DISMISSED';
    }
  }

  static ReportStatus fromString(String? val) {
    if (val == null) return ReportStatus.pending;
    final norm = val.toUpperCase();
    for (final s in ReportStatus.values) {
      if (s.toBackendString() == norm || s.name.toUpperCase() == norm) return s;
    }
    return ReportStatus.pending;
  }
}

class Report {
  final String id;
  final String? reporterUserId;
  final String? reporterName;
  final String? reporterContact;
  final String? emergencyId;
  final String title;
  final String description;
  final ReportCategory category;
  final ReportPriority priority;
  final ReportStatus status;
  final double? latitude;
  final double? longitude;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  const Report({
    required this.id,
    this.reporterUserId,
    this.reporterName,
    this.reporterContact,
    this.emergencyId,
    required this.title,
    required this.description,
    this.category = ReportCategory.other,
    this.priority = ReportPriority.medium,
    this.status = ReportStatus.pending,
    this.latitude,
    this.longitude,
    this.address,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'synced',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'reporterUserId': reporterUserId,
    'reporterName': reporterName,
    'reporterContact': reporterContact,
    'emergencyId': emergencyId,
    'title': title,
    'description': description,
    'category': category.toBackendString(),
    'priority': priority.toBackendString(),
    'status': status.toBackendString(),
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'syncStatus': syncStatus,
  };

  Map<String, dynamic> toDatabaseMap() => {
    'id': id,
    'reporter_user_id': reporterUserId,
    'reporter_name': reporterName,
    'reporter_contact': reporterContact,
    'emergency_id': emergencyId,
    'title': title,
    'description': description,
    'category': category.toBackendString(),
    'priority': priority.toBackendString(),
    'status': status.toBackendString(),
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'sync_status': syncStatus,
  };

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json['id'] as String,
    reporterUserId: json['reporterUserId'] ?? json['reporter_user_id'] as String?,
    reporterName: json['reporterName'] ?? json['reporter_name'] as String?,
    reporterContact: json['reporterContact'] ?? json['reporter_contact'] as String?,
    emergencyId: json['emergencyId'] ?? json['emergency_id'] as String?,
    title: json['title'] as String,
    description: json['description'] as String,
    category: ReportCategoryExtension.fromString(json['category'] as String?),
    priority: ReportPriorityExtension.fromString(json['priority'] as String?),
    status: ReportStatusExtension.fromString(json['status'] as String?),
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    address: json['address'] as String?,
    createdAt: DateTime.parse((json['createdAt'] ?? json['created_at']) as String),
    updatedAt: DateTime.parse((json['updatedAt'] ?? json['updated_at']) as String),
    syncStatus: json['syncStatus'] ?? json['sync_status'] ?? 'synced',
  );
}
