// Card widget for a single task in home/calendar list views.
// Shows checkbox, title (with strikethrough when completed), due date,
// category badge (icon + coloured pill), and priority badge.
//
// The category badge uses [Category.backgroundColor] (pastel tint) for
// the fill and [Category.foregroundColor] (darkened variant) for the
// icon/text contrast. Priority is colour-coded via a static [_borderColor]
// mapping from the 1-10 scale to a discrete green/yellow/orange/red.
import 'package:flutter/material.dart';

import 'package:axis/theme/app_theme.dart';
import 'package:axis/models/task.dart';
import 'package:axis/models/category.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Category? category;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const TaskCard({
    super.key,
    required this.task,
    this.category,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(AppTokens.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: task.isCompleted ? AppColors.inkMuted : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isCompleted ? AppColors.inkMuted : const Color(0xFF757575),
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check_rounded, size: 14, color: AppColors.canvas)
                    : null,
              ),
            ),

            const SizedBox(width: AppTokens.sm),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: AppTypography.taskTitle(
                      color: task.isCompleted ? AppColors.inkMuted : AppColors.ink,
                    ).copyWith(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.dueDate != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          _formatDueDate(task.dueDate!),
                          style: AppTypography.meta(color: AppColors.inkMuted),
                        ),
                        const Spacer(),
                        if (category != null && category!.id.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _CategoryBadge(category: category!),
                          ),
                        _PriorityBadge(priority: task.priority),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final period = date.hour < 12 ? 'AM' : 'PM';
    final minuteStr = date.minute.toString().padLeft(2, '0');
    final time = '$hour:$minuteStr $period';

    if (taskDate == today) return 'Today At $time';
    if (taskDate == today.add(const Duration(days: 1))) return 'Tomorrow At $time';

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day} At $time';
  }
}

class _CategoryBadge extends StatelessWidget {
  final Category category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: category.backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.iconData, size: 16, color: category.foregroundColor),
          const SizedBox(width: 5),
          Text(
            category.name,
            style: AppTypography.meta(color: category.foregroundColor, weight: 700, size: 13),
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final int priority;

  const _PriorityBadge({required this.priority});

  static Color _borderColor(int priority) {
    if (priority <= 2) return const Color(0xFF4CAF50);
    if (priority <= 4) return const Color(0xFFFFEB3B);
    if (priority <= 7) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  @override
  Widget build(BuildContext context) {
    final color = _borderColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_outlined, size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            '$priority',
            style: AppTypography.meta(color: color, weight: 700, size: 13),
          ),
        ],
      ),
    );
  }
}
