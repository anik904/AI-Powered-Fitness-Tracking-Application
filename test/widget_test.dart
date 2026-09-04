import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_fitness_tracker/core/providers/shared_preferences_provider.dart';
import 'package:ai_fitness_tracker/presentation/analytics/analytics_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AnalyticsScreen renders correctly with real providers', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: AnalyticsScreen(),
        ),
      ),
    );

    // Initial render
    await tester.pumpAndSettle();

    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Workout Activity'), findsOneWidget);
    expect(find.text('Exercise Distribution'), findsOneWidget);
    expect(find.text('30-Day Challenge'), findsOneWidget);
    expect(find.text('Recent Activity'), findsOneWidget);
  });
}
