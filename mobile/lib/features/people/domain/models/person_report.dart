/// Tipo de reporte de persona en zona de emergencia.
enum PersonReportType {
  missing, // Desaparecida / Sin localizar
  foundSheltered, // Encontrada / Albergada
  sighting, // Avistamiento reportado por ciudadano
}

/// Estado de resolución y verificación oficial del reporte.
enum VerificationStatus {
  unverified, // Reporte comunitario sin validar
  underReview, // En revisión por brigadistas o albergue
  verifiedByAuthority, // Validado oficialmente por Protección Civil / Autoridad
  reunited, // Reunificación confirmada oficialmente
}

extension VerificationStatusExtension on VerificationStatus {
  String get label {
    switch (this) {
      case VerificationStatus.unverified:
        return 'No Verificado';
      case VerificationStatus.underReview:
        return 'En Revisión';
      case VerificationStatus.verifiedByAuthority:
        return 'Verificado Oficial';
      case VerificationStatus.reunited:
        return 'Reunificado / Entregado';
    }
  }
}

/// Modelo de reporte de persona desaparecida o encontrada.
class PersonReport {
  final String id;
  final PersonReportType type;
  final String fullName;
  final int age;
  final bool isMinor;
  final String gender;
  final String physicalDescription; // Altura, tez, complexión, vestimenta
  final String? privateDistinctiveMarks; // Tatuajes, cicatrices (DATO SENSIBLE)
  final String lastKnownLocation;
  final double? latitude;
  final double? longitude;
  final String? currentShelterName;
  final String contactPhone; // DATO SENSIBLE EN CASO DE MENORES
  final String reporterName;
  final String reporterRelationship;
  final VerificationStatus status;
  final String? verifiedByOfficialId;
  final String? verifiedByOfficialName;
  final String? officialReunificationNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PersonReport({
    required this.id,
    required this.type,
    required this.fullName,
    required this.age,
    required this.isMinor,
    required this.gender,
    required this.physicalDescription,
    this.privateDistinctiveMarks,
    required this.lastKnownLocation,
    this.latitude,
    this.longitude,
    this.currentShelterName,
    required this.contactPhone,
    required this.reporterName,
    required this.reporterRelationship,
    required this.status,
    this.verifiedByOfficialId,
    this.verifiedByOfficialName,
    this.officialReunificationNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Retorna una versión sanitizada que oculta datos sensibles de menores si el rol no está autorizado.
  PersonReport toMaskedForCitizen() {
    if (!isMinor) return this;

    return PersonReport(
      id: id,
      type: type,
      fullName: _maskName(fullName),
      age: age,
      isMinor: true,
      gender: gender,
      physicalDescription: physicalDescription,
      privateDistinctiveMarks: '[PROTEGIDO: Solo visible por Autoridades y Administradores de Albergue]',
      lastKnownLocation: lastKnownLocation,
      latitude: latitude,
      longitude: longitude,
      currentShelterName: currentShelterName,
      contactPhone: '[PROTEGIDO POR PROTOCOLO DE MENORES]',
      reporterName: 'Familiar Registrado (Verificado en Albergue)',
      reporterRelationship: reporterRelationship,
      status: status,
      verifiedByOfficialId: verifiedByOfficialId,
      verifiedByOfficialName: verifiedByOfficialName,
      officialReunificationNotes: officialReunificationNotes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static String _maskName(String name) {
    final parts = name.split(' ');
    if (parts.length <= 1) return name;
    return '${parts[0]} ${parts.sublist(1).map((p) => p.isNotEmpty ? '${p[0]}***' : '').join(' ')}';
  }

  PersonReport copyWith({
    VerificationStatus? status,
    String? verifiedByOfficialId,
    String? verifiedByOfficialName,
    String? officialReunificationNotes,
    String? currentShelterName,
    DateTime? updatedAt,
  }) {
    return PersonReport(
      id: id,
      type: type,
      fullName: fullName,
      age: age,
      isMinor: isMinor,
      gender: gender,
      physicalDescription: physicalDescription,
      privateDistinctiveMarks: privateDistinctiveMarks,
      lastKnownLocation: lastKnownLocation,
      latitude: latitude,
      longitude: longitude,
      currentShelterName: currentShelterName ?? this.currentShelterName,
      contactPhone: contactPhone,
      reporterName: reporterName,
      reporterRelationship: reporterRelationship,
      status: status ?? this.status,
      verifiedByOfficialId: verifiedByOfficialId ?? this.verifiedByOfficialId,
      verifiedByOfficialName: verifiedByOfficialName ?? this.verifiedByOfficialName,
      officialReunificationNotes: officialReunificationNotes ?? this.officialReunificationNotes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'fullName': fullName,
    'age': age,
    'isMinor': isMinor,
    'gender': gender,
    'physicalDescription': physicalDescription,
    'privateDistinctiveMarks': privateDistinctiveMarks,
    'lastKnownLocation': lastKnownLocation,
    'latitude': latitude,
    'longitude': longitude,
    'currentShelterName': currentShelterName,
    'contactPhone': contactPhone,
    'reporterName': reporterName,
    'reporterRelationship': reporterRelationship,
    'status': status.name,
    'verifiedByOfficialId': verifiedByOfficialId,
    'verifiedByOfficialName': verifiedByOfficialName,
    'officialReunificationNotes': officialReunificationNotes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory PersonReport.fromJson(Map<String, dynamic> json) => PersonReport(
    id: json['id'] as String,
    type: PersonReportType.values.firstWhere((e) => e.name == json['type']),
    fullName: json['fullName'] as String,
    age: json['age'] as int,
    isMinor: json['isMinor'] as bool? ?? false,
    gender: json['gender'] as String,
    physicalDescription: json['physicalDescription'] as String,
    privateDistinctiveMarks: json['privateDistinctiveMarks'] as String?,
    lastKnownLocation: json['lastKnownLocation'] as String,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    currentShelterName: json['currentShelterName'] as String?,
    contactPhone: json['contactPhone'] as String,
    reporterName: json['reporterName'] as String,
    reporterRelationship: json['reporterRelationship'] as String,
    status: VerificationStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => VerificationStatus.unverified,
    ),
    verifiedByOfficialId: json['verifiedByOfficialId'] as String?,
    verifiedByOfficialName: json['verifiedByOfficialName'] as String?,
    officialReunificationNotes: json['officialReunificationNotes'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}
