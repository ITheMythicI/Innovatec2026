import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innovatec_mobile/core/security/roles_and_permissions.dart';
import 'package:innovatec_mobile/database/app_database.dart';
import 'package:innovatec_mobile/features/auth/domain/services/auth_service.dart';
import 'package:innovatec_mobile/features/auth/presentation/screens/auth_screen.dart';
import 'package:innovatec_mobile/features/broadcasts/presentation/screens/official_broadcasts_screen.dart';
import 'package:innovatec_mobile/features/emergencies/presentation/screens/emergencies_screen.dart';
import 'package:innovatec_mobile/features/families/presentation/screens/family_hub_screen.dart';
import 'package:innovatec_mobile/features/map/presentation/screens/evacuation_route_screen.dart';
import 'package:innovatec_mobile/sync/sync_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AppDatabase.instance.initialize();
  });

  setUp(() {
    SyncManager.instance.stopPeriodicSync();
  });

  group('1. AuthService & Role RBAC Tests', () {
    test('UserRole mapping matches backend Prisma and mobile codes', () {
      expect(UserRoleExtension.fromCode('USER'), UserRole.citizen);
      expect(UserRoleExtension.fromCode('CITIZEN'), UserRole.citizen);
      expect(UserRoleExtension.fromCode('COMMANDER'), UserRole.authority);
      expect(UserRoleExtension.fromCode('OPERATOR'), UserRole.authority);
      expect(UserRoleExtension.fromCode('SUPER_ADMIN'), UserRole.systemAdmin);
      expect(UserRole.citizen.toBackendRole, 'USER');
      expect(UserRole.authority.toBackendRole, 'COMMANDER');
    });

    test('AuditLog permissions: Citizen has NO access, Authority and Shelter Admin have access', () {
      expect(RbacService.hasPermission(UserRole.citizen, AppPermission.viewAuditLog), isFalse);
      expect(RbacService.hasPermission(UserRole.volunteer, AppPermission.viewAuditLog), isFalse);
      expect(RbacService.hasPermission(UserRole.shelterAdmin, AppPermission.viewAuditLog), isTrue);
      expect(RbacService.hasPermission(UserRole.authority, AppPermission.viewAuditLog), isTrue);
      expect(RbacService.hasPermission(UserRole.systemAdmin, AppPermission.viewAuditLog), isTrue);
    });

    test('AuthService guestEmergencyLogin generates anonymous citizen profile', () async {
      final guest = await AuthService().guestEmergencyLogin();
      expect(guest.role, UserRole.citizen);
      expect(guest.isOfflineEmergencyUser, isTrue);
      expect(guest.fullName, contains('SOS'));
    });

    test('AuthService switchUserRole updates state and role permissions', () async {
      await AuthService().switchUserRole(UserRole.authority);
      expect(AuthService().currentUser?.role, UserRole.authority);
      expect(AuthService().currentUser?.hasPermission(AppPermission.viewAuditLog), isTrue);

      await AuthService().switchUserRole(UserRole.citizen);
      expect(AuthService().currentUser?.role, UserRole.citizen);
      expect(AuthService().currentUser?.hasPermission(AppPermission.viewAuditLog), isFalse);
    });
  });

  group('2. Tactical Screen Widgets Rendering Tests', () {
    testWidgets('AuthScreen renders Iniciar Sesión and Registro multi-paso tabs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AuthScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('RESGUARDO // ACCESO'), findsOneWidget);
      expect(find.text('INICIAR SESIÓN'), findsOneWidget);
      expect(find.text('CREAR CUENTA'), findsOneWidget);
      expect(find.text('ENTRAR A RESGUARDO'), findsOneWidget);
      expect(find.text('MODO INVITADO / SOS DIRECTO'), findsOneWidget);

      // Switch to Registro tab
      await tester.tap(find.text('CREAR CUENTA'));
      await tester.pumpAndSettle();

      expect(find.text('Datos de Resguardo Civil'), findsOneWidget);
      expect(find.text('NOMBRE COMPLETO *'), findsOneWidget);
      expect(find.text('SIGUIENTE: RED FAMILIAR SOS'), findsOneWidget);
    });

    testWidgets('EmergenciesScreen renders Modo Pánico Activo and critical SOS buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: EmergenciesScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('MODO PÁNICO // ACTIVO'), findsOneWidget);
      expect(find.text('+1.4M NIVEL DE AGUA'), findsOneWidget);
      expect(find.text('¡ALERTA DE INUNDACIÓN EN TU ZONA!'), findsOneWidget);
      expect(find.text('PEDIR AUXILIO / SOS'), findsOneWidget);
      expect(find.text('MILITAR + SAT'), findsOneWidget);
      expect(find.text('ESTOY A SALVO'), findsOneWidget);
      expect(find.text('Gimnasio Benito Juárez'), findsOneWidget);
      expect(find.text('EMERGENCIA 911'), findsOneWidget);
    });

    testWidgets('EvacuationRouteScreen renders turn-by-turn guidance and shelter services', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: EvacuationRouteScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('RUTA SEGURA // ALBERGUE'), findsOneWidget);
      expect(find.text('+42m Elevación Segura • Camino verificado por Protección Civil hace 4 min'), findsOneWidget);
      expect(find.text('Gimnasio Benito Juárez'), findsOneWidget);
      expect(find.text('650 m'), findsOneWidget);
      expect(find.text('SECA'), findsOneWidget);
      expect(find.text('Médico 24/7'), findsOneWidget);
      expect(find.text('Agua Potable & Raciones'), findsOneWidget);
      expect(find.text('PASO 1 DE 3 • EN 80 METROS'), findsOneWidget);
    });

    testWidgets('OfficialBroadcastsScreen renders CONAGUA / CNPC bulletins and radio player', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OfficialBroadcastsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('COMUNICADOS OFICIALES'), findsOneWidget);
      expect(find.text('RADIO PROTECCIÓN CIVIL'), findsOneWidget);
      expect(find.text('FM 98.5 / 147.500 VHF'), findsOneWidget);
      expect(find.text('NIVEL ROJO'), findsOneWidget);
      expect(find.text('SEDENA / CONAGUA'), findsOneWidget);
    });

    testWidgets('FamilyHubScreen renders Red Civil Activa and member cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FamilyHubScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('RESGUARDO // RED CIVIL'), findsOneWidget);
      expect(find.text('RED MALLA C5'), findsOneWidget);
      expect(find.text('REPORTE INMEDIATO DE BIENESTAR'), findsOneWidget);
      expect(find.text('MI QR INGRESO'), findsOneWidget);

      // Scroll to view family roster
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Ana Sofía Garza Vega'), findsWidgets);
    });
  });
}
