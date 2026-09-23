import 'dart:async';
import 'package:innovatec_mobile/core/audit/audit_event.dart';
import 'package:innovatec_mobile/core/audit/audit_service.dart';
import 'package:innovatec_mobile/features/user_profile/domain/models/user_profile.dart';

/// Servicio gestor del perfil médico de emergencia del usuario.
class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;

  ProfileService._internal() {
    _initDefaultProfile();
  }

  final _profileController = StreamController<UserProfile>.broadcast();
  UserProfile? _profile;

  Stream<UserProfile> get profileStream => _profileController.stream;
  UserProfile get currentProfile => _profile ?? _createDefaultProfile();

  void _initDefaultProfile() {
    _profile = _createDefaultProfile();
    _profileController.add(_profile!);
  }

  UserProfile _createDefaultProfile() {
    return UserProfile(
      userId: 'USR-DEV-001',
      fullName: 'Carlos Mendoza Ruiz',
      age: 28,
      bloodType: 'O+',
      allergies: ['Penicilina', 'Sulfamidas'],
      chronicConditions: ['Asma leve'],
      vitalMedications: ['Salbutamol aerosol (en caso de crisis)'],
      isOrganDonor: true,
      medicalNotes: 'Usa lentes de contacto. Contactar primero a cónyuge.',
      emergencyContacts: [
        EmergencyContact(
          name: 'Ana Sofía Garza (Esposa)',
          relationship: 'Cónyuge',
          phone: '+52 55 1234 5678',
          isPriorityAlert: true,
        ),
        EmergencyContact(
          name: 'Dr. Roberto Mendoza (Padre)',
          relationship: 'Padre / Médico',
          phone: '+52 55 8765 4321',
          isPriorityAlert: true,
        ),
      ],
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> updateProfile(UserProfile updatedProfile, {required String actorRole}) async {
    _profile = updatedProfile;
    _profileController.add(_profile!);

    await AuditService().logEvent(
      eventType: AuditEventType.emergencyProfileUpdated,
      actorUserId: updatedProfile.userId,
      actorRole: actorRole,
      entityId: updatedProfile.userId,
      metadata: {
        'bloodType': updatedProfile.bloodType,
        'allergiesCount': updatedProfile.allergies.length,
        'contactsCount': updatedProfile.emergencyContacts.length,
      },
    );
  }
}
