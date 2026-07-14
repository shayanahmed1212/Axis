// Task Ribbon Card — white card on canvas, folded-corner priority tag
import 'package:flutter/material.dart';
import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/widgets/priority_ribbon.dart';
import 'package:axis/core/utils/haptics.dart';
import 'package:axis/features/tasks/domain/task.dart';

class TaskRibbonCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggleComplete;

  const TaskRibbonCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTokens.bentoGap),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          boxShadow: AppTokens.shadowCardWhite,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ribbon
              PriorityRibbon(priority: task.priority),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        task.title,
                        style: AppTypography.body(
                          size: AppTypography.cardTitleSize,
                          weight: AppTypography.cardTitleWeight,
                          color: task.isCompleted ? AppColors.inkMuted : AppColors.ink,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (task.description != null && task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: AppTypography.body(
                            size: AppTypography.captionSize,
                            weight: AppTypography.captionWeight,
                            color: AppColors.inkMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Due date row
                      if (task.dueDate != null)
                        Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 14, color: AppColors.inkMuted),
                            const SizedBox(width: 4),
                            Text(
                              _formatDueDate(task.dueDate!),
                              style: AppTypography.body(
                                size: AppTypography.captionSize,
                                weight: AppTypography.captionWeight,
                                letterSpacing: AppTypography.captionTracking,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              // Checkbox
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      AppHaptics.selectionClick();
                      onToggleComplete?.call(!task.isCompleted);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: task.isCompleted ? AppColors.success : Colors.transparent,
                        shape: BoxShape.circle,
                        border: task.isCompleted
                            ? null
                            : Border.all(color: AppColors.hairline, width: 2),
                      ),
                      child: task.isCompleted
                          ? TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: AppTokens.durationCompletion),
                              curve: Curves.easeOutBack,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                              child: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff < 0) return '${-diff}d overdue';
    return 'In $diff days';
  }
}
