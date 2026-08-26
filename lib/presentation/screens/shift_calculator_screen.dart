import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/shift_providers.dart';
import '../widgets/adjustments_card.dart';
import '../widgets/banner_ad_container.dart';
import '../widgets/night_diff_card.dart';
import '../widgets/result_summary_card.dart';
import '../widgets/scale_button.dart';
import '../widgets/shift_entry_form.dart';
import '../widgets/shift_history_list.dart';
import '../widgets/shiftpay_logo.dart';
import '../widgets/wage_settings_card.dart';

class ShiftCalculatorScreen extends ConsumerWidget {
  const ShiftCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          children: [
            const ShiftPayLogo(
              size: 26,
              borderRadius: 7,
            ),
            const SizedBox(width: 9),
            Text(
              'ShiftPay',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          // Theme Switcher (Dark / Light)
          ScaleButton(
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(themeModeProvider.notifier).toggleTheme();
              AnalyticsService().logThemeChanged(isDark ? 'light' : 'dark');
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colors.border, width: 0.8),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 14,
                color: colors.textSecondary,
              ),
            ),
          ),

          // Rules Button
          ScaleButton(
            onTap: () {
              HapticFeedback.selectionClick();
              AnalyticsService().logCalculationRulesOpened();
              _showHowItWorksModal(context);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colors.border, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.help_outline_rounded, size: 12, color: colors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Rules',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Scrollable Dashboard Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    // Real-time Result Summary Card
                    ResultSummaryCard(),
                    SizedBox(height: 12),

                    // Quick Add Shift & Time Selectors
                    ShiftEntryForm(),
                    SizedBox(height: 12),

                    // Base Wage, Currency & OT Rates
                    WageSettingsCard(),
                    SizedBox(height: 12),

                    // Night Differential Settings
                    NightDiffCard(),
                    SizedBox(height: 12),

                    // Additions, Deductions & Shift Note
                    AdjustmentsCard(),
                    SizedBox(height: 12),

                    // Shift History & Weekly Export
                    ShiftHistoryList(),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Pinned Adaptive Banner Ad
            SafeArea(
              top: false,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: colors.border, width: 0.8)),
                  color: colors.background,
                ),
                child: const BannerAdContainer(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHowItWorksModal(BuildContext context) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Calculation Rules',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            _buildRuleRow(colors, '⏱️ Elapsed Time', 'Total hours between Clock-In and Clock-Out. Handles overnight shifts seamlessly.'),
            _buildRuleRow(colors, '☕ Unpaid Break', 'Deducted directly from total shift hours before gross wage calculation.'),
            _buildRuleRow(colors, '⚡ Regular vs Overtime', 'Hours up to daily threshold (e.g. 8.0h) are paid at base rate (1.0x). Hours beyond the threshold are multiplied by your OT rate (e.g. 1.5x or 2.0x).'),
            _buildRuleRow(colors, '🌙 Night Differential', 'Counts exact minutes worked inside your configured night window and applies the bonus premium rate.'),
            _buildRuleRow(colors, '💰 Gross Pay Formula', '(Regular Hours × Base Rate) + (OT Hours × Base Rate × Multiplier) + (Night Hours × Night Bonus) + Tips - Deductions.'),
            const SizedBox(height: 16),
            ScaleButton(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Got it',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleRow(AppColorScheme colors, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary)),
          const SizedBox(height: 2),
          Text(desc, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary, height: 1.35)),
        ],
      ),
    );
  }
}

