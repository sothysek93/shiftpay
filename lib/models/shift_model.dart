import 'dart:convert';
import 'package:flutter/material.dart';

class NightDiffConfig {
  final bool enabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final double bonusRate;

  const NightDiffConfig({
    this.enabled = false,
    this.startHour = 22, // 10:00 PM
    this.startMinute = 0,
    this.endHour = 6,    // 06:00 AM
    this.endMinute = 0,
    this.bonusRate = 2.50,
  });

  TimeOfDay get startTime => TimeOfDay(hour: startHour, minute: startMinute);
  TimeOfDay get endTime => TimeOfDay(hour: endHour, minute: endMinute);

  NightDiffConfig copyWith({
    bool? enabled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    double? bonusRate,
  }) {
    return NightDiffConfig(
      enabled: enabled ?? this.enabled,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      bonusRate: bonusRate ?? this.bonusRate,
    );
  }

  Map<String, dynamic> toMap() => {
    'enabled': enabled,
    'startHour': startHour,
    'startMinute': startMinute,
    'endHour': endHour,
    'endMinute': endMinute,
    'bonusRate': bonusRate,
  };

  factory NightDiffConfig.fromMap(Map<String, dynamic> map) {
    return NightDiffConfig(
      enabled: map['enabled'] as bool? ?? false,
      startHour: map['startHour'] as int? ?? 22,
      startMinute: map['startMinute'] as int? ?? 0,
      endHour: map['endHour'] as int? ?? 6,
      endMinute: map['endMinute'] as int? ?? 0,
      bonusRate: (map['bonusRate'] as num?)?.toDouble() ?? 2.50,
    );
  }
}

class ShiftCalculationResult {
  final int totalElapsedMinutes;
  final double totalElapsedHours;
  final int breakMinutes;
  final int netPaidMinutes;
  final double netPaidHours;
  final double regularHours;
  final double otHours;
  final double nightDiffHours;
  final double regularPay;
  final double otPay;
  final double nightDiffPay;
  final double flatAdditions;
  final double flatDeductions;
  final double grossPay;
  final double effectiveHourlyRate;
  final bool isOvernight;

  const ShiftCalculationResult({
    required this.totalElapsedMinutes,
    required this.totalElapsedHours,
    required this.breakMinutes,
    required this.netPaidMinutes,
    required this.netPaidHours,
    required this.regularHours,
    required this.otHours,
    required this.nightDiffHours,
    required this.regularPay,
    required this.otPay,
    required this.nightDiffPay,
    required this.flatAdditions,
    required this.flatDeductions,
    required this.grossPay,
    required this.effectiveHourlyRate,
    required this.isOvernight,
  });

  Map<String, dynamic> toMap() => {
    'totalElapsedMinutes': totalElapsedMinutes,
    'totalElapsedHours': totalElapsedHours,
    'breakMinutes': breakMinutes,
    'netPaidMinutes': netPaidMinutes,
    'netPaidHours': netPaidHours,
    'regularHours': regularHours,
    'otHours': otHours,
    'nightDiffHours': nightDiffHours,
    'regularPay': regularPay,
    'otPay': otPay,
    'nightDiffPay': nightDiffPay,
    'flatAdditions': flatAdditions,
    'flatDeductions': flatDeductions,
    'grossPay': grossPay,
    'effectiveHourlyRate': effectiveHourlyRate,
    'isOvernight': isOvernight,
  };

  factory ShiftCalculationResult.fromMap(Map<String, dynamic> map) {
    return ShiftCalculationResult(
      totalElapsedMinutes: map['totalElapsedMinutes'] as int? ?? 0,
      totalElapsedHours: (map['totalElapsedHours'] as num?)?.toDouble() ?? 0.0,
      breakMinutes: map['breakMinutes'] as int? ?? 0,
      netPaidMinutes: map['netPaidMinutes'] as int? ?? 0,
      netPaidHours: (map['netPaidHours'] as num?)?.toDouble() ?? 0.0,
      regularHours: (map['regularHours'] as num?)?.toDouble() ?? 0.0,
      otHours: (map['otHours'] as num?)?.toDouble() ?? 0.0,
      nightDiffHours: (map['nightDiffHours'] as num?)?.toDouble() ?? 0.0,
      regularPay: (map['regularPay'] as num?)?.toDouble() ?? 0.0,
      otPay: (map['otPay'] as num?)?.toDouble() ?? 0.0,
      nightDiffPay: (map['nightDiffPay'] as num?)?.toDouble() ?? 0.0,
      flatAdditions: (map['flatAdditions'] as num?)?.toDouble() ?? 0.0,
      flatDeductions: (map['flatDeductions'] as num?)?.toDouble() ?? 0.0,
      grossPay: (map['grossPay'] as num?)?.toDouble() ?? 0.0,
      effectiveHourlyRate: (map['effectiveHourlyRate'] as num?)?.toDouble() ?? 0.0,
      isOvernight: map['isOvernight'] as bool? ?? false,
    );
  }
}

class ShiftHistoryItem {
  final String id;
  final DateTime createdAt;
  final DateTime shiftDate;
  final int clockInHour;
  final int clockInMinute;
  final int clockOutHour;
  final int clockOutMinute;
  final int breakMinutes;
  final double baseWage;
  final String currency;
  final double otMultiplier;
  final double dailyThreshold;
  final NightDiffConfig nightDiff;
  final double flatAdditions;
  final double flatDeductions;
  final ShiftCalculationResult result;
  final String note;

  const ShiftHistoryItem({
    required this.id,
    required this.createdAt,
    required this.shiftDate,
    required this.clockInHour,
    required this.clockInMinute,
    required this.clockOutHour,
    required this.clockOutMinute,
    required this.breakMinutes,
    required this.baseWage,
    required this.currency,
    required this.otMultiplier,
    required this.dailyThreshold,
    required this.nightDiff,
    required this.flatAdditions,
    required this.flatDeductions,
    required this.result,
    this.note = '',
  });

  String get clockInFormatted {
    final h = clockInHour % 12 == 0 ? 12 : clockInHour % 12;
    final m = clockInMinute.toString().padLeft(2, '0');
    final period = clockInHour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  String get clockOutFormatted {
    final h = clockOutHour % 12 == 0 ? 12 : clockOutHour % 12;
    final m = clockOutMinute.toString().padLeft(2, '0');
    final period = clockOutHour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'shiftDate': shiftDate.toIso8601String(),
    'clockInHour': clockInHour,
    'clockInMinute': clockInMinute,
    'clockOutHour': clockOutHour,
    'clockOutMinute': clockOutMinute,
    'breakMinutes': breakMinutes,
    'baseWage': baseWage,
    'currency': currency,
    'otMultiplier': otMultiplier,
    'dailyThreshold': dailyThreshold,
    'nightDiff': nightDiff.toMap(),
    'flatAdditions': flatAdditions,
    'flatDeductions': flatDeductions,
    'result': result.toMap(),
    'note': note,
  };

  factory ShiftHistoryItem.fromMap(Map<String, dynamic> map) {
    return ShiftHistoryItem(
      id: map['id'] as String,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      shiftDate: DateTime.tryParse(map['shiftDate'] as String? ?? '') ?? DateTime.now(),
      clockInHour: map['clockInHour'] as int? ?? 9,
      clockInMinute: map['clockInMinute'] as int? ?? 0,
      clockOutHour: map['clockOutHour'] as int? ?? 17,
      clockOutMinute: map['clockOutMinute'] as int? ?? 0,
      breakMinutes: map['breakMinutes'] as int? ?? 30,
      baseWage: (map['baseWage'] as num?)?.toDouble() ?? 20.0,
      currency: map['currency'] as String? ?? '\$',
      otMultiplier: (map['otMultiplier'] as num?)?.toDouble() ?? 1.5,
      dailyThreshold: (map['dailyThreshold'] as num?)?.toDouble() ?? 8.0,
      nightDiff: map['nightDiff'] != null
          ? NightDiffConfig.fromMap(map['nightDiff'] as Map<String, dynamic>)
          : const NightDiffConfig(),
      flatAdditions: (map['flatAdditions'] as num?)?.toDouble() ?? 0.0,
      flatDeductions: (map['flatDeductions'] as num?)?.toDouble() ?? 0.0,
      result: ShiftCalculationResult.fromMap(map['result'] as Map<String, dynamic>),
      note: map['note'] as String? ?? '',
    );
  }

  String toJson() => jsonEncode(toMap());
  factory ShiftHistoryItem.fromJson(String source) =>
      ShiftHistoryItem.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
