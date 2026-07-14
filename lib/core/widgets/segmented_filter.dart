// Pill-shaped segmented filter with accent fill indicator
import 'package:flutter/material.dart';
import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/utils/haptics.dart';
import 'package:axis/features/tasks/domain/task_filter.dart';

class SegmentedFilter extends StatelessWidget {
  final TaskFilter currentFilter;
  final ValueChanged<TaskFilter> onChanged;

  const SegmentedFilter({
    super.key,
    required this.currentFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.hairline.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Row(
        children: TaskFilter.values.map((filter) {
          final isSelected = filter == currentFilter;
          final label = switch (filter) {
            TaskFilter.all => 'All',
            TaskFilter.active => 'Active',
            TaskFilter.completed => 'Done',
          };
          return Expanded(
            child: GestureDetector(
              onTap: () {
                AppHaptics.selectionClick();
                onChanged(filter);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: AppTokens.durationNormal),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    size: 13,
                    weight: isSelected ? AppTypography.buttonWeight : AppTypography.bodyWeight,
                    color: isSelected ? AppColors.accentInk : AppColors.inkMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
