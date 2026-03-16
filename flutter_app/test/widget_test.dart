import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_scrolling/app/app.dart';

void main() {
  testWidgets('Verificar que la app carga correctamente', (WidgetTester tester) async {
    // Build our app and trigger a frame inside a ProviderScope for Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: MindScrollApp(),
      ),
    );

    // Verificamos que el widget principal de la app esté presente
    expect(find.byType(MindScrollApp), findsOneWidget);
  });
}
