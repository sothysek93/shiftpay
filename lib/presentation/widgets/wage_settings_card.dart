import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/shift_providers.dart';
import 'scale_button.dart';

class WageSettingsCard extends ConsumerStatefulWidget {
  const WageSettingsCard({super.key});

  @override
  ConsumerState<WageSettingsCard> createState() => _WageSettingsCardState();
}

class _WageSettingsCardState extends ConsumerState<WageSettingsCard> {
  late TextEditingController _wageController;
  late TextEditingController _customOtController;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(shiftPreferencesProvider);
    _wageController = TextEditingController(text: prefs.baseWage.toStringAsFixed(2));
    _customOtController = TextEditingController(text: prefs.otMultiplier.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _wageController.dispose();
    _customOtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final prefs = ref.watch(shiftPreferencesProvider);
    final notifier = ref.read(shiftPreferencesProvider.notifier);

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
          // Section Title & Currency Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Base Wage & OT Rules',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                  color: colors.textPrimary,
                ),
              ),
              _buildCurrencySelector(context, colors, prefs.currency, notifier),
            ],
          ),

          const SizedBox(height: 14),

          // Base Hourly Wage Field + Quick Adjust Steppers
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Base Hourly Wage',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _wageController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 6, top: 12),
                          child: Text(
                            prefs.currency,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ),
                        suffixText: '/hr',
                        suffixStyle: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val);
                        if (parsed != null && parsed >= 0) {
                          notifier.setBaseWage(parsed);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Quick Wage Steppers (+0.50, +1.00)
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAdjustButton(colors, '+0.50', () {
                            final newWage = prefs.baseWage + 0.50;
                            _wageController.text = newWage.toStringAsFixed(2);
                            notifier.setBaseWage(newWage);
                          }),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildQuickAdjustButton(colors, '+1.00', () {
                            final newWage = prefs.baseWage + 1.00;
                            _wageController.text = newWage.toStringAsFixed(2);
                            notifier.setBaseWage(newWage);
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Overtime Multiplier Selection (1.5x, 2.0x, Custom)
          Text(
            'Overtime Rate Multiplier',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildMultiplierPill(
                colors: colors,
                label: '1.5x (Time & Half)',
                multiplier: 1.5,
                current: prefs.otMultiplier,
                onSelected: () {
                  _customOtController.text = '1.5';
                  notifier.setOtMultiplier(1.5);
                },
              ),
              const SizedBox(width: 6),
              _buildMultiplierPill(
                colors: colors,
                label: '2.0x (Double)',
                multiplier: 2.0,
                current: prefs.otMultiplier,
                onSelected: () {
                  _customOtController.text = '2.0';
                  notifier.setOtMultiplier(2.0);
                },
              ),
              const SizedBox(width: 6),
              _buildCustomMultiplierPill(context, colors, prefs.otMultiplier, notifier),
            ],
          ),

          const SizedBox(height: 14),

          // Daily Overtime Threshold Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily OT Threshold',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: colors.textMuted,
                ),
              ),
              Text(
                'After ${prefs.dailyThreshold.toStringAsFixed(1)} hrs/day',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.overtime,
                ),
              ),
            ],
          ),
          Slider(
            value: prefs.dailyThreshold,
            min: 4.0,
            max: 12.0,
            divisions: 16,
            label: '${prefs.dailyThreshold.toStringAsFixed(1)}h',
            activeColor: colors.overtime,
            onChanged: (val) {
              notifier.setDailyThreshold(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(
    BuildContext context,
    AppColorScheme colors,
    String currentCurrency,
    ShiftPreferencesNotifier notifier,
  ) {
    return ScaleButton(
      onTap: () {
        HapticFeedback.selectionClick();
        showModalBottomSheet(
          context: context,
          backgroundColor: colors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(20),
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
                  'Select Currency',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.supportedCurrencies.map((c) {
                    final isSel = c == currentCurrency;
                    return ScaleButton(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        notifier.setCurrency(c);
                        AnalyticsService().logCurrencyChanged(c);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel
                              ? colors.primary.withValues(alpha: 0.15)
                              : colors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSel ? colors.primary : colors.border,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          c,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSel ? colors.primary : colors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
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
            Text(
              currentCurrency,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 3),
            Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: colors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAdjustButton(AppColorScheme colors, String label, VoidCallback onTap) {
    return ScaleButton(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border, width: 0.8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildMultiplierPill({
    required AppColorScheme colors,
    required String label,
    required double multiplier,
    required double current,
    required VoidCallback onSelected,
  }) {
    final isSelected = (current - multiplier).abs() < 0.01;
    return Expanded(
      child: ScaleButton(
        onTap: () {
          HapticFeedback.selectionClick();
          onSelected();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.overtime.withValues(alpha: 0.15)
                : colors.surfaceSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? colors.overtime : colors.border,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? colors.overtime : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomMultiplierPill(
    BuildContext context,
    AppColorScheme colors,
    double current,
    ShiftPreferencesNotifier notifier,
  ) {
    final isCustom = (current - 1.5).abs() > 0.01 && (current - 2.0).abs() > 0.01;
    return ScaleButton(
      onTap: () async {
        HapticFeedback.selectionClick();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colors.border, width: 1),
            ),
            title: Text(
              'Custom OT Multiplier',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            content: TextField(
              controller: _customOtController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: GoogleFonts.plusJakartaSans(fontSize: 15, color: colors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'e.g. 1.75, 2.5',
                suffixText: 'x',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted)),
              ),
              ElevatedButton(
                onPressed: () {
                  final val = double.tryParse(_customOtController.text);
                  if (val != null && val >= 1.0) {
                    notifier.setOtMultiplier(val);
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isCustom
              ? colors.overtime.withValues(alpha: 0.15)
              : colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCustom ? colors.overtime : colors.border,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          isCustom ? '${current.toStringAsFixed(1)}x' : 'Custom',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isCustom ? FontWeight.w700 : FontWeight.w500,
            color: isCustom ? colors.overtime : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
