import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/shift_calculator.dart';
import '../../providers/shift_providers.dart';
import 'scale_button.dart';

class ResultSummaryCard extends ConsumerWidget {
  const ResultSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final result = ref.watch(currentCalculationResultProvider);
    final prefs = ref.watch(shiftPreferencesProvider);
    final input = ref.watch(activeShiftInputProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: result.otHours > 0
              ? colors.overtime.withValues(alpha: 0.35)
              : colors.border,
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category label & Overnight chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'TOTAL ESTIMATED GROSS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
              if (result.isOvernight)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.nightDiff.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: colors.nightDiff.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.nightlight_round, size: 11, color: colors.nightDiff),
                      const SizedBox(width: 4),
                      Text(
                        'Overnight',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colors.nightDiff,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Main Hero Number
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                prefs.currency,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                result.grossPay.toStringAsFixed(2),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${prefs.currency}${result.effectiveHourlyRate.toStringAsFixed(2)}/hr',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Effective rate',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3-Metric Tiles
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  colors: colors,
                  label: 'Total Paid',
                  value: '${result.netPaidHours.toStringAsFixed(2)}h',
                  subtitle: '${result.breakMinutes}m break',
                  icon: Icons.schedule_rounded,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  colors: colors,
                  label: 'Regular',
                  value: '${result.regularHours.toStringAsFixed(2)}h',
                  subtitle: '${prefs.currency}${result.regularPay.toStringAsFixed(2)}',
                  icon: Icons.timer_outlined,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  colors: colors,
                  label: 'Overtime',
                  value: '${result.otHours.toStringAsFixed(2)}h',
                  subtitle: result.otHours > 0
                      ? '${prefs.currency}${result.otPay.toStringAsFixed(2)}'
                      : '0.00',
                  icon: Icons.trending_up_rounded,
                  color: result.otHours > 0 ? colors.overtime : colors.textMuted,
                  isHighlighted: result.otHours > 0,
                ),
              ),
            ],
          ),

          // Optional Night Diff Banner
          if (prefs.nightDiff.enabled && result.nightDiffHours > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.nightDiff.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colors.nightDiff.withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.bedtime_outlined, size: 14, color: colors.nightDiff),
                  const SizedBox(width: 8),
                  Text(
                    'Night Diff (${prefs.nightDiff.startHour % 12}:00–${prefs.nightDiff.endHour % 12}:00)',
                    style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
                  ),
                  const Spacer(),
                  Text(
                    '${result.nightDiffHours.toStringAsFixed(2)}h (+${prefs.currency}${result.nightDiffPay.toStringAsFixed(2)})',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.nightDiff,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Optional Additions/Deductions row
          if (input.flatAdditions > 0 || input.flatDeductions > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (input.flatAdditions > 0)
                  Text(
                    '+${prefs.currency}${input.flatAdditions.toStringAsFixed(2)} additions',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colors.primary,
                    ),
                  ),
                if (input.flatDeductions > 0)
                  Text(
                    '-${prefs.currency}${input.flatDeductions.toStringAsFixed(2)} deductions',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colors.error,
                    ),
                  ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Primary Actions
          Row(
            children: [
              Expanded(
                flex: 4,
                child: ScaleButton(
                  onTap: () async {
                    await ref.read(shiftHistoryProvider.notifier).saveCurrentShift();
                    AnalyticsService().logShiftSaved(
                      grossPay: result.grossPay,
                      netHours: result.netPaidHours,
                      otHours: result.otHours,
                      hasNote: input.note.trim().isNotEmpty,
                      currency: prefs.currency,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: colors.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Shift logged to history',
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                              ),
                            ],
                          ),
                          backgroundColor: colors.surfaceHighlight,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: colors.border, width: 1),
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_task_rounded, color: Colors.white, size: 17),
                        const SizedBox(width: 6),
                        Text(
                          'Save Shift',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ScaleButton(
                  onTap: () {
                    final summary = ShiftCalculator.formatClipboardSummary(
                      date: input.shiftDate,
                      clockInHour: input.clockInHour,
                      clockInMinute: input.clockInMinute,
                      clockOutHour: input.clockOutHour,
                      clockOutMinute: input.clockOutMinute,
                      currency: prefs.currency,
                      baseWage: prefs.baseWage,
                      otMultiplier: prefs.otMultiplier,
                      result: result,
                      note: input.note,
                    );
                    Clipboard.setData(ClipboardData(text: summary));
                    AnalyticsService().logShiftSummaryCopied(
                      grossPay: result.grossPay,
                      netHours: result.netPaidHours,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.copy_rounded, color: colors.primary, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Shift summary copied',
                              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                            ),
                          ],
                        ),
                        backgroundColor: colors.surfaceHighlight,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: colors.border, width: 1),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.border, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy_rounded, color: colors.textSecondary, size: 15),
                        const SizedBox(width: 6),
                        Text(
                          'Copy',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required AppColorScheme colors,
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withValues(alpha: 0.1) : colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighlighted ? color.withValues(alpha: 0.35) : colors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 11, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: colors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
