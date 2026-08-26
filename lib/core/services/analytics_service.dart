import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;
  bool _initialized = false;

  /// Initializes Firebase Analytics safely
  Future<void> init() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      await _analytics?.setAnalyticsCollectionEnabled(true);
      _initialized = true;
      debugPrint('[AnalyticsService] Firebase Analytics initialized successfully');
    } catch (e) {
      debugPrint('[AnalyticsService] Error initializing Firebase Analytics: $e');
    }
  }

  FirebaseAnalyticsObserver get analyticsObserver =>
      FirebaseAnalyticsObserver(analytics: _analytics ?? FirebaseAnalytics.instance);

  // ---------------------------------------------------------------------------
  // SCREEN VIEW TRACKING
  // ---------------------------------------------------------------------------

  Future<void> logScreenView(String screenName) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logScreenView(screenName: screenName);
      debugPrint('[Analytics] Screen View: $screenName');
    } catch (e) {
      debugPrint('[Analytics] Error logging screen view: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // SHIFT CALCULATION & PRESET EVENTS
  // ---------------------------------------------------------------------------

  Future<void> logShiftCalculated({
    required double grossPay,
    required double netHours,
    required double otHours,
    required bool isOvernight,
    required String currency,
  }) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: 'shift_calculated',
        parameters: {
          'gross_pay': grossPay,
          'net_hours': netHours,
          'ot_hours': otHours,
          'is_overnight': isOvernight ? 1 : 0,
          'currency': currency,
        },
      );
    } catch (e) {
      debugPrint('[Analytics] Error: $e');
    }
  }

  Future<void> logPresetApplied(String presetName) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: 'preset_applied',
        parameters: {'preset_name': presetName},
      );
    } catch (e) {
      debugPrint('[Analytics] Error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // SHIFT SAVING & EXPORT EVENTS
  // ---------------------------------------------------------------------------

  Future<void> logShiftSaved({
    required double grossPay,
    required double netHours,
    required double otHours,
    required bool hasNote,
    required String currency,
  }) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: 'shift_saved',
        parameters: {
          'gross_pay': grossPay,
          'net_hours': netHours,
          'ot_hours': otHours,
          'has_note': hasNote ? 1 : 0,
          'currency': currency,
        },
      );
    } catch (e) {
      debugPrint('[Analytics] Error: $e');
    }
  }

  Future<void> logShiftSummaryCopied({
    required double grossPay,
    required double netHours,
  }) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: 'shift_summary_copied',
        parameters: {
          'gross_pay': grossPay,
          'net_hours': netHours,
        },
      );
    } catch (e) {
      debugPrint('[Analytics] Error: $e');
    }
  }

  Future<void> logWeeklyReportCopied({
    required int shiftCount,
    required double totalGross,
  }) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: 'weekly_report_copied',
        parameters: {
          'shift_count': shiftCount,
          'total_gross': totalGross,
        },
      );
    } catch (e) {
      debugPrint('[Analytics] Error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // SETTINGS & MONETIZATION EVENTS
  // ---------------------------------------------------------------------------

  Future<void> logThemeChanged(String themeMode) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: 'theme_changed',
        parameters: {'mode': themeMode},
      );
    } catch (e) {
      debugPrint('[Analytics] Error: $e');
    }
  }

  Future<void> logCurrencyChanged(String currency) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: 'currency_changed',
        parameters: {'currency': currency},
      );
    } catch (e) {
      debugPrint('[Analytics] Error: $e');
    }
  }

  Future<void> logNightDiffToggled({
    required bool enabled,
    required double bonusRate,
  }) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: 'night_diff_toggled',
        parameters: {
          'enabled': enabled ? 1 : 0,
          'bonus_rate': bonusRate,
        },
      );
    } catch (e) {
      debugPrint('[Analytics] Error: $e');
    }
  }

  Future<void> logRewardedAdUnlocked() async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: 'rewarded_ad_unlocked_24h',
        parameters: {'feature': 'weekly_summary_export'},
      );
    } catch (e) {
      debugPrint('[Analytics] Error: $e');
    }
  }

  Future<void> logCalculationRulesOpened() async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logEvent(name: 'calculation_rules_opened');
    } catch (e) {
      debugPrint('[Analytics] Error: $e');
    }
  }
}
