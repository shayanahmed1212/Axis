// ignore_for_file: prefer_const_constructors, unnecessary_underscores, unused_import, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/widgets/app_snackbar.dart';
import 'package:axis/core/widgets/confirm_dialog.dart';
import 'package:axis/core/widgets/primary_button.dart';
import 'package:axis/features/tasks/application/task_providers.dart';
import 'package:axis/features/tasks/application/task_controller.dart';
import 'package:axis/features/tasks/presentation/widgets/task_card.dart';
import 'package:axis/features/tasks/presentation/widgets/task_filter_tabs.dart';
import 'package:axis/features/tasks/presentation/widgets/task_empty_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListProvider);
    final filter = ref.watch(taskFilterProvider);
    final controller = ref.watch(taskControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: Text(
          'My Tasks',
          style: GoogleFonts.getFont(
            AppTypography.displayFamily,
            fontSize: AppTypography.displaySize,
            fontWeight: FontWeight(AppTypography.displayWeight),
            letterSpacing: AppTypography.displayLetterSpacing,
            color: AppColors.ink,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TaskFilterTabs(
              currentFilter: filter,
              onChanged: (f) => controller.setFilter(f),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface1,
              onRefresh: () async {
                ref.invalidate(taskListProvider);
              },
              child: tasksAsync.when(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(
                          'Something drifted.',
                          style: GoogleFonts.getFont(
                            AppTypography.displayFamily,
                            fontSize: AppTypography.headlineSize,
                            fontWeight: FontWeight(AppTypography.headlineWeight),
                            letterSpacing: AppTypography.headlineLetterSpacing,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: GoogleFonts.getFont(
                            AppTypography.bodyFamily,
                            fontSize: AppTypography.bodySize,
                            fontWeight: FontWeight(AppTypography.bodyWeight),
                            color: AppColors.inkMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: 'Recalibrate',
                          onPressed: () => ref.invalidate(taskListProvider),
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return TaskEmptyState(
                      filter: filter,
                      onAddTask: () => context.push('/task/new'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () => context.push('/task/${task.id}'),
                        onToggleComplete: (completed) async {
                          try {
                            await controller.toggleCompletion(task);
                          } catch (e) {
                            AppSnackbar.show(context, 'Failed to update task', type: SnackBarType.error);
                          }
                        },
                        onDelete: () async {
                          try {
                            await controller.deleteTask(task.id);
                            AppSnackbar.show(
                              context, 'Task deleted',
                              type: SnackBarType.success,
                              actionLabel: 'Undo',
                              onAction: () async {
                                await controller.createTask(
                                  title: task.title,
                                  description: task.description,
                                  priority: task.priority,
                                  dueDate: task.dueDate,
                                );
                              },
                            );
                          } catch (e) {
                            AppSnackbar.show(context, 'Failed to delete task', type: SnackBarType.error);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/task/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
