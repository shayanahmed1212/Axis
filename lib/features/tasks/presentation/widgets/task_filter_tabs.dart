// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/features/tasks/data/task_repository.dart';

class TaskFilterTabs extends StatelessWidget {
  final TaskFilter currentFilter;
  final ValueChanged<TaskFilter> onChanged;

  const TaskFilterTabs({
    super.key,
    required this.currentFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.xxs),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: AppColors.hairline, width: 1),
      ),
      child: Row(
        children: TaskFilter.values.map((filter) {
          final isSelected = filter == currentFilter;
          final label = switch (filter) {
            TaskFilter.all => 'All',
            TaskFilter.active => 'Active',
            TaskFilter.completed => 'Completed',
          };
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: AppTokens.durationNormal),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentSoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: isSelected
                      ? Border.all(color: AppColors.accent.withOpacity(0.3), width: 1)
                      : null,
                ),
                child: Text(
                  label,
                  style: GoogleFonts.getFont(
                    isSelected ? AppTypography.displayFamily : AppTypography.bodyFamily,
                    fontSize: AppTypography.bodySmSize,
                    fontWeight: isSelected ? FontWeight(AppTypography.headlineWeight) : FontWeight(AppTypography.bodySmWeight),
                    color: isSelected ? AppColors.accent : AppColors.inkSubtle,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
