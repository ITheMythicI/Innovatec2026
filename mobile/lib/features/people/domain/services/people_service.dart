import 'dart:async';
import 'package:innovatec_mobile/core/audit/audit_event.dart';
import 'package:innovatec_mobile/core/audit/audit_service.dart';
import 'package:innovatec_mobile/core/security/crypto_service.dart';
import 'package:innovatec_mobile/core/security/roles_and_permissions.dart';
import 'package:innovatec_mobile/features/people/domain/models/person_report.dart';

/// Servicio Offline-First para Personas Desaparecidas, Encontradas y Protocolo de Menores.
class PeopleService {
  static final PeopleService _instance = PeopleService._internal();
  factory PeopleService() => _instance;

  PeopleService._internal() {
    _initDefaultReports();
  }

  final _reportsController = StreamController<List<PersonReport>>.broadcast();
  final List<PersonReport> _reports = [];

  Stream<List<PersonReport>> get reportsStream => _reportsController.stream;
  List<PersonReport> get allReports => List.unmodifiable(_reports);

  void _initDefaultReports() {
    _reports.addAll([
      PersonReport(
        id: 'REP-DES-001',
        type: PersonReportType.missing,
        fullName: 'Mateo Emiliano Morales',
        age: 7,
        isMinor: true,
        gender: 'Masculino',
        physicalDescription: 'Altura 1.20m, playera roja de superhéroe, pantalón de mezclilla azul y tenis blancos.',
        privateDistinctiveMarks: 'Pequeña cicatriz en forma de media luna detrás de la oreja izquierda.',
        lastKnownLocation: 'Parque México, Col. Hipódromo Condesa',
        latitude: 19.4124,
        longitude: -99.1698,
        contactPhone: '+52 55 3344 5566',
        reporterName: 'Mariana Morales (Madre)',
        reporterRelationship: 'Madre',
        status: VerificationStatus.underReview,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PersonReport(
        id: 'REP-ALB-002',
        type: PersonReportType.foundSheltered,
        fullName: 'Santiago Velázquez',
        age: 6,
        isMinor: true,
        gender: 'Masculino',
        physicalDescription: 'Playera azul con estampado de dinosaurio, tenis negros con luces.',
        privateDistinctiveMarks: 'Lunar visible en el antebrazo derecho.',
        lastKnownLocation: 'Rescatado en cruce Av. Insurgentes y Viaducto',
        currentShelterName: 'Albergue Deportivo Benito Juárez',
        contactPhone: '+52 55 9988 7766 (Admin Albergue)',
        reporterName: 'Capitán Luis Rivas (SEDENA)',
        reporterRelationship: 'Brigada de Rescate Oficial',
        status: VerificationStatus.verifiedByAuthority,
        verifiedByOfficialId: 'SEDENA-BRIG-902',
        verifiedByOfficialName: 'Capitán Luis Rivas',
        officialReunificationNotes: 'Menor resguardado en área de pediatría del albergue.',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PersonReport(
        id: 'REP-DES-003',
        type: PersonReportType.missing,
        fullName: 'Guillermo Fernández Ortiz',
        age: 52,
        isMinor: false,
        gender: 'Masculino',
        physicalDescription: 'Estatura 1.78m, complexión robusta, cabello cano, chaleco negro.',
        privateDistinctiveMarks: 'Tatuaje de ancla en muñeca derecha.',
        lastKnownLocation: 'Col. Doctores cerca de Metro Niños Héroes',
        latitude: 19.4201,
        longitude: -99.1512,
        contactPhone: '+52 55 1122 3344',
        reporterName: 'Claudia Fernández',
        reporterRelationship: 'Hija',
        status: VerificationStatus.unverified,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      PersonReport(
        id: 'REP-ALB-004',
        type: PersonReportType.foundSheltered,
        fullName: 'Carmen Josefina Lozano',
        age: 74,
        isMinor: false,
        gender: 'Femenino',
        physicalDescription: 'Vestido floreado morado, suéter beige, bastón de aluminio.',
        privateDistinctiveMarks: 'Usa lentes de armazón grueso dorado.',
        lastKnownLocation: 'Rescatada en Calzada de Tlalpan',
        currentShelterName: 'Albergue Estadio Jesús Martínez',
        contactPhone: '+52 55 4433 2211',
        reporterName: 'Trabajo Social Albergue',
        reporterRelationship: 'Personal de Refugio',
        status: VerificationStatus.verifiedByAuthority,
        verifiedByOfficialId: 'PC-CDMX-4821',
        verifiedByOfficialName: 'Oficial Daniel Alarcón',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ]);
    _reportsController.add(_reports);
  }

  List<PersonReport> searchReports({
    String query = '',
    PersonReportType? typeFilter,
    bool? minorsOnly,
    required UserRole currentRole,
  }) {
    final canViewSensitive = RbacService.hasPermission(currentRole, AppPermission.viewSensitiveMinorDetails);

    return _reports.where((report) {
      if (typeFilter != null && report.type != typeFilter) return false;
      if (minorsOnly == true && !report.isMinor) return false;

      if (query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        final matchName = report.fullName.toLowerCase().contains(q);
        final matchLocation = report.lastKnownLocation.toLowerCase().contains(q);
        final matchDesc = report.physicalDescription.toLowerCase().contains(q);
        final matchShelter = report.currentShelterName?.toLowerCase().contains(q) ?? false;
        if (!matchName && !matchLocation && !matchDesc && !matchShelter) return false;
      }

      return true;
    }).map((report) {
      if (report.isMinor && !canViewSensitive) {
        return report.toMaskedForCitizen();
      }
      return report;
    }).toList();
  }

  Future<PersonReport> createReport({
    required PersonReportType type,
    required String fullName,
    required int age,
    required bool isMinor,
    required String gender,
    required String physicalDescription,
    String? privateDistinctiveMarks,
    required String lastKnownLocation,
    double? latitude,
    double? longitude,
    String? currentShelterName,
    required String contactPhone,
    required String reporterName,
    required String reporterRelationship,
    required String actorUserId,
    required UserRole actorRole,
  }) async {
    final newReport = PersonReport(
      id: 'REP-${type == PersonReportType.missing ? "DES" : "ALB"}-${CryptoService.generateId().substring(0, 8).toUpperCase()}',
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
      currentShelterName: currentShelterName,
      contactPhone: contactPhone,
      reporterName: reporterName,
      reporterRelationship: reporterRelationship,
      status: (actorRole == UserRole.authority || actorRole == UserRole.shelterAdmin)
          ? VerificationStatus.verifiedByAuthority
          : VerificationStatus.unverified,
      verifiedByOfficialId: (actorRole == UserRole.authority || actorRole == UserRole.shelterAdmin) ? actorUserId : null,
      verifiedByOfficialName: (actorRole == UserRole.authority || actorRole == UserRole.shelterAdmin) ? reporterName : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _reports.insert(0, newReport);
    _reportsController.add(_reports);

    await AuditService().logEvent(
      eventType: type == PersonReportType.missing
          ? AuditEventType.missingPersonReported
          : AuditEventType.foundPersonReported,
      actorUserId: actorUserId,
      actorRole: actorRole.code,
      entityId: newReport.id,
      metadata: {
        'fullName': fullName,
        'age': age,
        'isMinor': isMinor,
        'type': type.name,
        'location': lastKnownLocation,
      },
    );

    return newReport;
  }

  Future<void> authorizeReunificationOrVerify({
    required String reportId,
    required VerificationStatus newStatus,
    required String officialNotes,
    required String officialId,
    required String officialName,
    required UserRole officialRole,
  }) async {
    final hasPerm = RbacService.hasPermission(officialRole, AppPermission.authorizeMinorReunification);
    if (!hasPerm) {
      throw Exception('Acceso Denegado: Su rol (${officialRole.displayName}) no está facultado para autorizar entregas o cambios oficiales.');
    }

    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) throw Exception('Reporte no encontrado');

    final oldReport = _reports[index];
    final updatedReport = oldReport.copyWith(
      status: newStatus,
      verifiedByOfficialId: officialId,
      verifiedByOfficialName: officialName,
      officialReunificationNotes: officialNotes,
      updatedAt: DateTime.now(),
    );

    _reports[index] = updatedReport;
    _reportsController.add(_reports);

    await AuditService().logEvent(
      eventType: oldReport.isMinor
          ? AuditEventType.minorReunificationAuthorized
          : AuditEventType.personStatusVerified,
      actorUserId: officialId,
      actorRole: officialRole.code,
      entityId: reportId,
      metadata: {
        'personName': oldReport.fullName,
        'isMinor': oldReport.isMinor,
        'newStatus': newStatus.name,
        'officialName': officialName,
        'officialNotes': officialNotes,
      },
    );
  }

  Future<void> logSensitiveMinorAccess({
    required String reportId,
    required String officialUserId,
    required String officialRole,
  }) async {
    await AuditService().logEvent(
      eventType: AuditEventType.sensitiveMinorViewed,
      actorUserId: officialUserId,
      actorRole: officialRole,
      entityId: reportId,
      metadata: {'action': 'VIEW_SENSITIVE_MINOR_DETAILS'},
    );
  }
}
