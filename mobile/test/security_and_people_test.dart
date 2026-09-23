import 'package:flutter_test/flutter_test.dart';
import 'package:innovatec_mobile/core/security/crypto_service.dart';
import 'package:innovatec_mobile/core/security/roles_and_permissions.dart';
import 'package:innovatec_mobile/core/audit/audit_service.dart';
import 'package:innovatec_mobile/core/audit/audit_event.dart';
import 'package:innovatec_mobile/features/people/domain/models/person_report.dart';
import 'package:innovatec_mobile/features/people/domain/services/people_service.dart';
import 'package:innovatec_mobile/features/families/domain/services/family_service.dart';
import 'package:innovatec_mobile/features/families/domain/models/family_member.dart';

void main() {
  group('1. CryptoService Tests', () {
    test('Calculates consistent deterministic SHA-256 hashes', () {
      final map1 = {'b': 2, 'a': 1};
      final map2 = {'a': 1, 'b': 2};

      final hash1 = CryptoService.hashData(map1);
      final hash2 = CryptoService.hashData(map2);

      expect(hash1, equals(hash2));
      expect(hash1.length, equals(64));
    });

    test('Digital signature creation and validation', () {
      const secret = 'TOP_SECRET_KEY';
      const payload = 'SOS_COORDINATES_19.4124_-99.1698';

      final signature = CryptoService.signPayload(payload, secret);
      final isValid = CryptoService.verifySignature(
        payload: payload,
        signature: signature,
        publicKeyOrSecret: secret,
      );

      expect(isValid, isTrue);

      final isTamperedValid = CryptoService.verifySignature(
        payload: 'TAMPERED_PAYLOAD',
        signature: signature,
        publicKeyOrSecret: secret,
      );
      expect(isTamperedValid, isFalse);
    });
  });

  group('2. RBAC & Permissions Matrix Tests', () {
    test('Citizens cannot access sensitive minor data or verify reunifications', () {
      const citizenRole = UserRole.citizen;

      expect(RbacService.hasPermission(citizenRole, AppPermission.viewSensitiveMinorDetails), isFalse);
      expect(RbacService.hasPermission(citizenRole, AppPermission.verifyMissingPersonReport), isFalse);
      expect(RbacService.hasPermission(citizenRole, AppPermission.authorizeMinorReunification), isFalse);
      expect(RbacService.hasPermission(citizenRole, AppPermission.reportMissingPerson), isTrue);
    });

    test('Authorities and Shelter Admins have verification and child protection privileges', () {
      expect(RbacService.hasPermission(UserRole.authority, AppPermission.viewSensitiveMinorDetails), isTrue);
      expect(RbacService.hasPermission(UserRole.authority, AppPermission.authorizeMinorReunification), isTrue);
      expect(RbacService.hasPermission(UserRole.shelterAdmin, AppPermission.authorizeMinorReunification), isTrue);
    });
  });

  group('3. PeopleService & Minor Data Masking Tests', () {
    test('Masks sensitive details of minors for regular citizen queries', () {
      final peopleService = PeopleService();

      final resultsForCitizen = peopleService.searchReports(
        minorsOnly: true,
        currentRole: UserRole.citizen,
      );

      expect(resultsForCitizen.isNotEmpty, isTrue);
      final minorReport = resultsForCitizen.first;

      expect(minorReport.contactPhone, contains('PROTEGIDO'));
      expect(minorReport.privateDistinctiveMarks, contains('PROTEGIDO'));
    });

    test('Shows complete unmasked data for Authority queries', () {
      final peopleService = PeopleService();

      final resultsForAuthority = peopleService.searchReports(
        minorsOnly: true,
        currentRole: UserRole.authority,
      );

      expect(resultsForAuthority.isNotEmpty, isTrue);
      final minorReport = resultsForAuthority.first;

      expect(minorReport.contactPhone, isNot(contains('PROTEGIDO')));
      expect(minorReport.privateDistinctiveMarks, isNot(contains('PROTEGIDO')));
    });
  });

  group('4. AuditService & Hash Chain Integrity Tests', () {
    test('Logs chained events and passes cryptographic verification', () async {
      final auditService = AuditService();

      await auditService.logEvent(
        eventType: AuditEventType.authLogin,
        actorUserId: 'TEST-USER',
        actorRole: 'CITIZEN',
        entityId: 'TEST-ENTITY',
        metadata: {'test': true},
      );

      final verification = auditService.verifyChainIntegrity();
      expect(verification.isValid, isTrue);
      expect(verification.totalEvents, greaterThanOrEqualTo(2));
    });
  });

  group('5. FamilyService Tests', () {
    test('Updates member status and calculates status badges correctly', () async {
      final familyService = FamilyService();
      final family = familyService.currentFamily;
      expect(family, isNotNull);

      final memberId = family!.members.first.id;
      await familyService.updateMemberStatus(
        memberId: memberId,
        newStatus: MemberEmergencyStatus.safe,
        actorUserId: 'USR-01',
        actorRole: 'CITIZEN',
      );

      expect(familyService.currentFamily!.safeCount, greaterThanOrEqualTo(1));
    });
  });
}
