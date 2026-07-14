// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';

class DueDatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DueDatePickerField({
    super.key,
    this.selectedDate,
    required this.onDateSelected,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surface2,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Due Date',
            style: GoogleFonts.getFont(
              AppTypography.bodyFamily,
              fontSize: AppTypography.bodySize,
              fontWeight: FontWeight(AppTypography.bodyWeight),
              color: AppColors.inkMuted,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _pickDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface1,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(color: AppColors.hairline, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.inkSubtle, size: 18),
                const SizedBox(width: 12),
                Text(
                  selectedDate != null
                      ? '${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}'
                      : 'No due date',
                  style: GoogleFonts.getFont(
                    AppTypography.bodyFamily,
                    fontSize: AppTypography.bodySize,
                    fontWeight: FontWeight(AppTypography.bodyWeight),
                    color: selectedDate != null ? AppColors.ink : AppColors.inkSubtle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
