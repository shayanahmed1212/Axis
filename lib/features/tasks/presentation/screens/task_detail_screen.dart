// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/widgets/app_snackbar.dart';
import 'package:axis/core/widgets/confirm_dialog.dart';
import 'package:axis/features/tasks/application/task_providers.dart';
import 'package:axis/features/tasks/application/task_controller.dart';
import 'package:axis/features/tasks/domain/task.dart';
import 'package:axis/features/tasks/domain/task_priority.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailProvider(taskId));

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: Text(
          'Task Details',
          style: GoogleFonts.getFont(
            AppTypography.bodyFamily,
            fontSize: AppTypography.cardTitleSize,
            fontWeight: FontWeight(AppTypography.cardTitleWeight),
            color: AppColors.ink,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              final currentTask = taskAsync.valueOrNull;
              if (currentTask != null) {
                context.push('/task/edit/${currentTask.id}');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: 'Delete Task',
                message: 'Are you sure you want to delete this task?',
                confirmLabel: 'Delete',
              );
              if (confirmed == true) {
                try {
                  await ref.read(taskControllerProvider).deleteTask(taskId);
                  AppSnackbar.show(context, 'Task deleted', type: SnackBarType.success);
                  if (context.mounted) context.pop();
                } catch (e) {
                  AppSnackbar.show(context, 'Failed to delete task', type: SnackBarType.error);
                }
              }
            },
          ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'Error: $error',
              style: GoogleFonts.getFont(
                AppTypography.bodyFamily,
                fontSize: AppTypography.bodySize,
                fontWeight: FontWeight(AppTypography.bodyWeight),
                color: AppColors.error,
              ),
            ),
          ),
        ),
        data: (task) => _TaskDetailContent(
          task: task,
          onToggleComplete: () async {
            try {
              await ref.read(taskControllerProvider).toggleCompletion(task);
              ref.invalidate(taskDetailProvider(taskId));
            } catch (e) {
              AppSnackbar.show(context, 'Failed to update task', type: SnackBarType.error);
            }
          },
        ),
      ),
    );
  }
}

class _TaskDetailContent extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleComplete;

  const _TaskDetailContent({required this.task, required this.onToggleComplete});

  Color _priorityColor() {
    return switch (task.priority) {
      TaskPriority.low => AppColors.success,
      TaskPriority.medium => AppColors.primary,
      TaskPriority.high => AppColors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onToggleComplete,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted ? AppColors.accent : AppColors.hairlineStrong,
                      width: 2,
                    ),
                    color: task.isCompleted ? AppColors.accent : Colors.transparent,
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, size: 16, color: AppColors.onPrimary)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  task.title,
                  style: GoogleFonts.getFont(
                    AppTypography.displayFamily,
                    fontSize: AppTypography.headlineSize,
                    fontWeight: FontWeight(AppTypography.headlineWeight),
                    letterSpacing: AppTypography.headlineLetterSpacing,
                    color: task.isCompleted ? AppColors.inkSubtle : AppColors.ink,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _priorityColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  task.priorityDisplay,
                  style: GoogleFonts.getFont(
                    AppTypography.bodyFamily,
                    fontSize: AppTypography.bodySmSize,
                    fontWeight: FontWeight(AppTypography.bodySmWeight),
                    color: _priorityColor(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (task.dueDate != null)
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: AppColors.inkSubtle),
                    const SizedBox(width: 4),
                    Text(
                      '${task.dueDate!.month}/${task.dueDate!.day}/${task.dueDate!.year}',
                      style: GoogleFonts.getFont(
                        AppTypography.bodyFamily,
                        fontSize: AppTypography.bodySmSize,
                        fontWeight: FontWeight(AppTypography.bodySmWeight),
                        color: AppColors.inkSubtle,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              task.description!,
              style: GoogleFonts.getFont(
                AppTypography.bodyFamily,
                fontSize: AppTypography.bodySize,
                fontWeight: FontWeight(AppTypography.bodyWeight),
                color: AppColors.inkMuted,
              ),
            ),
          ],
          const SizedBox(height: 32),
          Text(
            'Created ${task.createdAt.month}/${task.createdAt.day}/${task.createdAt.year}',
            style: GoogleFonts.getFont(
              AppTypography.bodyFamily,
              fontSize: AppTypography.captionSize,
              fontWeight: FontWeight(AppTypography.captionWeight),
              letterSpacing: AppTypography.captionLetterSpacing,
              color: AppColors.inkSubtle,
            ),
          ),
        ],
      ),
    );
  }
}
