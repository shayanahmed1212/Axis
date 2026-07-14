// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/widgets/primary_button.dart';
import 'package:axis/features/tasks/data/task_repository.dart';

class TaskEmptyState extends StatelessWidget {
  final TaskFilter filter;
  final VoidCallback onAddTask;

  const TaskEmptyState({
    super.key,
    required this.filter,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final (title, message, icon) = switch (filter) {
      TaskFilter.all => (
        'Your axis is clear.',
        'Tasks you create will center here.',
        Icons.add_circle_outline,
      ),
      TaskFilter.active => (
        'Nothing pulling you off-center.',
        'All tasks accounted for.',
        Icons.check_circle_outline,
      ),
      TaskFilter.completed => (
        'No completed tasks yet.',
        'Finish a task to see it here.',
        Icons.task_alt,
      ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.surface2,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.hairlineStrong),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.getFont(
                AppTypography.displayFamily,
                fontSize: AppTypography.headlineSize,
                fontWeight: FontWeight(AppTypography.headlineWeight),
                letterSpacing: AppTypography.headlineLetterSpacing,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.getFont(
                AppTypography.bodyFamily,
                fontSize: AppTypography.bodySize,
                fontWeight: FontWeight(AppTypography.bodyWeight),
                color: AppColors.inkMuted,
              ),
              textAlign: TextAlign.center,
            ),
            if (filter == TaskFilter.all) ...[
              const SizedBox(height: 24),
              PrimaryButton(text: 'Add Task', onPressed: onAddTask, isFullWidth: true),
            ],
          ],
        ),
      ),
    );
  }
}
