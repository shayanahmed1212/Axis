// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/widgets/axis_bottom_sheet.dart';
import 'package:axis/core/widgets/bottom_nav_bar.dart';
import 'package:axis/core/errors/app_exception.dart';
import 'package:axis/features/tasks/domain/task.dart';
import 'package:axis/features/tasks/domain/task_filter.dart';
import 'package:axis/features/tasks/application/task_providers.dart';
import 'package:axis/features/tasks/presentation/screens/add_task_sheet.dart';
import 'package:axis/features/tasks/presentation/widgets/task_card.dart';
import 'package:axis/features/categories/data/category_repository.dart';
import 'package:axis/features/categories/domain/category.dart';
import 'package:axis/features/tasks/presentation/screens/task_detail_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  TaskFilter _filter = TaskFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.canvasDark,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTokens.pageMargin),
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  Icon(Icons.menu_rounded, color: AppColors.ink, size: 24),
                  const Spacer(),
                  Text(
                    'Index',
                    style: AppTypography.screenTitle(color: AppColors.inkMuted),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.surfaceCardAlt,
                      child: Icon(Icons.person_rounded, color: AppColors.ink, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: tasksAsync.when(
        data: (tasks) {
          final isEmpty = tasks.isEmpty;
          return Column(
            children: [
              if (!isEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppTokens.pageMargin),
                  child: TextField(
                    controller: _searchController,
                    style: AppTypography.body(color: AppColors.ink),
                    decoration: InputDecoration(
                      hintText: 'Search for your task\u2026',
                      hintStyle: AppTypography.body(color: AppColors.inkMuted),
                      prefixIcon: Icon(Icons.search_rounded, color: AppColors.inkMuted, size: 20),
                      filled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                        borderSide: BorderSide(color: AppColors.hairline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                        borderSide: BorderSide(color: AppColors.hairline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: AppTokens.md),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(height: AppTokens.sm),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppTokens.pageMargin),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => _showFilterSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Today',
                              style: AppTypography.body(color: AppColors.primary, weight: 500),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.expand_more_rounded, color: AppColors.primary, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTokens.lg),
              ],
              Expanded(
                child: isEmpty
                    ? _EmptyState(onAddTask: () => _showAddTaskSheet(context, categoriesAsync))
                    : _buildTaskList(tasks, categoriesAsync),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Text('Error: $e', style: AppTypography.body(color: AppColors.primary)),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0: break;
            case 1: context.go('/calendar'); break;
            case 2: context.go('/focus'); break;
            case 3: context.go('/profile'); break;
          }
        },
        onFabTap: () => _showAddTaskSheet(context, categoriesAsync),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, AsyncValue<List<Category>> categoriesAsync) {
    var filteredTasks = _searchQuery.isEmpty
        ? tasks
        : tasks.where((t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return ListView.builder(
      padding: EdgeInsets.all(AppTokens.pageMargin),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        final category = categoriesAsync.value?.firstWhere(
          (c) => c.id == task.categoryId,
          orElse: () => Category.empty,
        );
        return Padding(
          padding: EdgeInsets.only(bottom: AppTokens.md),
          child: TaskCard(
            task: task,
            category: category != null && category.id.isNotEmpty ? category : null,
            onTap: () => _showTaskDetail(context, task, categoriesAsync),
            onToggle: () => _toggleTask(task),
          ),
        );
      },
    );
  }

  void _showAddTaskSheet(BuildContext context, AsyncValue<List<Category>> categoriesAsync) {
    AddTaskSheet.show(
      context: context,
      categories: categoriesAsync.value ?? [],
      onSave: (task) async {
        try {
          final repo = ref.read(taskRepositoryProvider);
          await repo.createTask(task);
        } on AppException catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      },
    );
  }

  void _showTaskDetail(
    BuildContext context,
    Task task,
    AsyncValue<List<Category>> categoriesAsync,
  ) {
    TaskDetailSheet.show(
      context: context,
      task: task,
      categories: categoriesAsync.value ?? [],
      onSave: (updatedTask) async {
        try {
          final repo = ref.read(taskRepositoryProvider);
          await repo.updateTask(updatedTask);
        } on AppException catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      },
      onDelete: () async {
        final confirmed = await AxisConfirmationSheet.show(
          context: context,
          title: 'Delete Task',
          message: 'Delete "${task.title}"? This cannot be undone.',
          confirmLabel: 'Delete',
          confirmColor: AppColors.primary,
        );
        if (confirmed) {
          try {
            final repo = ref.read(taskRepositoryProvider);
            await repo.deleteTask(task.id);
          } on AppException catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message)),
            );
          }
        }
      },
    );
  }

  Future<void> _toggleTask(Task task) async {
    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.toggleTaskCompletion(task.id, !task.isCompleted);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AxisBottomSheet(
        title: 'Filter Tasks',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: TaskFilter.values.map((filter) {
            return ListTile(
              title: Text(
                filter == TaskFilter.all
                    ? 'All Tasks'
                    : filter == TaskFilter.active
                        ? 'Active Tasks'
                        : 'Completed Tasks',
                style: AppTypography.body(
                  color: _filter == filter ? AppColors.primary : AppColors.ink,
                ),
              ),
              trailing: _filter == filter
                  ? Icon(Icons.check_rounded, color: AppColors.primary, size: 22)
                  : null,
              onTap: () {
                setState(() => _filter = filter);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddTask;

  const _EmptyState({required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTokens.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/onboarding/home_empty.png',
              height: 200,
              errorBuilder: (_, _, _) => Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryDim,
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                ),
                child: Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 48),
              ),
            ),
            const SizedBox(height: AppTokens.xl),
            Text(
              'What do you want to do today?',
              style: AppTypography.body(color: AppColors.inkMuted, weight: 500, size: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.sm),
            Text(
              'Tap + to add your tasks',
              style: AppTypography.body(color: AppColors.primary, weight: 400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


