import 'package:flutter_test/flutter_test.dart';
import 'package:innovatec_mobile/main.dart';

void main() {
  testWidgets('Innovatec 2026 App Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const InnovatecApp());
    await tester.pumpAndSettle();

    // Verify that primary navigation labels exist.
    expect(find.text('Personas'), findsOneWidget);
    expect(find.text('Mi Familia'), findsOneWidget);
    expect(find.text('Ficha Médica'), findsOneWidget);
    expect(find.text('Auditoría'), findsOneWidget);
  });
}
