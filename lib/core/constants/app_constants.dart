class AppConstants {
  static const String appName = 'ShiftPay';
  static const String appTagline = 'Overtime & Wages Calculator';

  // Persistence Keys
  static const String keyBaseWage = 'pref_base_wage';
  static const String keyCurrency = 'pref_currency';
  static const String keyOtMultiplier = 'pref_ot_multiplier';
  static const String keyDailyThreshold = 'pref_daily_threshold';
  static const String keyNightDiffEnabled = 'pref_night_diff_enabled';
  static const String keyNightStartHour = 'pref_night_start_hour';
  static const String keyNightStartMinute = 'pref_night_start_minute';
  static const String keyNightEndHour = 'pref_night_end_hour';
  static const String keyNightEndMinute = 'pref_night_end_minute';
  static const String keyNightBonusRate = 'pref_night_bonus_rate';
  static const String keyShiftHistory = 'pref_shift_history_json';
  static const String keyInterstitialCount = 'pref_interstitial_count';
  static const String keyRewardedUnlockExpiry = 'pref_rewarded_unlock_expiry';

  // Defaults
  static const double defaultBaseWage = 22.50;
  static const String defaultCurrency = '\$';
  static const double defaultDailyThreshold = 8.0;
  static const double defaultOtMultiplier = 1.5;
  static const double defaultNightBonusRate = 2.50;
  static const int defaultNightStartHour = 22; // 10:00 PM
  static const int defaultNightStartMinute = 0;
  static const int defaultNightEndHour = 6; // 06:00 AM
  static const int defaultNightEndMinute = 0;

  // Interstitial frequency
  static const int interstitialTriggerFrequency = 3;

  // Rewarded unlock duration
  static const Duration rewardedUnlockDuration = Duration(hours: 24);

  // Available Currency Symbols
  static const List<String> supportedCurrencies = ['\$', '€', '£', '¥', 'C\$', 'A\$', '₹', '₱', 'KHR'];
}
