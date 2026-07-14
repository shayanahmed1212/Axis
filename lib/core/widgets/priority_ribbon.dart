// Priority Ribbon — folded-corner tag, not a pill chip
import 'package:flutter/material.dart';
import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/features/tasks/domain/task_priority.dart';

class PriorityRibbon extends StatelessWidget {
  final TaskPriority priority;
  final double scale;

  const PriorityRibbon({super.key, required this.priority, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, label) = switch (priority) {
      TaskPriority.high => (AppColors.blockCoral, AppColors.blockCoralText, 'HIGH'),
      TaskPriority.medium => (AppColors.accent, AppColors.accentInk, 'MED'),
      TaskPriority.low => (AppColors.blockSage, AppColors.blockSageText, 'LOW'),
    };

    return Transform.scale(
      scale: scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.body(
            size: AppTypography.ribbonSize,
            weight: AppTypography.ribbonWeight,
            letterSpacing: AppTypography.ribbonTracking,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
