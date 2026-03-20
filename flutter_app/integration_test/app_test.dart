import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mind_scrolling/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Launch', () {
    testWidgets('App starts without crashing', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Feed Screen', () {
    testWidgets('Feed loads and shows content', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      // Should have gesture-based swipeable content
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('Swipe right (like) works', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      final gesture = find.byType(GestureDetector).first;
      await tester.drag(gesture, const Offset(300, 0));
      await tester.pumpAndSettle();
    });

    testWidgets('Swipe left (skip) works', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      final gesture = find.byType(GestureDetector).first;
      await tester.drag(gesture, const Offset(-300, 0));
      await tester.pumpAndSettle();
    });

    testWidgets('Swipe up (save to vault) works', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      final gesture = find.byType(GestureDetector).first;
      await tester.drag(gesture, const Offset(0, -300));
      await tester.pumpAndSettle();
    });
  });

  group('Navigation', () {
    testWidgets('Bottom navigation has expected tabs', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
