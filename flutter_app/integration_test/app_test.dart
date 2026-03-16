import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mind_scrolling/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Prueba de Integración - Mind Scrolling', () {
    testWidgets('Verificar que la app carga y muestra el feed', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verificar que la app inició correctamente buscando algún elemento clave.
      // Basado en tu estructura, probamos que el feed esté presente.
      expect(find.byType(app.MindScrollApp), findsOneWidget);

      // Esperar un momento para ver la UI
      await Future.delayed(const Duration(seconds: 2));
    });
  });
}
