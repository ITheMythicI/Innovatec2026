import 'package:flutter_test/flutter_test.dart';
import 'package:innovatec_mobile/main.dart';
import 'package:innovatec_mobile/sync/sync_manager.dart';

void main() {
  testWidgets('Innovatec 2026 App Smoke Test', (WidgetTester tester) async {
    SyncManager.instance.stopPeriodicSync();

    await tester.pumpWidget(const InnovatecApp());
    await tester.pumpAndSettle();

    // Verify that primary navigation labels exist according to design contract.
    expect(find.text('SOS / Alertas'), findsWidgets);
    expect(find.text('Albergues'), findsWidgets);
    expect(find.text('Reportes'), findsWidgets);
    expect(find.text('Personas'), findsWidgets);
    expect(find.text('Mi Familia'), findsWidgets);
    expect(find.text('Ficha Médica'), findsWidgets);
    expect(find.text('Auditoría'), findsWidgets);
  });
}
