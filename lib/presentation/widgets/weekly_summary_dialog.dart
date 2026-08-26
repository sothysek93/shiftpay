import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/shift_calculator.dart';
import '../../models/shift_model.dart';
import 'scale_button.dart';

class WeeklySummaryDialog extends StatelessWidget {
  final List<ShiftHistoryItem> shifts;
  final String currency;

  const WeeklySummaryDialog({
    super.key,
    required this.shifts,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final report = ShiftCalculator.formatWeeklyExportReport(shifts: shifts, currency: currency);

    double totalGross = 0.0;
    double totalNet = 0.0;
    double totalRegular = 0.0;
    double totalOT = 0.0;
    double totalNight = 0.0;

    for (final s in shifts) {
      totalGross += s.result.grossPay;
      totalNet += s.result.netPaidHours;
      totalRegular += s.result.regularHours;
      totalOT += s.result.otHours;
      totalNight += s.result.nightDiffHours;
    }

    final avgRate = totalNet > 0 ? (totalGross / totalNet) : 0.0;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.border, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.analytics_rounded, size: 16, color: colors.primary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Weekly Summary',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, size: 18, color: colors.textMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Top Aggregated Stats
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border, width: 0.8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Gross Earnings', style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                      Text(
                        '$currency${totalGross.toStringAsFixed(2)}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: colors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Hours', style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                      Text(
                        '${totalNet.toStringAsFixed(2)}h (${totalRegular.toStringAsFixed(1)}h reg + ${totalOT.toStringAsFixed(1)}h OT)',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary),
                      ),
                    ],
                  ),
                  if (totalNight > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Night Diff Hours', style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                        Text(
                          '${totalNight.toStringAsFixed(2)} hrs',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.nightDiff),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Average Effective Rate', style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                      Text(
                        '$currency${avgRate.toStringAsFixed(2)}/hr',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Scrollable Raw Report Snippet
            Text(
              'Report Preview',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: colors.textMuted),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 160),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.border, width: 0.8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    report,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10.5,
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Copy Report CTA
            ScaleButton(
              onTap: () {
                HapticFeedback.lightImpact();
                Clipboard.setData(ClipboardData(text: report));
                AnalyticsService().logWeeklyReportCopied(
                  shiftCount: shifts.length,
                  totalGross: totalGross,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: colors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Weekly report copied to clipboard',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                    backgroundColor: colors.surfaceHighlight,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
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
                    const Icon(Icons.copy_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Copy Full Report',
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
          ],
        ),
      ),
    );
  }
}
