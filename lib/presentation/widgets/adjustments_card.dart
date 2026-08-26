import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/shift_providers.dart';

class AdjustmentsCard extends ConsumerStatefulWidget {
  const AdjustmentsCard({super.key});

  @override
  ConsumerState<AdjustmentsCard> createState() => _AdjustmentsCardState();
}

class _AdjustmentsCardState extends ConsumerState<AdjustmentsCard> {
  bool _isExpanded = false;
  late TextEditingController _additionsController;
  late TextEditingController _deductionsController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final input = ref.read(activeShiftInputProvider);
    _additionsController = TextEditingController(
      text: input.flatAdditions > 0 ? input.flatAdditions.toStringAsFixed(2) : '',
    );
    _deductionsController = TextEditingController(
      text: input.flatDeductions > 0 ? input.flatDeductions.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: input.note);
  }

  @override
  void dispose() {
    _additionsController.dispose();
    _deductionsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final prefs = ref.watch(shiftPreferencesProvider);
    final notifier = ref.read(activeShiftInputProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border, width: 1.0),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.tune_rounded, size: 16, color: colors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Additions, Deductions & Notes',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: colors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Divider(color: colors.border, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Additions (Tips, allowance)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '+ Additions (Tips)',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: colors.primary),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _additionsController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                              decoration: InputDecoration(
                                prefixText: '+${prefs.currency}',
                                prefixStyle: GoogleFonts.inter(fontSize: 13, color: colors.primary),
                                hintText: '0.00',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              ),
                              onChanged: (val) {
                                final amount = double.tryParse(val) ?? 0.0;
                                notifier.setFlatAdditions(amount);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Deductions (Fees, meals)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '- Deductions (Meals)',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: colors.error),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _deductionsController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                              decoration: InputDecoration(
                                prefixText: '-${prefs.currency}',
                                prefixStyle: GoogleFonts.inter(fontSize: 13, color: colors.error),
                                hintText: '0.00',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              ),
                              onChanged: (val) {
                                final amount = double.tryParse(val) ?? 0.0;
                                notifier.setFlatDeductions(amount);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Optional Note Field
                  TextField(
                    controller: _noteController,
                    style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.edit_note_rounded, size: 18, color: colors.textMuted),
                      hintText: 'Shift Note (e.g. ICU Shift, Emergency On-Call)',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (val) => notifier.setNote(val),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
