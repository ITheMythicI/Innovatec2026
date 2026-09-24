import 'package:flutter_test/flutter_test.dart';
import 'package:innovatec_mobile/core/security/roles_and_permissions.dart';
import 'package:innovatec_mobile/features/auth/domain/services/auth_service.dart';
import 'package:innovatec_mobile/main.dart';
import 'package:innovatec_mobile/sync/sync_manager.dart';

void main() {
  testWidgets('Innovatec 2026 App Smoke Test - Navigation & Role-based Access', (WidgetTester tester) async {
    SyncManager.instance.stopPeriodicSync();

    // Default citizen user: Ensure citizen does NOT see Auditoría
    await AuthService().switchUserRole(UserRole.citizen);

    await tester.pumpWidget(const InnovatecApp());
    await tester.pumpAndSettle();

    // Verify common navigation labels for citizen
    expect(find.text('SOS / Pánico'), findsWidgets);
    expect(find.text('Boletines'), findsWidgets);
    expect(find.text('Albergues'), findsWidgets);
    expect(find.text('Mi Familia'), findsWidgets);
    expect(find.text('Reportes'), findsWidgets);
    expect(find.text('Personas'), findsWidgets);
    expect(find.text('Ficha Médica'), findsWidgets);

    // CRITICAL: Regular citizen must NOT see Auditoría
    expect(find.text('Auditoría'), findsNothing);

    // Switch to Authority: Must see Auditoría
    await AuthService().switchUserRole(UserRole.authority);
    await tester.pumpAndSettle();

    expect(find.text('Auditoría'), findsWidgets);
  });
}
