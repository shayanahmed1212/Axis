// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/widgets/priority_ribbon.dart';
import 'package:axis/core/utils/haptics.dart';
import 'package:axis/features/tasks/application/task_providers.dart';
import 'package:axis/features/tasks/application/task_controller.dart';
import 'package:axis/features/tasks/domain/task.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.chevron_left_rounded, size: 28), onPressed: () => context.pop()),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) {
          final task = tasks.where((t) => t.id == taskId).firstOrNull;
          if (task == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 64, color: AppColors.inkMuted),
                  const SizedBox(height: 16),
                  Text('Task not found', style: AppTypography.body(size: 16, weight: 600, color: AppColors.ink)),
                  const SizedBox(height: 8),
                  Text('This task may have been deleted', style: AppTypography.body(size: 13, weight: 400, color: AppColors.inkMuted)),
                  const SizedBox(height: 24),
                  TextButton(onPressed: () => context.pop(), child: Text('Go back')),
                ],
              ),
            );
          }
          return _buildDetail(context, ref, task);
        },
      ),
    );
  }

  Widget _buildDetail(BuildContext context, WidgetRef ref, Task task) {
    final controller = ref.read(taskControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Priority ribbon
          PriorityRibbon(priority: task.priority, scale: 1.5),
          const SizedBox(height: 20),

          // Task card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(AppTokens.radiusXl),
              boxShadow: AppTokens.shadowCardWhite,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTypography.display(size: 22, weight: 700, color: AppColors.ink),
                ),
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    task.description!,
                    style: AppTypography.body(size: AppTypography.bodySize, weight: AppTypography.bodyWeight, color: AppColors.inkMuted),
                  ),
                ],
                const SizedBox(height: 20),
                // Metadata chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (task.dueDate != null)
                      _MetaChip(icon: Icons.calendar_today_rounded, label: _formatDate(task.dueDate!)),
                    _MetaChip(icon: Icons.access_time_rounded, label: _formatDate(task.createdAt)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Actions
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                AppHaptics.mediumImpact();
                try {
                  await controller.toggleCompletion(task);
                  if (context.mounted) context.pop();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: task.isCompleted ? AppColors.blockSage : AppColors.accent,
                foregroundColor: task.isCompleted ? AppColors.blockSageText : AppColors.accentInk,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusPill)),
                elevation: 0,
              ),
              child: Text(
                task.isCompleted ? 'Mark incomplete' : 'Mark complete',
                style: AppTypography.body(size: AppTypography.buttonSize, weight: AppTypography.buttonWeight),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () async {
                AppHaptics.mediumImpact();
                try {
                  await controller.deleteTask(task.id);
                  if (context.mounted) context.pop();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                  }
                }
              },
              child: Text(
                'Delete task',
                style: AppTypography.body(size: 14, weight: 500, color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.inkMuted),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.body(size: 12, weight: 500, color: AppColors.inkMuted)),
        ],
      ),
    );
  }
}
