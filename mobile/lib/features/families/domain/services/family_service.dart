import 'dart:async';
import 'package:innovatec_mobile/core/audit/audit_event.dart';
import 'package:innovatec_mobile/core/audit/audit_service.dart';
import 'package:innovatec_mobile/core/security/crypto_service.dart';
import 'package:innovatec_mobile/database/app_database.dart';
import 'package:innovatec_mobile/features/families/domain/models/family_group.dart';
import 'package:innovatec_mobile/features/families/domain/models/family_member.dart';
import 'package:innovatec_mobile/sync/sync_manager.dart';

/// Servicio gestor de Familias y Núcleos de Confianza Offline-First.
class FamilyService {
  static final FamilyService _instance = FamilyService._internal();
  factory FamilyService() => _instance;

  FamilyService._internal() {
    _initDefaultFamily();
  }

  final _familyController = StreamController<FamilyGroup?>.broadcast();
  FamilyGroup? _currentFamily;

  Stream<FamilyGroup?> get familyStream => _familyController.stream;
  FamilyGroup? get currentFamily => _currentFamily;

  void _initDefaultFamily() {
    _currentFamily = FamilyGroup(
      id: 'FAM-CDMX-01',
      familyName: 'Familia Mendoza Garza',
      headOfHouseholdUserId: 'USR-DEV-001',
      meetingPointLocation: 'Parque México, Frente al Foro Lindbergh',
      members: [
        FamilyMember(
          id: 'MBR-01',
          fullName: 'Carlos Mendoza Ruiz',
          relationship: 'Titular / Cónyuge',
          age: 28,
          isMinor: false,
          status: MemberEmergencyStatus.safe,
          lastKnownLocation: 'Parque México, Condesa',
          notes: 'Con equipo de primeros auxilios y radio',
          lastStatusUpdate: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        FamilyMember(
          id: 'MBR-02',
          fullName: 'Ana Sofía Garza Vega',
          relationship: 'Cónyuge',
          age: 27,
          isMinor: false,
          status: MemberEmergencyStatus.inShelter,
          shelterName: 'Albergue Estadio Jesús Martínez',
          lastKnownLocation: 'Col. Magdalena Mixhuca',
          notes: 'Registrada en refugio con batería al 15%',
          lastStatusUpdate: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
        FamilyMember(
          id: 'MBR-03',
          fullName: 'Mateo Mendoza Garza',
          relationship: 'Hijo',
          age: 5,
          isMinor: true,
          status: MemberEmergencyStatus.inShelter,
          shelterName: 'Albergue Estadio Jesús Martínez',
          lastKnownLocation: 'Con su madre Ana Sofía',
          notes: 'Alergia al polvo, con su madre',
          lastStatusUpdate: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
        FamilyMember(
          id: 'MBR-04',
          fullName: 'Elena Ruiz Vda. de Mendoza',
          relationship: 'Madre / Adulto Mayor',
          age: 68,
          isMinor: false,
          status: MemberEmergencyStatus.unreachable,
          lastKnownLocation: 'Col. Roma Norte (Piso 2)',
          notes: 'Medicamento para hipertensión pendiente',
          lastStatusUpdate: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    );

    // Persiste en SQLite
    AppDatabase.instance.familiesDao.insertOrUpdateFamily({
      'id': _currentFamily!.id,
      'family_name': _currentFamily!.familyName,
      'emergency_meeting_point': _currentFamily!.meetingPointLocation,
      'representative_contact': _currentFamily!.headOfHouseholdUserId,
      'notes': '',
      'last_status_update': DateTime.now().toUtc().toIso8601String(),
    });
    AppDatabase.instance.familiesDao.insertOrUpdateMembers(
      _currentFamily!.id,
      _currentFamily!.members.map((m) => m.toJson()).toList(),
    );

    _familyController.add(_currentFamily);
  }

  Future<void> updateMemberStatus({
    required String memberId,
    required MemberEmergencyStatus newStatus,
    String? shelterName,
    String? lastKnownLocation,
    String? notes,
    required String actorUserId,
    required String actorRole,
  }) async {
    if (_currentFamily == null) return;

    final updatedMembers = _currentFamily!.members.map((member) {
      if (member.id == memberId) {
        return member.copyWith(
          status: newStatus,
          shelterName: shelterName ?? member.shelterName,
          lastKnownLocation: lastKnownLocation ?? member.lastKnownLocation,
          notes: notes ?? member.notes,
          lastStatusUpdate: DateTime.now(),
        );
      }
      return member;
    }).toList();

    _currentFamily = _currentFamily!.copyWith(members: updatedMembers);
    _familyController.add(_currentFamily);

    // Persistencia SQLite
    await AppDatabase.instance.familiesDao.insertOrUpdateMembers(
      _currentFamily!.id,
      updatedMembers.map((m) => m.toJson()).toList(),
    );

    // Encolar mutación
    await SyncManager.instance.enqueueLocalMutation(
      entityType: 'family_member_status',
      entityId: memberId,
      operation: 'UPDATE',
      payload: {
        'familyId': _currentFamily!.id,
        'memberId': memberId,
        'newStatus': newStatus.name,
        'shelter': shelterName,
        'location': lastKnownLocation,
      },
    );

    await AuditService().logEvent(
      eventType: AuditEventType.familyMemberStatusChanged,
      actorUserId: actorUserId,
      actorRole: actorRole,
      entityId: memberId,
      metadata: {
        'familyId': _currentFamily!.id,
        'newStatus': newStatus.name,
        'shelter': shelterName,
        'location': lastKnownLocation,
      },
    );
  }

  Future<void> addMember({
    required String fullName,
    required String relationship,
    required int age,
    required bool isMinor,
    required MemberEmergencyStatus status,
    String? notes,
    required String actorUserId,
    required String actorRole,
  }) async {
    final newMember = FamilyMember(
      id: CryptoService.generateId(),
      fullName: fullName,
      relationship: relationship,
      age: age,
      isMinor: isMinor,
      status: status,
      notes: notes,
      lastStatusUpdate: DateTime.now(),
    );

    final members = List<FamilyMember>.from(_currentFamily?.members ?? [])..add(newMember);
    _currentFamily = _currentFamily?.copyWith(members: members) ??
        FamilyGroup(
          id: CryptoService.generateId(),
          familyName: 'Mi Familia',
          headOfHouseholdUserId: actorUserId,
          meetingPointLocation: 'Punto de reunión acordado',
          members: members,
          createdAt: DateTime.now(),
        );

    _familyController.add(_currentFamily);

    // Persistencia SQLite
    await AppDatabase.instance.familiesDao.insertOrUpdateMembers(
      _currentFamily!.id,
      members.map((m) => m.toJson()).toList(),
    );

    // Encolar mutación
    await SyncManager.instance.enqueueLocalMutation(
      entityType: 'family_member',
      entityId: newMember.id,
      operation: 'CREATE',
      payload: newMember.toJson(),
    );

    await AuditService().logEvent(
      eventType: AuditEventType.familyCreated,
      actorUserId: actorUserId,
      actorRole: actorRole,
      entityId: newMember.id,
      metadata: {
        'name': fullName,
        'relationship': relationship,
        'isMinor': isMinor,
      },
    );
  }
}
