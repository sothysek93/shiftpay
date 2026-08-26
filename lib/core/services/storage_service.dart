import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../models/shift_model.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Base Wage
  double getBaseWage() => _prefs.getDouble(AppConstants.keyBaseWage) ?? AppConstants.defaultBaseWage;
  Future<bool> setBaseWage(double wage) => _prefs.setDouble(AppConstants.keyBaseWage, wage);

  // Currency
  String getCurrency() => _prefs.getString(AppConstants.keyCurrency) ?? AppConstants.defaultCurrency;
  Future<bool> setCurrency(String currency) => _prefs.setString(AppConstants.keyCurrency, currency);

  // OT Multiplier
  double getOtMultiplier() => _prefs.getDouble(AppConstants.keyOtMultiplier) ?? AppConstants.defaultOtMultiplier;
  Future<bool> setOtMultiplier(double multiplier) => _prefs.setDouble(AppConstants.keyOtMultiplier, multiplier);

  // Daily Threshold
  double getDailyThreshold() => _prefs.getDouble(AppConstants.keyDailyThreshold) ?? AppConstants.defaultDailyThreshold;
  Future<bool> setDailyThreshold(double threshold) => _prefs.setDouble(AppConstants.keyDailyThreshold, threshold);

  // Night Differential Config
  NightDiffConfig getNightDiffConfig() {
    final enabled = _prefs.getBool(AppConstants.keyNightDiffEnabled) ?? false;
    final startHour = _prefs.getInt(AppConstants.keyNightStartHour) ?? AppConstants.defaultNightStartHour;
    final startMinute = _prefs.getInt(AppConstants.keyNightStartMinute) ?? AppConstants.defaultNightStartMinute;
    final endHour = _prefs.getInt(AppConstants.keyNightEndHour) ?? AppConstants.defaultNightEndHour;
    final endMinute = _prefs.getInt(AppConstants.keyNightEndMinute) ?? AppConstants.defaultNightEndMinute;
    final bonus = _prefs.getDouble(AppConstants.keyNightBonusRate) ?? AppConstants.defaultNightBonusRate;

    return NightDiffConfig(
      enabled: enabled,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
      bonusRate: bonus,
    );
  }

  Future<void> saveNightDiffConfig(NightDiffConfig config) async {
    await _prefs.setBool(AppConstants.keyNightDiffEnabled, config.enabled);
    await _prefs.setInt(AppConstants.keyNightStartHour, config.startHour);
    await _prefs.setInt(AppConstants.keyNightStartMinute, config.startMinute);
    await _prefs.setInt(AppConstants.keyNightEndHour, config.endHour);
    await _prefs.setInt(AppConstants.keyNightEndMinute, config.endMinute);
    await _prefs.setDouble(AppConstants.keyNightBonusRate, config.bonusRate);
  }

  // Shift History
  List<ShiftHistoryItem> getShiftHistory() {
    final jsonStr = _prefs.getString(AppConstants.keyShiftHistory);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => ShiftHistoryItem.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveShiftHistory(List<ShiftHistoryItem> shifts) {
    final list = shifts.map((s) => s.toMap()).toList();
    return _prefs.setString(AppConstants.keyShiftHistory, jsonEncode(list));
  }

  // Interstitial Counter
  int getInterstitialCount() => _prefs.getInt(AppConstants.keyInterstitialCount) ?? 0;
  Future<bool> setInterstitialCount(int count) => _prefs.setInt(AppConstants.keyInterstitialCount, count);

  // Rewarded Unlock Expiry (24 hours unlock for Weekly Export)
  DateTime? getRewardedUnlockExpiry() {
    final millis = _prefs.getInt(AppConstants.keyRewardedUnlockExpiry);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<bool> setRewardedUnlockExpiry(DateTime expiry) {
    return _prefs.setInt(AppConstants.keyRewardedUnlockExpiry, expiry.millisecondsSinceEpoch);
  }

  bool isRewardedUnlocked() {
    final expiry = getRewardedUnlockExpiry();
    if (expiry == null) return false;
    return DateTime.now().isBefore(expiry);
  }

  // Theme Mode ('dark', 'light', 'system')
  String getThemeMode() => _prefs.getString('app_theme_mode') ?? 'dark';
  Future<bool> setThemeMode(String mode) => _prefs.setString('app_theme_mode', mode);
}
