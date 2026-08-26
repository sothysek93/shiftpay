import 'package:flutter/material.dart';

@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  final Color background;
  final Color surface;
  final Color surfaceSubtle;
  final Color surfaceHighlight;
  final Color border;
  final Color borderSubtle;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  final Color primary;
  final Color primaryGlow;
  final Color primaryDark;

  final Color overtime;
  final Color overtimeGlow;

  final Color nightDiff;
  final Color nightDiffGlow;

  final Color error;
  final Color errorGlow;
  final Color warning;
  final Color info;

  const AppColorScheme({
    required this.background,
    required this.surface,
    required this.surfaceSubtle,
    required this.surfaceHighlight,
    required this.border,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.primaryGlow,
    required this.primaryDark,
    required this.overtime,
    required this.overtimeGlow,
    required this.nightDiff,
    required this.nightDiffGlow,
    required this.error,
    required this.errorGlow,
    required this.warning,
    required this.info,
  });

  static const dark = AppColorScheme(
    background: Color(0xFF09090B),
    surface: Color(0xFF111113),
    surfaceSubtle: Color(0xFF18181B),
    surfaceHighlight: Color(0xFF222226),
    border: Color(0xFF27272A),
    borderSubtle: Color(0xFF3F3F46),
    textPrimary: Color(0xFFFAFAFA),
    textSecondary: Color(0xFFA1A1AA),
    textMuted: Color(0xFF71717A),
    primary: Color(0xFF10B981),
    primaryGlow: Color(0x2410B981),
    primaryDark: Color(0xFF059669),
    overtime: Color(0xFFF59E0B),
    overtimeGlow: Color(0x24F59E0B),
    nightDiff: Color(0xFF818CF8),
    nightDiffGlow: Color(0x24818CF8),
    error: Color(0xFFF43F5E),
    errorGlow: Color(0x24F43F5E),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF38BDF8),
  );

  static const light = AppColorScheme(
    background: Color(0xFFF8F9FA),
    surface: Color(0xFFFFFFFF),
    surfaceSubtle: Color(0xFFF1F3F5),
    surfaceHighlight: Color(0xFFE9ECEF),
    border: Color(0xFFE2E8F0),
    borderSubtle: Color(0xFFCBD5E1),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF94A3B8),
    primary: Color(0xFF059669),
    primaryGlow: Color(0x1F059669),
    primaryDark: Color(0xFF047857),
    overtime: Color(0xFFD97706),
    overtimeGlow: Color(0x1FD97706),
    nightDiff: Color(0xFF6366F1),
    nightDiffGlow: Color(0x1F6366F1),
    error: Color(0xFFE11D48),
    errorGlow: Color(0x1FE11D48),
    warning: Color(0xFFD97706),
    info: Color(0xFF0284C7),
  );

  @override
  ThemeExtension<AppColorScheme> copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSubtle,
    Color? surfaceHighlight,
    Color? border,
    Color? borderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? primary,
    Color? primaryGlow,
    Color? primaryDark,
    Color? overtime,
    Color? overtimeGlow,
    Color? nightDiff,
    Color? nightDiffGlow,
    Color? error,
    Color? errorGlow,
    Color? warning,
    Color? info,
  }) {
    return AppColorScheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      surfaceHighlight: surfaceHighlight ?? this.surfaceHighlight,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      primary: primary ?? this.primary,
      primaryGlow: primaryGlow ?? this.primaryGlow,
      primaryDark: primaryDark ?? this.primaryDark,
      overtime: overtime ?? this.overtime,
      overtimeGlow: overtimeGlow ?? this.overtimeGlow,
      nightDiff: nightDiff ?? this.nightDiff,
      nightDiffGlow: nightDiffGlow ?? this.nightDiffGlow,
      error: error ?? this.error,
      errorGlow: errorGlow ?? this.errorGlow,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  ThemeExtension<AppColorScheme> lerp(covariant ThemeExtension<AppColorScheme>? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      surfaceHighlight: Color.lerp(surfaceHighlight, other.surfaceHighlight, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryGlow: Color.lerp(primaryGlow, other.primaryGlow, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      overtime: Color.lerp(overtime, other.overtime, t)!,
      overtimeGlow: Color.lerp(overtimeGlow, other.overtimeGlow, t)!,
      nightDiff: Color.lerp(nightDiff, other.nightDiff, t)!,
      nightDiffGlow: Color.lerp(nightDiffGlow, other.nightDiffGlow, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorGlow: Color.lerp(errorGlow, other.errorGlow, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

// Extension on BuildContext for quick color access
extension AppThemeContext on BuildContext {
  AppColorScheme get colors => Theme.of(this).extension<AppColorScheme>() ?? AppColorScheme.dark;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

// Static class for backwards compatibility
abstract class AppColors {
  static const background = Color(0xFF09090B);
  static const surface = Color(0xFF111113);
  static const surfaceSubtle = Color(0xFF18181B);
  static const surfaceHighlight = Color(0xFF222226);
  static const border = Color(0xFF27272A);
  static const borderSubtle = Color(0xFF3F3F46);

  static const textPrimary = Color(0xFFFAFAFA);
  static const textSecondary = Color(0xFFA1A1AA);
  static const textMuted = Color(0xFF71717A);

  static const primary = Color(0xFF10B981);
  static const primaryGlow = Color(0x2410B981);
  static const primaryDark = Color(0xFF059669);

  static const overtime = Color(0xFFF59E0B);
  static const overtimeGlow = Color(0x24F59E0B);

  static const nightDiff = Color(0xFF818CF8);
  static const nightDiffGlow = Color(0x24818CF8);

  static const error = Color(0xFFF43F5E);
  static const errorGlow = Color(0x24F43F5E);

  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF38BDF8);
}
