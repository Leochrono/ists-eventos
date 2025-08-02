import 'package:flutter_test/flutter_test.dart';
import 'package:ists_eventos/main.dart';
import '../lib/services/api_service.dart';

void main() {
  testWidgets('ISTS Eventos app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ISTSEventosApp(apiService: ApiService()));

    // Verify that the app starts correctly
    expect(find.text('ISTS Eventos'), findsOneWidget);
    expect(find.text('¡Hacemos gente de talento!'), findsOneWidget);
  });
}

