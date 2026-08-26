import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/services/ad_service.dart';
import '../core/services/storage_service.dart';
import '../core/utils/shift_calculator.dart';
import '../models/shift_model.dart';

// Storage Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageServiceProvider must be overridden in ProviderScope');
});

// AdService Provider
final adServiceProvider = Provider<AdService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final adService = AdService(storage);
  adService.loadInterstitialAd();
  adService.loadRewardedAd();
  ref.onDispose(() => adService.dispose());
  return adService;
});

// Preferences State
class ShiftPreferencesState {
  final double baseWage;
  final String currency;
  final double otMultiplier;
  final double dailyThreshold;
  final NightDiffConfig nightDiff;

  const ShiftPreferencesState({
    required this.baseWage,
    required this.currency,
    required this.otMultiplier,
    required this.dailyThreshold,
    required this.nightDiff,
  });

  ShiftPreferencesState copyWith({
    double? baseWage,
    String? currency,
    double? otMultiplier,
    double? dailyThreshold,
    NightDiffConfig? nightDiff,
  }) {
    return ShiftPreferencesState(
      baseWage: baseWage ?? this.baseWage,
      currency: currency ?? this.currency,
      otMultiplier: otMultiplier ?? this.otMultiplier,
      dailyThreshold: dailyThreshold ?? this.dailyThreshold,
      nightDiff: nightDiff ?? this.nightDiff,
    );
  }
}

class ShiftPreferencesNotifier extends StateNotifier<ShiftPreferencesState> {
  final StorageService _storage;

  ShiftPreferencesNotifier(this._storage)
      : super(ShiftPreferencesState(
          baseWage: _storage.getBaseWage(),
          currency: _storage.getCurrency(),
          otMultiplier: _storage.getOtMultiplier(),
          dailyThreshold: _storage.getDailyThreshold(),
          nightDiff: _storage.getNightDiffConfig(),
        ));

  Future<void> setBaseWage(double wage) async {
    state = state.copyWith(baseWage: wage);
    await _storage.setBaseWage(wage);
  }

  Future<void> setCurrency(String currency) async {
    state = state.copyWith(currency: currency);
    await _storage.setCurrency(currency);
  }

  Future<void> setOtMultiplier(double multiplier) async {
    state = state.copyWith(otMultiplier: multiplier);
    await _storage.setOtMultiplier(multiplier);
  }

  Future<void> setDailyThreshold(double threshold) async {
    state = state.copyWith(dailyThreshold: threshold);
    await _storage.setDailyThreshold(threshold);
  }

  Future<void> setNightDiff(NightDiffConfig config) async {
    state = state.copyWith(nightDiff: config);
    await _storage.saveNightDiffConfig(config);
  }
}

final shiftPreferencesProvider =
    StateNotifierProvider<ShiftPreferencesNotifier, ShiftPreferencesState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ShiftPreferencesNotifier(storage);
});

// Draft Shift Input State
class ActiveShiftInputState {
  final DateTime shiftDate;
  final int clockInHour;
  final int clockInMinute;
  final int clockOutHour;
  final int clockOutMinute;
  final int breakMinutes;
  final double flatAdditions;
  final double flatDeductions;
  final String note;

  const ActiveShiftInputState({
    required this.shiftDate,
    required this.clockInHour,
    required this.clockInMinute,
    required this.clockOutHour,
    required this.clockOutMinute,
    required this.breakMinutes,
    required this.flatAdditions,
    required this.flatDeductions,
    this.note = '',
  });

  TimeOfDay get clockInTime => TimeOfDay(hour: clockInHour, minute: clockInMinute);
  TimeOfDay get clockOutTime => TimeOfDay(hour: clockOutHour, minute: clockOutMinute);

  ActiveShiftInputState copyWith({
    DateTime? shiftDate,
    int? clockInHour,
    int? clockInMinute,
    int? clockOutHour,
    int? clockOutMinute,
    int? breakMinutes,
    double? flatAdditions,
    double? flatDeductions,
    String? note,
  }) {
    return ActiveShiftInputState(
      shiftDate: shiftDate ?? this.shiftDate,
      clockInHour: clockInHour ?? this.clockInHour,
      clockInMinute: clockInMinute ?? this.clockInMinute,
      clockOutHour: clockOutHour ?? this.clockOutHour,
      clockOutMinute: clockOutMinute ?? this.clockOutMinute,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      flatAdditions: flatAdditions ?? this.flatAdditions,
      flatDeductions: flatDeductions ?? this.flatDeductions,
      note: note ?? this.note,
    );
  }
}

class ActiveShiftInputNotifier extends StateNotifier<ActiveShiftInputState> {
  final Ref _ref;

  ActiveShiftInputNotifier(this._ref)
      : super(ActiveShiftInputState(
          shiftDate: DateTime.now(),
          clockInHour: 9,
          clockInMinute: 0,
          clockOutHour: 17,
          clockOutMinute: 30,
          breakMinutes: 30,
          flatAdditions: 0.0,
          flatDeductions: 0.0,
          note: '',
        ));

  void setShiftDate(DateTime date) {
    state = state.copyWith(shiftDate: date);
  }

  void setClockIn(int hour, int minute) {
    state = state.copyWith(clockInHour: hour, clockInMinute: minute);
  }

  void setClockOut(int hour, int minute) {
    state = state.copyWith(clockOutHour: hour, clockOutMinute: minute);
  }

  void setBreakMinutes(int minutes) {
    state = state.copyWith(breakMinutes: minutes);
  }

  void setFlatAdditions(double additions) {
    state = state.copyWith(flatAdditions: additions);
  }

  void setFlatDeductions(double deductions) {
    state = state.copyWith(flatDeductions: deductions);
  }

  void setNote(String note) {
    state = state.copyWith(note: note);
  }

  void applyPreset({
    required int inHour,
    required int inMin,
    required int outHour,
    required int outMin,
    required int breakMins,
  }) {
    state = state.copyWith(
      clockInHour: inHour,
      clockInMinute: inMin,
      clockOutHour: outHour,
      clockOutMinute: outMin,
      breakMinutes: breakMins,
    );
  }

  Future<void> resetInputs() async {
    state = ActiveShiftInputState(
      shiftDate: DateTime.now(),
      clockInHour: 9,
      clockInMinute: 0,
      clockOutHour: 17,
      clockOutMinute: 0,
      breakMinutes: 30,
      flatAdditions: 0.0,
      flatDeductions: 0.0,
      note: '',
    );
    // Check interstitial counter on reset
    await _ref.read(adServiceProvider).checkAndShowInterstitial();
  }
}

final activeShiftInputProvider =
    StateNotifierProvider<ActiveShiftInputNotifier, ActiveShiftInputState>((ref) {
  return ActiveShiftInputNotifier(ref);
});

// Derived live calculation provider
final currentCalculationResultProvider = Provider<ShiftCalculationResult>((ref) {
  final prefs = ref.watch(shiftPreferencesProvider);
  final input = ref.watch(activeShiftInputProvider);

  return ShiftCalculator.calculate(
    clockInHour: input.clockInHour,
    clockInMinute: input.clockInMinute,
    clockOutHour: input.clockOutHour,
    clockOutMinute: input.clockOutMinute,
    breakMinutes: input.breakMinutes,
    baseWage: prefs.baseWage,
    otMultiplier: prefs.otMultiplier,
    dailyThreshold: prefs.dailyThreshold,
    nightDiff: prefs.nightDiff,
    flatAdditions: input.flatAdditions,
    flatDeductions: input.flatDeductions,
  );
});

// Shift History Provider
class ShiftHistoryNotifier extends StateNotifier<List<ShiftHistoryItem>> {
  final StorageService _storage;
  final Ref _ref;

  ShiftHistoryNotifier(this._storage, this._ref) : super(_storage.getShiftHistory());

  Future<void> saveCurrentShift() async {
    final prefs = _ref.read(shiftPreferencesProvider);
    final input = _ref.read(activeShiftInputProvider);
    final result = _ref.read(currentCalculationResultProvider);

    final newItem = ShiftHistoryItem(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      shiftDate: input.shiftDate,
      clockInHour: input.clockInHour,
      clockInMinute: input.clockInMinute,
      clockOutHour: input.clockOutHour,
      clockOutMinute: input.clockOutMinute,
      breakMinutes: input.breakMinutes,
      baseWage: prefs.baseWage,
      currency: prefs.currency,
      otMultiplier: prefs.otMultiplier,
      dailyThreshold: prefs.dailyThreshold,
      nightDiff: prefs.nightDiff,
      flatAdditions: input.flatAdditions,
      flatDeductions: input.flatDeductions,
      result: result,
      note: input.note,
    );

    final updated = [newItem, ...state];
    state = updated;
    await _storage.saveShiftHistory(updated);

    // Trigger interstitial every 3rd save or reset
    await _ref.read(adServiceProvider).checkAndShowInterstitial();
  }

  Future<void> deleteShift(String id) async {
    final updated = state.where((s) => s.id != id).toList();
    state = updated;
    await _storage.saveShiftHistory(updated);
  }

  Future<void> clearAll() async {
    state = [];
    await _storage.saveShiftHistory([]);
  }
}

final shiftHistoryProvider =
    StateNotifierProvider<ShiftHistoryNotifier, List<ShiftHistoryItem>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ShiftHistoryNotifier(storage, ref);
});

// Rewarded Ad 24-Hour Unlock State
class RewardedUnlockNotifier extends StateNotifier<bool> {
  final StorageService _storage;
  final AdService _adService;

  RewardedUnlockNotifier(this._storage, this._adService)
      : super(_storage.isRewardedUnlocked());

  void refreshStatus() {
    state = _storage.isRewardedUnlocked();
  }

  DateTime? get unlockExpiry => _storage.getRewardedUnlockExpiry();

  Future<bool> watchAdToUnlock() async {
    final success = await _adService.showRewardedAd(
      onRewardEarned: () {
        state = true;
      },
    );
    if (success) {
      state = true;
    }
    return success;
  }
}

final rewardedUnlockProvider =
    StateNotifierProvider<RewardedUnlockNotifier, bool>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final adService = ref.watch(adServiceProvider);
  return RewardedUnlockNotifier(storage, adService);
});

// Theme Mode Provider (Dark, Light, System)
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final StorageService _storage;

  ThemeModeNotifier(this._storage) : super(_parseThemeMode(_storage.getThemeMode()));

  static ThemeMode _parseThemeMode(String val) {
    switch (val) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final str = mode == ThemeMode.light ? 'light' : (mode == ThemeMode.dark ? 'dark' : 'system');
    await _storage.setThemeMode(str);
  }

  Future<void> toggleTheme() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeModeNotifier(storage);
});

