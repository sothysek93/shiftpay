import 'dart:math';
import 'package:intl/intl.dart';
import '../../models/shift_model.dart';

class ShiftCalculator {
  /// Calculates all shift metrics given the input parameters
  static ShiftCalculationResult calculate({
    required int clockInHour,
    required int clockInMinute,
    required int clockOutHour,
    required int clockOutMinute,
    required int breakMinutes,
    required double baseWage,
    required double otMultiplier,
    required double dailyThreshold,
    required NightDiffConfig nightDiff,
    required double flatAdditions,
    required double flatDeductions,
  }) {
    final int startTotalMinutes = clockInHour * 60 + clockInMinute;
    final int endTotalMinutes = clockOutHour * 60 + clockOutMinute;

    int totalElapsedMinutes = endTotalMinutes - startTotalMinutes;
    bool isOvernight = false;

    if (totalElapsedMinutes < 0) {
      totalElapsedMinutes += 1440; // 24 * 60
      isOvernight = true;
    } else if (totalElapsedMinutes == 0) {
      // 0 minutes elapsed
      totalElapsedMinutes = 0;
    }

    final double totalElapsedHours = totalElapsedMinutes / 60.0;
    final int netPaidMinutes = max(0, totalElapsedMinutes - breakMinutes);
    final double netPaidHours = netPaidMinutes / 60.0;

    // Regular vs OT Split
    double regularHours = 0.0;
    double otHours = 0.0;

    if (netPaidHours > dailyThreshold) {
      regularHours = dailyThreshold;
      otHours = netPaidHours - dailyThreshold;
    } else {
      regularHours = netPaidHours;
      otHours = 0.0;
    }

    // Night Differential calculation using minute-level interval intersection
    double nightDiffHours = 0.0;
    if (nightDiff.enabled && totalElapsedMinutes > 0) {
      final int nightStartMin = nightDiff.startHour * 60 + nightDiff.startMinute;
      final int nightEndMin = nightDiff.endHour * 60 + nightDiff.endMinute;

      int intersectingMinutes = 0;
      for (int i = 0; i < totalElapsedMinutes; i++) {
        final int currentMin = (startTotalMinutes + i) % 1440;
        if (_isMinuteInNightWindow(currentMin, nightStartMin, nightEndMin)) {
          intersectingMinutes++;
        }
      }

      // Deduct proportional break from night differential if break exists
      if (totalElapsedMinutes > 0 && breakMinutes > 0 && intersectingMinutes > 0) {
        final double nightRatio = intersectingMinutes / totalElapsedMinutes;
        final double breakInNight = breakMinutes * nightRatio;
        final double netNightMinutes = max(0.0, intersectingMinutes - breakInNight);
        nightDiffHours = netNightMinutes / 60.0;
      } else {
        nightDiffHours = intersectingMinutes / 60.0;
      }
    }

    // Pay calculations
    final double regularPay = regularHours * baseWage;
    final double otPay = otHours * (baseWage * otMultiplier);
    final double nightDiffPay = nightDiff.enabled ? (nightDiffHours * nightDiff.bonusRate) : 0.0;
    final double grossPay = max(
      0.0,
      regularPay + otPay + nightDiffPay + flatAdditions - flatDeductions,
    );

    final double effectiveHourlyRate = netPaidHours > 0 ? (grossPay / netPaidHours) : 0.0;

    return ShiftCalculationResult(
      totalElapsedMinutes: totalElapsedMinutes,
      totalElapsedHours: totalElapsedHours,
      breakMinutes: breakMinutes,
      netPaidMinutes: netPaidMinutes,
      netPaidHours: netPaidHours,
      regularHours: regularHours,
      otHours: otHours,
      nightDiffHours: nightDiffHours,
      regularPay: regularPay,
      otPay: otPay,
      nightDiffPay: nightDiffPay,
      flatAdditions: flatAdditions,
      flatDeductions: flatDeductions,
      grossPay: grossPay,
      effectiveHourlyRate: effectiveHourlyRate,
      isOvernight: isOvernight,
    );
  }

  /// Helper to test if a minute of the day [0..1439] falls inside the night window
  static bool _isMinuteInNightWindow(int minuteOfDay, int nightStart, int nightEnd) {
    if (nightStart < nightEnd) {
      // Window does not cross midnight (e.g. 01:00 to 05:00)
      return minuteOfDay >= nightStart && minuteOfDay < nightEnd;
    } else if (nightStart > nightEnd) {
      // Window crosses midnight (e.g. 22:00 to 06:00)
      return minuteOfDay >= nightStart || minuteOfDay < nightEnd;
    } else {
      // 24-hour night window if start == end
      return true;
    }
  }

  /// Generates a clean text snippet for daily shift clipboard copying
  static String formatClipboardSummary({
    required DateTime date,
    required int clockInHour,
    required int clockInMinute,
    required int clockOutHour,
    required int clockOutMinute,
    required String currency,
    required double baseWage,
    required double otMultiplier,
    required ShiftCalculationResult result,
    String? note,
  }) {
    final dateStr = DateFormat('EEE, MMM d, yyyy').format(date);
    final inStr = _formatTimeOfDay(clockInHour, clockInMinute);
    final outStr = _formatTimeOfDay(clockOutHour, clockOutMinute);

    final buf = StringBuffer();
    buf.writeln('📋 ShiftPay Summary — $dateStr');
    buf.writeln('⏰ Shift: $inStr - $outStr (${result.totalElapsedHours.toStringAsFixed(2)}h total${result.isOvernight ? ', Overnight' : ''})');
    if (result.breakMinutes > 0) {
      buf.writeln('☕ Unpaid Break: ${result.breakMinutes} mins');
    }
    buf.writeln('⏱️ Net Paid Hours: ${result.netPaidHours.toStringAsFixed(2)} hrs');
    buf.writeln('├ Standard Hours: ${result.regularHours.toStringAsFixed(2)} hrs ($currency${result.regularPay.toStringAsFixed(2)})');
    if (result.otHours > 0) {
      buf.writeln('├ Overtime (${otMultiplier.toStringAsFixed(1)}x): ${result.otHours.toStringAsFixed(2)} hrs ($currency${result.otPay.toStringAsFixed(2)})');
    }
    if (result.nightDiffHours > 0) {
      buf.writeln('├ Night Premium: ${result.nightDiffHours.toStringAsFixed(2)} hrs ($currency${result.nightDiffPay.toStringAsFixed(2)})');
    }
    if (result.flatAdditions > 0) {
      buf.writeln('├ Additions (Tips/Bonus): +$currency${result.flatAdditions.toStringAsFixed(2)}');
    }
    if (result.flatDeductions > 0) {
      buf.writeln('├ Deductions (Fees/Meals): -$currency${result.flatDeductions.toStringAsFixed(2)}');
    }
    buf.writeln('💰 Estimated Gross Pay: $currency${result.grossPay.toStringAsFixed(2)}');
    buf.writeln('📈 Effective Rate: $currency${result.effectiveHourlyRate.toStringAsFixed(2)}/hr');
    if (note != null && note.trim().isNotEmpty) {
      buf.writeln('📝 Note: ${note.trim()}');
    }
    buf.write('⚡ Calculated with ShiftPay');
    return buf.toString();
  }

  /// Generates a comprehensive Weekly Summary Report
  static String formatWeeklyExportReport({
    required List<ShiftHistoryItem> shifts,
    required String currency,
  }) {
    if (shifts.isEmpty) {
      return 'No shifts recorded for export.';
    }

    // Sort chronologically
    final sorted = List<ShiftHistoryItem>.from(shifts)
      ..sort((a, b) => a.shiftDate.compareTo(b.shiftDate));

    final startDate = DateFormat('MMM d').format(sorted.first.shiftDate);
    final endDate = DateFormat('MMM d, yyyy').format(sorted.last.shiftDate);

    double totalElapsed = 0.0;
    double totalNet = 0.0;
    double totalRegular = 0.0;
    double totalOT = 0.0;
    double totalNight = 0.0;
    double totalGross = 0.0;
    int totalBreakMinutes = 0;

    for (final s in sorted) {
      totalElapsed += s.result.totalElapsedHours;
      totalNet += s.result.netPaidHours;
      totalRegular += s.result.regularHours;
      totalOT += s.result.otHours;
      totalNight += s.result.nightDiffHours;
      totalGross += s.result.grossPay;
      totalBreakMinutes += s.breakMinutes;
    }

    final double avgEffectiveRate = totalNet > 0 ? (totalGross / totalNet) : 0.0;

    final buf = StringBuffer();
    buf.writeln('========================================');
    buf.writeln('📊 SHIFTPAY WEEKLY EARNINGS REPORT');
    buf.writeln('Period: $startDate — $endDate');
    buf.writeln('Total Shifts: ${sorted.length}');
    buf.writeln('========================================\n');

    buf.writeln('📈 SUMMARY TOTALS:');
    buf.writeln('• Gross Earnings:      $currency${totalGross.toStringAsFixed(2)}');
    buf.writeln('• Total Elapsed:       ${totalElapsed.toStringAsFixed(2)} hrs');
    buf.writeln('• Net Paid Hours:      ${totalNet.toStringAsFixed(2)} hrs');
    buf.writeln('• Regular Hours:       ${totalRegular.toStringAsFixed(2)} hrs');
    buf.writeln('• Overtime Hours:      ${totalOT.toStringAsFixed(2)} hrs');
    if (totalNight > 0) {
      buf.writeln('• Night Diff Hours:    ${totalNight.toStringAsFixed(2)} hrs');
    }
    buf.writeln('• Unpaid Breaks:       $totalBreakMinutes mins');
    buf.writeln('• Avg Effective Rate:  $currency${avgEffectiveRate.toStringAsFixed(2)}/hr\n');

    buf.writeln('----------------------------------------');
    buf.writeln('📋 DAILY SHIFT BREAKDOWN:');
    buf.writeln('----------------------------------------');

    for (int i = 0; i < sorted.length; i++) {
      final s = sorted[i];
      final dateFormatted = DateFormat('EEE, MMM d').format(s.shiftDate);
      buf.writeln('\n[#${i + 1}] $dateFormatted (${s.clockInFormatted} - ${s.clockOutFormatted})');
      buf.writeln('   Paid: ${s.result.netPaidHours.toStringAsFixed(2)}h | Reg: ${s.result.regularHours.toStringAsFixed(2)}h | OT: ${s.result.otHours.toStringAsFixed(2)}h');
      if (s.result.nightDiffHours > 0) {
        buf.writeln('   Night Premium: ${s.result.nightDiffHours.toStringAsFixed(2)}h (+$currency${s.result.nightDiffPay.toStringAsFixed(2)})');
      }
      if (s.flatAdditions > 0 || s.flatDeductions > 0) {
        buf.writeln('   Adjustments: +$currency${s.flatAdditions.toStringAsFixed(2)} / -$currency${s.flatDeductions.toStringAsFixed(2)}');
      }
      buf.writeln('   Gross Pay: $currency${s.result.grossPay.toStringAsFixed(2)}');
    }

    buf.writeln('\n========================================');
    buf.writeln('Generated by ShiftPay • ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
    buf.writeln('========================================');

    return buf.toString();
  }

  static String _formatTimeOfDay(int hour, int minute) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}
