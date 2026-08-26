import 'package:flutter_test/flutter_test.dart';
import 'package:shiftpay/core/utils/shift_calculator.dart';
import 'package:shiftpay/models/shift_model.dart';

void main() {
  group('ShiftCalculator Core & Edge Case Calculations', () {
    test('Break time exceeding elapsed shift time returns 0.0 net hours & 0.0 gross', () {
      final result = ShiftCalculator.calculate(
        clockInHour: 9,
        clockInMinute: 0,
        clockOutHour: 10,
        clockOutMinute: 0, // 1 hour elapsed = 60 mins
        breakMinutes: 90,  // 90 min break exceeds 60 min elapsed
        baseWage: 25.0,
        otMultiplier: 1.5,
        dailyThreshold: 8.0,
        nightDiff: const NightDiffConfig(enabled: false),
        flatAdditions: 0.0,
        flatDeductions: 0.0,
      );

      expect(result.totalElapsedHours, 1.0);
      expect(result.netPaidHours, 0.0);
      expect(result.regularHours, 0.0);
      expect(result.otHours, 0.0);
      expect(result.regularPay, 0.0);
      expect(result.grossPay, 0.0);
      expect(result.effectiveHourlyRate, 0.0);
    });

    test('Same clock-in and clock-out time (09:00 to 09:00) yields 0.0 elapsed hours', () {
      final result = ShiftCalculator.calculate(
        clockInHour: 9,
        clockInMinute: 0,
        clockOutHour: 9,
        clockOutMinute: 0,
        breakMinutes: 0,
        baseWage: 20.0,
        otMultiplier: 2.0,
        dailyThreshold: 8.0,
        nightDiff: const NightDiffConfig(enabled: false),
        flatAdditions: 0.0,
        flatDeductions: 0.0,
      );

      expect(result.totalElapsedHours, 0.0);
      expect(result.netPaidHours, 0.0);
      expect(result.grossPay, 0.0);
    });

    test('Full 23-Hour 50-Minute Shift across Midnight: 09:00 to 08:50 next morning', () {
      final result = ShiftCalculator.calculate(
        clockInHour: 9,
        clockInMinute: 0,
        clockOutHour: 8,
        clockOutMinute: 50,
        breakMinutes: 50,
        baseWage: 20.0,
        otMultiplier: 2.0,
        dailyThreshold: 8.0,
        nightDiff: const NightDiffConfig(enabled: false),
        flatAdditions: 0.0,
        flatDeductions: 0.0,
      );

      // Elapsed = 23h 50m (1430 mins). Break = 50m -> 1380 mins (23.0 hrs)
      // 8.0h regular @ 20.0 ($160) + 15.0h OT @ (20 * 2.0 = $40/hr -> $600) = $760
      expect(result.isOvernight, true);
      expect(result.netPaidHours, 23.0);
      expect(result.regularHours, 8.0);
      expect(result.otHours, 15.0);
      expect(result.regularPay, 160.0);
      expect(result.otPay, 600.0);
      expect(result.grossPay, 760.0);
    });

    test('Custom Threshold (4.0h) and 2.5x OT Multiplier', () {
      final result = ShiftCalculator.calculate(
        clockInHour: 8,
        clockInMinute: 0,
        clockOutHour: 16,
        clockOutMinute: 0, // 8h elapsed
        breakMinutes: 0,
        baseWage: 20.0,
        otMultiplier: 2.5,
        dailyThreshold: 4.0,
        nightDiff: const NightDiffConfig(enabled: false),
        flatAdditions: 0.0,
        flatDeductions: 0.0,
      );

      // 8h net: 4h reg @ 20 ($80) + 4h OT @ 50 ($200) = $280
      expect(result.regularHours, 4.0);
      expect(result.otHours, 4.0);
      expect(result.regularPay, 80.0);
      expect(result.otPay, 200.0);
      expect(result.grossPay, 280.0);
    });

    test('Complex Night Window intersection across midnight (8 PM to 4 AM with night 11 PM to 7 AM)', () {
      // Shift: 20:00 to 04:00 (8h)
      // Night window: 23:00 to 07:00
      // Night overlap: 23:00 to 04:00 = 5 hours
      final result = ShiftCalculator.calculate(
        clockInHour: 20,
        clockInMinute: 0,
        clockOutHour: 4,
        clockOutMinute: 0,
        breakMinutes: 0,
        baseWage: 25.0,
        otMultiplier: 1.5,
        dailyThreshold: 8.0,
        nightDiff: const NightDiffConfig(
          enabled: true,
          startHour: 23,
          startMinute: 0,
          endHour: 7,
          endMinute: 0,
          bonusRate: 4.0,
        ),
        flatAdditions: 20.0,
        flatDeductions: 10.0,
      );

      expect(result.isOvernight, true);
      expect(result.totalElapsedHours, 8.0);
      expect(result.netPaidHours, 8.0);
      expect(result.nightDiffHours, 5.0);
      expect(result.nightDiffPay, 20.0); // 5 * 4.0
      // Base (8 * 25 = 200) + Night (20) + Additions (20) - Deductions (10) = 230.0
      expect(result.grossPay, 230.0);
    });

    test('Non-overnight night window (e.g. 1:00 AM to 5:00 AM)', () {
      // Shift: 00:00 to 06:00 (6h)
      // Night window: 01:00 to 05:00 (4h overlap)
      final result = ShiftCalculator.calculate(
        clockInHour: 0,
        clockInMinute: 0,
        clockOutHour: 6,
        clockOutMinute: 0,
        breakMinutes: 0,
        baseWage: 20.0,
        otMultiplier: 1.5,
        dailyThreshold: 8.0,
        nightDiff: const NightDiffConfig(
          enabled: true,
          startHour: 1,
          startMinute: 0,
          endHour: 5,
          endMinute: 0,
          bonusRate: 2.0,
        ),
        flatAdditions: 0.0,
        flatDeductions: 0.0,
      );

      expect(result.nightDiffHours, 4.0);
      expect(result.nightDiffPay, 8.0);
      expect(result.grossPay, 128.0);
    });
  });

  group('Shift Model & Serialization Tests', () {
    test('ShiftHistoryItem toMap and fromMap serialization round-trip', () {
      final calcResult = ShiftCalculator.calculate(
        clockInHour: 9,
        clockInMinute: 0,
        clockOutHour: 17,
        clockOutMinute: 0,
        breakMinutes: 30,
        baseWage: 22.50,
        otMultiplier: 1.5,
        dailyThreshold: 8.0,
        nightDiff: const NightDiffConfig(enabled: true, bonusRate: 2.0),
        flatAdditions: 10.0,
        flatDeductions: 5.0,
      );

      final item = ShiftHistoryItem(
        id: 'shift-123',
        createdAt: DateTime(2026, 8, 26, 12, 0),
        shiftDate: DateTime(2026, 8, 26),
        clockInHour: 9,
        clockInMinute: 0,
        clockOutHour: 17,
        clockOutMinute: 0,
        breakMinutes: 30,
        baseWage: 22.50,
        currency: '£',
        otMultiplier: 1.5,
        dailyThreshold: 8.0,
        nightDiff: const NightDiffConfig(enabled: true, bonusRate: 2.0),
        flatAdditions: 10.0,
        flatDeductions: 5.0,
        result: calcResult,
        note: 'Hospital Ward Cover',
      );

      final map = item.toMap();
      final restored = ShiftHistoryItem.fromMap(map);

      expect(restored.id, item.id);
      expect(restored.currency, '£');
      expect(restored.baseWage, 22.50);
      expect(restored.note, 'Hospital Ward Cover');
      expect(restored.result.grossPay, calcResult.grossPay);
      expect(restored.clockInFormatted, '9:00 AM');
      expect(restored.clockOutFormatted, '5:00 PM');
    });

    test('NightDiffConfig copyWith and defaults', () {
      const config = NightDiffConfig(enabled: false);
      expect(config.startHour, 22);
      expect(config.endHour, 6);
      expect(config.bonusRate, 2.50);

      final updated = config.copyWith(enabled: true, bonusRate: 5.0);
      expect(updated.enabled, true);
      expect(updated.bonusRate, 5.0);
      expect(updated.startHour, 22);
    });
  });

  group('Clipboard & Export Formatting Tests', () {
    test('formatClipboardSummary contains all essential wage breakdown items', () {
      final result = ShiftCalculator.calculate(
        clockInHour: 9,
        clockInMinute: 0,
        clockOutHour: 18,
        clockOutMinute: 0,
        breakMinutes: 30,
        baseWage: 20.0,
        otMultiplier: 1.5,
        dailyThreshold: 8.0,
        nightDiff: const NightDiffConfig(enabled: false),
        flatAdditions: 5.0,
        flatDeductions: 2.0,
      );

      final summary = ShiftCalculator.formatClipboardSummary(
        date: DateTime(2026, 8, 26),
        clockInHour: 9,
        clockInMinute: 0,
        clockOutHour: 18,
        clockOutMinute: 0,
        currency: '\$',
        baseWage: 20.0,
        otMultiplier: 1.5,
        result: result,
        note: 'Overtime test shift',
      );

      expect(summary.contains('ShiftPay Summary'), true);
      expect(summary.contains('Standard Hours:'), true);
      expect(summary.contains('Estimated Gross Pay: \$'), true);
      expect(summary.contains('Overtime test shift'), true);
    });
  });
}
