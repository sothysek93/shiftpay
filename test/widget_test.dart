import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiftpay/core/services/storage_service.dart';
import 'package:shiftpay/main.dart';
import 'package:shiftpay/models/shift_model.dart';
import 'package:shiftpay/presentation/screens/shift_calculator_screen.dart';
import 'package:shiftpay/providers/shift_providers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Widget & Integration Tests', () {
    testWidgets('ShiftPayApp renders dashboard with brand and calculations', (WidgetTester tester) async {
      final storageService = await StorageService.init();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storageService),
          ],
          child: const ShiftPayApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ShiftCalculatorScreen), findsOneWidget);
      expect(find.text('ShiftPay'), findsOneWidget);
      expect(find.text('TOTAL ESTIMATED GROSS'), findsOneWidget);
      expect(find.text('Shift Time & Hours'), findsOneWidget);
      expect(find.text('Base Wage & OT Rules'), findsOneWidget);
    });

    testWidgets('Tapping Theme Toggle switches between Dark and Light mode', (WidgetTester tester) async {
      final storageService = await StorageService.init();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ShiftPayApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Initially Dark mode
      expect(container.read(themeModeProvider), ThemeMode.dark);

      // Find the Theme Toggle icon button (light_mode or dark_mode icon)
      final toggleFinder = find.byIcon(Icons.light_mode_rounded);
      expect(toggleFinder, findsOneWidget);

      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      // Switched to Light mode
      expect(container.read(themeModeProvider), ThemeMode.light);
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

      // Switch back
      await tester.tap(find.byIcon(Icons.dark_mode_rounded));
      await tester.pumpAndSettle();
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    testWidgets('Tapping Preset updates active input and recalculates gross wage', (WidgetTester tester) async {
      final storageService = await StorageService.init();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ShiftPayApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap '12h Day (7–7)' preset
      final presetFinder = find.text('12h Day (7–7)');
      expect(presetFinder, findsOneWidget);

      await tester.tap(presetFinder);
      await tester.pumpAndSettle();

      final input = container.read(activeShiftInputProvider);
      expect(input.clockInHour, 7);
      expect(input.clockOutHour, 19);
      expect(input.breakMinutes, 60);

      final result = container.read(currentCalculationResultProvider);
      expect(result.totalElapsedHours, 12.0);
      expect(result.netPaidHours, 11.0);
      expect(result.otHours, 3.0); // 11.0 - 8.0 = 3.0h OT
    });

    testWidgets('Save Shift records item into Shift History and displays badge', (WidgetTester tester) async {
      final storageService = await StorageService.init();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ShiftPayApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(container.read(shiftHistoryProvider).length, 0);

      final saveButton = find.text('Save Shift');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(container.read(shiftHistoryProvider).length, 1);
      expect(find.text('Shift logged to history'), findsOneWidget);
    });

    testWidgets('Tapping Calculation Rules button displays modal bottom sheet', (WidgetTester tester) async {
      final storageService = await StorageService.init();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storageService),
          ],
          child: const ShiftPayApp(),
        ),
      );

      await tester.pumpAndSettle();

      final rulesButton = find.text('Rules');
      expect(rulesButton, findsOneWidget);

      await tester.tap(rulesButton);
      await tester.pumpAndSettle();

      expect(find.text('Calculation Rules'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);

      // Dismiss modal
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(find.text('Calculation Rules'), findsNothing);
    });
  });

  group('Provider State Notifiers Unit Tests', () {
    test('ShiftPreferencesNotifier updates preferences properly', () async {
      final storageService = await StorageService.init();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
        ],
      );

      final notifier = container.read(shiftPreferencesProvider.notifier);

      notifier.setBaseWage(35.0);
      expect(container.read(shiftPreferencesProvider).baseWage, 35.0);

      notifier.setCurrency('€');
      expect(container.read(shiftPreferencesProvider).currency, '€');

      notifier.setOtMultiplier(2.0);
      expect(container.read(shiftPreferencesProvider).otMultiplier, 2.0);

      notifier.setDailyThreshold(10.0);
      expect(container.read(shiftPreferencesProvider).dailyThreshold, 10.0);

      notifier.setNightDiff(const NightDiffConfig(enabled: true, bonusRate: 5.0));
      expect(container.read(shiftPreferencesProvider).nightDiff.enabled, true);
      expect(container.read(shiftPreferencesProvider).nightDiff.bonusRate, 5.0);
    });

    test('ActiveShiftInputNotifier state mutations and reset', () async {
      final storageService = await StorageService.init();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
        ],
      );

      final notifier = container.read(activeShiftInputProvider.notifier);

      notifier.setClockIn(10, 30);
      notifier.setClockOut(18, 45);
      notifier.setBreakMinutes(45);
      notifier.setFlatAdditions(25.0);
      notifier.setFlatDeductions(8.50);
      notifier.setNote('Overtime Saturday');

      var input = container.read(activeShiftInputProvider);
      expect(input.clockInHour, 10);
      expect(input.clockInMinute, 30);
      expect(input.clockOutHour, 18);
      expect(input.clockOutMinute, 45);
      expect(input.breakMinutes, 45);
      expect(input.flatAdditions, 25.0);
      expect(input.flatDeductions, 8.50);
      expect(input.note, 'Overtime Saturday');

      notifier.resetInputs();
      input = container.read(activeShiftInputProvider);
      expect(input.clockInHour, 9);
      expect(input.clockOutHour, 17);
      expect(input.breakMinutes, 30);
      expect(input.flatAdditions, 0.0);
      expect(input.flatDeductions, 0.0);
      expect(input.note, '');
    });
  });
}
