import 'package:flutter_test/flutter_test.dart';
import 'package:shiftpay/core/utils/shift_calculator.dart';
import 'package:shiftpay/models/shift_model.dart';

void main() {
  group('ShiftCalculator Tests', () {
    test('Standard Day Shift: 9:00 AM to 5:00 PM (8h) with 30m break @ \$20/hr', () {
      final result = ShiftCalculator.calculate(
        clockInHour: 9,
        clockInMinute: 0,
        clockOutHour: 17,
        clockOutMinute: 0,
        breakMinutes: 30,
        baseWage: 20.0,
        otMultiplier: 1.5,
        dailyThreshold: 8.0,
        nightDiff: const NightDiffConfig(enabled: false),
        flatAdditions: 0.0,
        flatDeductions: 0.0,
      );

      expect(result.totalElapsedHours, 8.0);
      expect(result.netPaidHours, 7.5);
      expect(result.regularHours, 7.5);
      expect(result.otHours, 0.0);
      expect(result.regularPay, 150.0); // 7.5 * 20
      expect(result.grossPay, 150.0);
      expect(result.isOvernight, false);
    });

    test('Overtime Shift: 8:00 AM to 8:00 PM (12h) with 60m break @ \$25/hr with 1.5x OT', () {
      final result = ShiftCalculator.calculate(
        clockInHour: 8,
        clockInMinute: 0,
        clockOutHour: 20,
        clockOutMinute: 0,
        breakMinutes: 60,
        baseWage: 25.0,
        otMultiplier: 1.5,
        dailyThreshold: 8.0,
        nightDiff: const NightDiffConfig(enabled: false),
        flatAdditions: 0.0,
        flatDeductions: 0.0,
      );

      // Total Elapsed = 12h, Net Paid = 11h
      // Regular = 8h, OT = 3h
      expect(result.totalElapsedHours, 12.0);
      expect(result.netPaidHours, 11.0);
      expect(result.regularHours, 8.0);
      expect(result.otHours, 3.0);
      expect(result.regularPay, 200.0); // 8 * 25
      expect(result.otPay, 112.50);     // 3 * 25 * 1.5 = 112.5
      expect(result.grossPay, 312.50);
      expect(result.effectiveHourlyRate, closeTo(312.50 / 11.0, 0.01));
    });

    test('Overnight Shift Crossing Midnight: 10:00 PM (22:00) to 6:00 AM (06:00) with 0m break', () {
      final result = ShiftCalculator.calculate(
        clockInHour: 22,
        clockInMinute: 0,
        clockOutHour: 6,
        clockOutMinute: 0,
        breakMinutes: 0,
        baseWage: 30.0,
        otMultiplier: 1.5,
        dailyThreshold: 8.0,
        nightDiff: const NightDiffConfig(
          enabled: true,
          startHour: 22,
          startMinute: 0,
          endHour: 6,
          endMinute: 0,
          bonusRate: 3.00,
        ),
        flatAdditions: 0.0,
        flatDeductions: 0.0,
      );

      expect(result.isOvernight, true);
      expect(result.totalElapsedHours, 8.0);
      expect(result.netPaidHours, 8.0);
      expect(result.regularHours, 8.0);
      expect(result.otHours, 0.0);
      expect(result.nightDiffHours, 8.0);
      expect(result.nightDiffPay, 24.0); // 8 * 3.00
      expect(result.grossPay, 264.0);    // (8 * 30) + 24 = 264.0
    });

    test('Partial Night Differential: 4:00 PM (16:00) to 12:00 AM (00:00) with 10 PM - 6 AM night window', () {
      // Shift is 16:00 to 00:00 (8h). Night window is 22:00 to 06:00.
      // Intersecting night hours: 22:00 to 00:00 = 2 hours.
      final result = ShiftCalculator.calculate(
        clockInHour: 16,
        clockInMinute: 0,
        clockOutHour: 0,
        clockOutMinute: 0,
        breakMinutes: 0,
        baseWage: 20.0,
        otMultiplier: 1.5,
        dailyThreshold: 8.0,
        nightDiff: const NightDiffConfig(
          enabled: true,
          startHour: 22,
          startMinute: 0,
          endHour: 6,
          endMinute: 0,
          bonusRate: 2.50,
        ),
        flatAdditions: 15.0, // tips
        flatDeductions: 5.0, // meal deduction
      );

      expect(result.totalElapsedHours, 8.0);
      expect(result.netPaidHours, 8.0);
      expect(result.regularHours, 8.0);
      expect(result.nightDiffHours, 2.0);
      expect(result.nightDiffPay, 5.0); // 2 * 2.50
      // Gross = (8 * 20) + 5 (night) + 15 (tip) - 5 (meal) = 175.0
      expect(result.grossPay, 175.0);
    });

    test('Weekly Export Report generation with multiple shifts', () {
      final shift1 = ShiftHistoryItem(
        id: '1',
        createdAt: DateTime(2026, 8, 20),
        shiftDate: DateTime(2026, 8, 20),
        clockInHour: 9,
        clockInMinute: 0,
        clockOutHour: 17,
        clockOutMinute: 0,
        breakMinutes: 30,
        baseWage: 20.0,
        currency: '\$',
        otMultiplier: 1.5,
        dailyThreshold: 8.0,
        nightDiff: const NightDiffConfig(enabled: false),
        flatAdditions: 0.0,
        flatDeductions: 0.0,
        result: ShiftCalculator.calculate(
          clockInHour: 9,
          clockInMinute: 0,
          clockOutHour: 17,
          clockOutMinute: 0,
          breakMinutes: 30,
          baseWage: 20.0,
          otMultiplier: 1.5,
          dailyThreshold: 8.0,
          nightDiff: const NightDiffConfig(enabled: false),
          flatAdditions: 0.0,
          flatDeductions: 0.0,
        ),
      );

      final report = ShiftCalculator.formatWeeklyExportReport(
        shifts: [shift1],
        currency: '\$',
      );

      expect(report.contains('SHIFTPAY WEEKLY EARNINGS REPORT'), true);
      expect(report.contains('Gross Earnings:      \$150.00'), true);
    });
  });
}
