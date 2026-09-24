enum EmergencyType {
  earthquake,
  flood,
  hurricane,
  wildfire,
  landslide,
  volcanicEruption,
  tsunami,
  explosion,
  buildingCollapse,
  hazardousSpill,
  other,
}

enum EmergencySeverity {
  low,
  medium,
  high,
  critical,
}

enum EmergencyStatus {
  active,
  contained,
  resolved,
  cancelled,
}

extension EmergencyTypeExtension on EmergencyType {
  String get displayName {
    switch (this) {
      case EmergencyType.earthquake:
        return 'Terremoto / Sismo';
      case EmergencyType.flood:
        return 'Inundación';
      case EmergencyType.hurricane:
        return 'Huracán / Tormenta';
      case EmergencyType.wildfire:
        return 'Incendio Forestal';
      case EmergencyType.landslide:
        return 'Deslave / Derrumbe';
      case EmergencyType.volcanicEruption:
        return 'Erupción Volcánica';
      case EmergencyType.tsunami:
        return 'Tsunami';
      case EmergencyType.explosion:
        return 'Explosión';
      case EmergencyType.buildingCollapse:
        return 'Colapso Estructural';
      case EmergencyType.hazardousSpill:
        return 'Derrame Químico';
      case EmergencyType.other:
        return 'Otra Emergencia';
    }
  }

  String toBackendString() {
    switch (this) {
      case EmergencyType.earthquake:
        return 'EARTHQUAKE';
      case EmergencyType.flood:
        return 'FLOOD';
      case EmergencyType.hurricane:
        return 'HURRICANE';
      case EmergencyType.wildfire:
        return 'WILDFIRE';
      case EmergencyType.landslide:
        return 'LANDSLIDE';
      case EmergencyType.volcanicEruption:
        return 'VOLCANIC_ERUPTION';
      case EmergencyType.tsunami:
        return 'TSUNAMI';
      case EmergencyType.explosion:
        return 'EXPLOSION';
      case EmergencyType.buildingCollapse:
        return 'BUILDING_COLLAPSE';
      case EmergencyType.hazardousSpill:
        return 'HAZARDOUS_SPILL';
      case EmergencyType.other:
        return 'OTHER';
    }
  }

  static EmergencyType fromString(String? val) {
    if (val == null) return EmergencyType.other;
    final normalized = val.toUpperCase();
    for (final t in EmergencyType.values) {
      if (t.toBackendString() == normalized || t.name.toUpperCase() == normalized) {
        return t;
      }
    }
    return EmergencyType.other;
  }
}

extension EmergencySeverityExtension on EmergencySeverity {
  String get displayName {
    switch (this) {
      case EmergencySeverity.low:
        return 'Baja';
      case EmergencySeverity.medium:
        return 'Media';
      case EmergencySeverity.high:
        return 'Alta';
      case EmergencySeverity.critical:
        return 'Crítica';
    }
  }

  String toBackendString() => name.toUpperCase();

  static EmergencySeverity fromString(String? val) {
    if (val == null) return EmergencySeverity.medium;
    final normalized = val.toUpperCase();
    for (final s in EmergencySeverity.values) {
      if (s.name.toUpperCase() == normalized) return s;
    }
    return EmergencySeverity.medium;
  }
}

extension EmergencyStatusExtension on EmergencyStatus {
  String get displayName {
    switch (this) {
      case EmergencyStatus.active:
        return 'Activa';
      case EmergencyStatus.contained:
        return 'Contenida';
      case EmergencyStatus.resolved:
        return 'Resuelta';
      case EmergencyStatus.cancelled:
        return 'Cancelada';
    }
  }

  String toBackendString() => name.toUpperCase();

  static EmergencyStatus fromString(String? val) {
    if (val == null) return EmergencyStatus.active;
    final normalized = val.toUpperCase();
    for (final s in EmergencyStatus.values) {
      if (s.name.toUpperCase() == normalized) return s;
    }
    return EmergencyStatus.active;
  }
}

/// Modelo de dominio para Emergencia / Desastre.
class Emergency {
  final String id;
  final String title;
  final String? description;
  final EmergencyType type;
  final EmergencySeverity severity;
  final EmergencyStatus status;
  final double latitude;
  final double longitude;
  final double? radiusMeters;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  const Emergency({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.severity,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.radiusMeters,
    required this.startedAt,
    this.endedAt,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'synced',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.toBackendString(),
    'severity': severity.toBackendString(),
    'status': status.toBackendString(),
    'latitude': latitude,
    'longitude': longitude,
    'radiusMeters': radiusMeters,
    'startedAt': startedAt.toUtc().toIso8601String(),
    'endedAt': endedAt?.toUtc().toIso8601String(),
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'syncStatus': syncStatus,
  };

  Map<String, dynamic> toDatabaseMap() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.toBackendString(),
    'severity': severity.toBackendString(),
    'status': status.toBackendString(),
    'latitude': latitude,
    'longitude': longitude,
    'radius_meters': radiusMeters,
    'started_at': startedAt.toUtc().toIso8601String(),
    'ended_at': endedAt?.toUtc().toIso8601String(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'sync_status': syncStatus,
  };

  factory Emergency.fromJson(Map<String, dynamic> json) => Emergency(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    type: EmergencyTypeExtension.fromString(json['type'] as String?),
    severity: EmergencySeverityExtension.fromString(json['severity'] as String?),
    status: EmergencyStatusExtension.fromString(json['status'] as String?),
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    radiusMeters: (json['radiusMeters'] ?? json['radius_meters'] as num?)?.toDouble(),
    startedAt: DateTime.parse((json['startedAt'] ?? json['started_at']) as String),
    endedAt: (json['endedAt'] ?? json['ended_at']) != null
        ? DateTime.parse((json['endedAt'] ?? json['ended_at']) as String)
        : null,
    createdAt: DateTime.parse((json['createdAt'] ?? json['created_at']) as String),
    updatedAt: DateTime.parse((json['updatedAt'] ?? json['updated_at']) as String),
    syncStatus: json['syncStatus'] ?? json['sync_status'] ?? 'synced',
  );
}
