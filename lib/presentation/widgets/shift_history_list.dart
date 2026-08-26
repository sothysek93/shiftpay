import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/shift_calculator.dart';
import '../../models/shift_model.dart';
import '../../providers/shift_providers.dart';
import 'scale_button.dart';
import 'weekly_summary_dialog.dart';

class ShiftHistoryList extends ConsumerWidget {
  const ShiftHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final history = ref.watch(shiftHistoryProvider);
    final historyNotifier = ref.read(shiftHistoryProvider.notifier);
    final prefs = ref.watch(shiftPreferencesProvider);
    final isUnlocked = ref.watch(rewardedUnlockProvider);
    final unlockNotifier = ref.read(rewardedUnlockProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border, width: 1.0),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Weekly Export CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Shift History',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.1,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: colors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.border, width: 0.8),
                    ),
                    child: Text(
                      '${history.length}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              // Weekly Export Button
              ScaleButton(
                onTap: () async {
                  HapticFeedback.selectionClick();
                  if (isUnlocked) {
                    _showExportDialog(context, history, prefs.currency);
                  } else {
                    _showRewardedUnlockPrompt(context, colors, unlockNotifier, history, prefs.currency);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? colors.primary.withValues(alpha: 0.15)
                        : colors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isUnlocked ? colors.primary : colors.border,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                        size: 12,
                        color: isUnlocked ? colors.primary : colors.overtime,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isUnlocked ? 'Weekly Summary' : 'Weekly Summary',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked ? colors.primary : colors.overtime,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 12),

          if (history.isEmpty) ...[
            // Minimalist Empty State
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 32,
                      color: colors.textMuted.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No shifts logged yet',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap "Save Shift" above to record your earnings',
                      style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Shifts List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = history[index];
                return _buildHistoryItemTile(context, colors, item, historyNotifier);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryItemTile(
    BuildContext context,
    AppColorScheme colors,
    ShiftHistoryItem item,
    ShiftHistoryNotifier historyNotifier,
  ) {
    final dateFormatted = DateFormat('EEE, MMM d').format(item.shiftDate);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormatted,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.clockInFormatted} – ${item.clockOutFormatted}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              // Daily Earnings Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.3), width: 0.8),
                ),
                child: Text(
                  '${item.currency}${item.result.grossPay.toStringAsFixed(2)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Hours Breakdown Pills & Actions
          Row(
            children: [
              _buildSmallBadge('${item.result.netPaidHours.toStringAsFixed(2)}h', colors.textPrimary),
              const SizedBox(width: 4),
              _buildSmallBadge('${item.result.regularHours.toStringAsFixed(1)}h reg', colors.textSecondary),
              if (item.result.otHours > 0) ...[
                const SizedBox(width: 4),
                _buildSmallBadge('+${item.result.otHours.toStringAsFixed(1)}h OT', colors.overtime),
              ],
              if (item.result.nightDiffHours > 0) ...[
                const SizedBox(width: 4),
                _buildSmallBadge('${item.result.nightDiffHours.toStringAsFixed(1)}h night', colors.nightDiff),
              ],
              const Spacer(),
              // Copy Button
              ScaleButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  final snippet = ShiftCalculator.formatClipboardSummary(
                    date: item.shiftDate,
                    clockInHour: item.clockInHour,
                    clockInMinute: item.clockInMinute,
                    clockOutHour: item.clockOutHour,
                    clockOutMinute: item.clockOutMinute,
                    currency: item.currency,
                    baseWage: item.baseWage,
                    otMultiplier: item.otMultiplier,
                    result: item.result,
                    note: item.note,
                  );
                  Clipboard.setData(ClipboardData(text: snippet));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Shift details copied', style: GoogleFonts.inter(color: Colors.white, fontSize: 12)),
                      backgroundColor: colors.surfaceHighlight,
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.copy_rounded, size: 14, color: colors.textMuted),
                ),
              ),
              const SizedBox(width: 2),
              // Delete Button
              ScaleButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  historyNotifier.deleteShift(item.id);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline_rounded, size: 15, color: colors.error),
                ),
              ),
            ],
          ),
          if (item.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.note,
              style: GoogleFonts.inter(fontSize: 11, fontStyle: FontStyle.italic, color: colors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  void _showExportDialog(BuildContext context, List<ShiftHistoryItem> history, String currency) {
    showDialog(
      context: context,
      builder: (ctx) => WeeklySummaryDialog(shifts: history, currency: currency),
    );
  }

  void _showRewardedUnlockPrompt(
    BuildContext context,
    AppColorScheme colors,
    RewardedUnlockNotifier unlockNotifier,
    List<ShiftHistoryItem> history,
    String currency,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.overtime.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.video_collection_rounded, size: 28, color: colors.overtime),
            ),
            const SizedBox(height: 12),
            Text(
              'Unlock Weekly Summary Export',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Watch a short sponsored video to unlock comprehensive weekly analytical reports and exports for the next 24 hours.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            ScaleButton(
              onTap: () async {
                Navigator.pop(ctx);
                final unlocked = await unlockNotifier.watchAdToUnlock();
                if (unlocked && context.mounted) {
                  _showExportDialog(context, history, currency);
                }
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: colors.overtime,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Watch Ad & Unlock (24h)',
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
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
