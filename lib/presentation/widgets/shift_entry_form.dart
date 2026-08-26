import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/shift_providers.dart';
import 'scale_button.dart';

class ShiftEntryForm extends ConsumerWidget {
  const ShiftEntryForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final input = ref.watch(activeShiftInputProvider);
    final notifier = ref.read(activeShiftInputProvider.notifier);

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
          // Section Header: Date & Quick Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shift Time & Hours',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                  color: colors.textPrimary,
                ),
              ),
              Row(
                children: [
                  // Date Picker button
                  ScaleButton(
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: input.shiftDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.dark(
                              primary: colors.primary,
                              surface: colors.surface,
                              onSurface: colors.textPrimary,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        notifier.setShiftDate(picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colors.border, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 11, color: colors.textMuted),
                          const SizedBox(width: 5),
                          Text(
                            DateFormat('EEE, MMM d').format(input.shiftDate),
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
                  const SizedBox(width: 6),
                  // Reset Button
                  ScaleButton(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      notifier.resetInputs();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colors.border, width: 0.8),
                      ),
                      child: Icon(Icons.refresh_rounded, size: 13, color: colors.textMuted),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Shift Quick Presets Scrollable Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPresetPill(colors, '9–5 Day', () {
                  AnalyticsService().logPresetApplied('9-5 Day');
                  notifier.applyPreset(inHour: 9, inMin: 0, outHour: 17, outMin: 0, breakMins: 30);
                }),
                const SizedBox(width: 6),
                _buildPresetPill(colors, '3–11 Eve', () {
                  AnalyticsService().logPresetApplied('3-11 Eve');
                  notifier.applyPreset(inHour: 15, inMin: 0, outHour: 23, outMin: 0, breakMins: 30);
                }),
                const SizedBox(width: 6),
                _buildPresetPill(colors, '11–7 Night', () {
                  AnalyticsService().logPresetApplied('11-7 Night');
                  notifier.applyPreset(inHour: 23, inMin: 0, outHour: 7, outMin: 0, breakMins: 30);
                }),
                const SizedBox(width: 6),
                _buildPresetPill(colors, '12h Day (7–7)', () {
                  AnalyticsService().logPresetApplied('12h Day (7-7)');
                  notifier.applyPreset(inHour: 7, inMin: 0, outHour: 19, outMin: 0, breakMins: 60);
                }),
                const SizedBox(width: 6),
                _buildPresetPill(colors, '12h Night (7–7)', () {
                  AnalyticsService().logPresetApplied('12h Night (7-7)');
                  notifier.applyPreset(inHour: 19, inMin: 0, outHour: 7, outMin: 0, breakMins: 60);
                }),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Clock In & Clock Out Pickers
          Row(
            children: [
              Expanded(
                child: _buildTimePickerTile(
                  context: context,
                  colors: colors,
                  label: 'Clock In',
                  hour: input.clockInHour,
                  minute: input.clockInMinute,
                  icon: Icons.login_rounded,
                  accentColor: colors.primary,
                  onTimeSelected: (t) => notifier.setClockIn(t.hour, t.minute),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTimePickerTile(
                  context: context,
                  colors: colors,
                  label: 'Clock Out',
                  hour: input.clockOutHour,
                  minute: input.clockOutMinute,
                  icon: Icons.logout_rounded,
                  accentColor: colors.overtime,
                  onTimeSelected: (t) => notifier.setClockOut(t.hour, t.minute),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Unpaid Break duration controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Unpaid Break',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                '${input.breakMinutes} min (${(input.breakMinutes / 60.0).toStringAsFixed(2)}h)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Quick Break Segmented Pills
          Row(
            children: [0, 15, 30, 45, 60].map((mins) {
              final isSelected = input.breakMinutes == mins;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: ScaleButton(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      notifier.setBreakMinutes(mins);
                    },
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary.withValues(alpha: 0.15)
                            : colors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? colors.primary : colors.border,
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${mins}m',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? colors.primary : colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetPill(AppColorScheme colors, String label, VoidCallback onTap) {
    return ScaleButton(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border, width: 0.8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerTile({
    required BuildContext context,
    required AppColorScheme colors,
    required String label,
    required int hour,
    required int minute,
    required IconData icon,
    required Color accentColor,
    required Function(TimeOfDay) onTimeSelected,
  }) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';

    return ScaleButton(
      onTap: () async {
        HapticFeedback.selectionClick();
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: hour, minute: minute),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: colors.primary,
                surface: colors.surface,
                onSurface: colors.textPrimary,
              ),
            ),
            child: child!,
          ),
        );
        if (time != null) {
          onTimeSelected(time);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: accentColor),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$h:$m',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  period,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
