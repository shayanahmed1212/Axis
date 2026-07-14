// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/features/tasks/domain/task_priority.dart';

class PriorityChipSelector extends StatelessWidget {
  final TaskPriority selectedPriority;
  final ValueChanged<TaskPriority> onChanged;

  const PriorityChipSelector({
    super.key,
    required this.selectedPriority,
    required this.onChanged,
  });

  Color _colorForPriority(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.low => AppColors.success,
      TaskPriority.medium => AppColors.primary,
      TaskPriority.high => AppColors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Priority',
            style: GoogleFonts.getFont(
              AppTypography.bodyFamily,
              fontSize: AppTypography.bodySize,
              fontWeight: FontWeight(AppTypography.bodyWeight),
              color: AppColors.inkMuted,
            ),
          ),
        ),
        Row(
          children: TaskPriority.values.map((priority) {
            final isSelected = priority == selectedPriority;
            final color = _colorForPriority(priority);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onChanged(priority),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.15) : AppColors.surface1,
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: isSelected ? color : AppColors.hairline,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    priority.displayName,
                    style: GoogleFonts.getFont(
                      AppTypography.bodyFamily,
                      fontSize: AppTypography.bodySmSize,
                      fontWeight: isSelected ? FontWeight(AppTypography.headlineWeight) : FontWeight(AppTypography.bodySmWeight),
                      color: isSelected ? color : AppColors.inkMuted,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
