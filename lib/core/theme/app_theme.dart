import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData dark() {
    const scheme = AppColorScheme.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scheme.background,
      colorScheme: ColorScheme.dark(
        primary: scheme.primary,
        secondary: scheme.overtime,
        surface: scheme.surface,
        error: scheme.error,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: scheme.textPrimary,
        onError: Colors.white,
        outline: scheme.border,
        outlineVariant: scheme.borderSubtle,
      ),
      extensions: const [scheme],
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.background,
      textTheme: _textTheme(scheme.textPrimary, scheme.textSecondary, scheme.textMuted),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: scheme.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.border, width: 1.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceSubtle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.inter(fontSize: 13, color: scheme.textMuted),
        labelStyle: GoogleFonts.inter(fontSize: 13, color: scheme.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.border,
        thickness: 1,
        space: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceSubtle,
        thumbColor: Colors.white,
        overlayColor: scheme.primaryGlow,
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.black,
          elevation: 0,
          minimumSize: const Size(double.infinity, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static ThemeData light() {
    const scheme = AppColorScheme.light;
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: scheme.background,
      colorScheme: ColorScheme.light(
        primary: scheme.primary,
        secondary: scheme.overtime,
        surface: scheme.surface,
        error: scheme.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: scheme.textPrimary,
        onError: Colors.white,
        outline: scheme.border,
        outlineVariant: scheme.borderSubtle,
      ),
      extensions: const [scheme],
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.background,
      textTheme: _textTheme(scheme.textPrimary, scheme.textSecondary, scheme.textMuted),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: scheme.background,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.border, width: 1.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceSubtle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.inter(fontSize: 13, color: scheme.textMuted),
        labelStyle: GoogleFonts.inter(fontSize: 13, color: scheme.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.border,
        thickness: 1,
        space: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceSubtle,
        thumbColor: scheme.primary,
        overlayColor: scheme.primaryGlow,
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary, Color muted) => TextTheme(
    displayLarge: GoogleFonts.plusJakartaSans(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.8,
      color: primary,
    ),
    displayMedium: GoogleFonts.plusJakartaSans(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: primary,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: primary,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: primary,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      color: primary,
    ),
    titleSmall: GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: primary,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: primary,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: primary,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: secondary,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: primary,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: muted,
    ),
  );
}
