import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/shift_providers.dart';
import 'scale_button.dart';

class NightDiffCard extends ConsumerWidget {
  const NightDiffCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final prefs = ref.watch(shiftPreferencesProvider);
    final notifier = ref.read(shiftPreferencesProvider.notifier);
    final nightConfig = prefs.nightDiff;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: nightConfig.enabled
              ? colors.nightDiff.withValues(alpha: 0.35)
              : colors.border,
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bedtime_rounded,
                    size: 16,
                    color: nightConfig.enabled ? colors.nightDiff : colors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Night Differential Premium',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: nightConfig.enabled,
                  activeThumbColor: colors.nightDiff,
                  activeTrackColor: colors.nightDiff.withValues(alpha: 0.25),
                  inactiveThumbColor: colors.textMuted,
                  inactiveTrackColor: colors.surfaceSubtle,
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    notifier.setNightDiff(nightConfig.copyWith(enabled: val));
                    AnalyticsService().logNightDiffToggled(
                      enabled: val,
                      bonusRate: nightConfig.bonusRate,
                    );
                  },
                ),
              ),
            ],
          ),

          if (nightConfig.enabled) ...[
            const SizedBox(height: 10),
            Divider(color: colors.border, height: 1),
            const SizedBox(height: 12),

            // Night Window Start & End Pickers
            Text(
              'Night Premium Window',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildTimeWindowButton(
                    context: context,
                    colors: colors,
                    label: 'Starts',
                    hour: nightConfig.startHour,
                    minute: nightConfig.startMinute,
                    onSelected: (time) {
                      notifier.setNightDiff(
                        nightConfig.copyWith(startHour: time.hour, startMinute: time.minute),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward_rounded, size: 12, color: colors.textMuted),
                ),
                Expanded(
                  child: _buildTimeWindowButton(
                    context: context,
                    colors: colors,
                    label: 'Ends',
                    hour: nightConfig.endHour,
                    minute: nightConfig.endMinute,
                    onSelected: (time) {
                      notifier.setNightDiff(
                        nightConfig.copyWith(endHour: time.hour, endMinute: time.minute),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bonus $/hr Slider / Input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Night Premium Bonus',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.textMuted,
                  ),
                ),
                Text(
                  '+${prefs.currency}${nightConfig.bonusRate.toStringAsFixed(2)}/hr',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.nightDiff,
                  ),
                ),
              ],
            ),
            Slider(
              value: nightConfig.bonusRate,
              min: 0.50,
              max: 10.00,
              divisions: 38,
              label: '+${prefs.currency}${nightConfig.bonusRate.toStringAsFixed(2)}',
              activeColor: colors.nightDiff,
              onChanged: (val) {
                notifier.setNightDiff(nightConfig.copyWith(bonusRate: val));
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeWindowButton({
    required BuildContext context,
    required AppColorScheme colors,
    required String label,
    required int hour,
    required int minute,
    required Function(TimeOfDay) onSelected,
  }) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formatted = '$h:$m $period';

    return ScaleButton(
      onTap: () async {
        HapticFeedback.selectionClick();
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: hour, minute: minute),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: colors.nightDiff,
                surface: colors.surface,
                onSurface: colors.textPrimary,
              ),
            ),
            child: child!,
          ),
        );
        if (time != null) {
          onSelected(time);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 10, color: colors.textMuted)),
            const SizedBox(height: 2),
            Text(
              formatted,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.nightDiff,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
