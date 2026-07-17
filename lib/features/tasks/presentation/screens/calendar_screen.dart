// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/widgets/pressable.dart';
import 'package:axis/core/widgets/bottom_nav_bar.dart';
import 'package:axis/core/errors/app_exception.dart';
import 'package:axis/features/tasks/domain/task.dart';
import 'package:axis/features/tasks/application/task_providers.dart';
import 'package:axis/features/tasks/presentation/screens/add_task_sheet.dart';
import 'package:axis/features/tasks/presentation/widgets/task_card.dart';
import 'package:axis/features/categories/data/category_repository.dart';
import 'package:axis/features/categories/domain/category.dart';
import 'package:axis/features/tasks/presentation/screens/task_detail_sheet.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;
  late List<DateTime> _scrollDays;
  CalendarTab _tab = CalendarTab.today;
  final ScrollController _scrollController = ScrollController();
  double _itemWidth = 52;

  static const _dayLabels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  static const _monthLabels = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
    'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
    _scrollDays = _generateScrollDays(_selectedDay);
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerDate(_selectedDay));
  }

  List<DateTime> _generateScrollDays(DateTime center) {
    return List.generate(61, (i) => center.subtract(Duration(days: 30 - i)));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _centerDate(DateTime date) {
    final index = _scrollDays.indexWhere((d) => _isSameDay(d, date));
    if (index < 0) {
      setState(() {
        _scrollDays = _generateScrollDays(date);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndex(30);
      });
      return;
    }
    _scrollToIndex(index);
  }

  void _scrollToIndex(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final target = (index * _itemWidth) - (screenWidth / 2) + (_itemWidth / 2);
    _scrollController.animateTo(
      target.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppTokens.md),
            Text(
              'Calendar',
              style: AppTypography.screenTitle(color: AppColors.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.md),
            Container(
              width: double.infinity,
              color: const Color(0xFF2C2C2C),
              padding: const EdgeInsets.symmetric(vertical: AppTokens.sm),
              child: Column(
                children: [
                  _buildMonthHeader(),
                  const SizedBox(height: AppTokens.sm),
                  _buildWeekStrip(tasksAsync),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterBar(),
            const SizedBox(height: AppTokens.sm),
            Expanded(child: _buildTaskList(tasksAsync, categoriesAsync)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0: context.go('/'); break;
            case 1: break;
            case 2: context.go('/focus'); break;
            case 3: context.go('/profile'); break;
          }
        },
        onFabTap: () => _showAddTaskSheet(context, categoriesAsync),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTokens.pageMargin),
      child: Row(
        children: [
          Pressable(
            onTap: () => _changeMonth(-1),
            child: Icon(Icons.chevron_left_rounded, color: AppColors.inkMuted, size: 28),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                _monthLabels[_focusedMonth.month - 1],
                style: AppTypography.meta(
                  color: AppColors.ink,
                  weight: 700,
                  size: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_focusedMonth.year}',
                style: AppTypography.meta(
                  color: AppColors.inkMuted,
                  weight: 400,
                  size: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          Pressable(
            onTap: () => _changeMonth(1),
            child: Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStrip(AsyncValue<List<Task>> tasksAsync) {
    final tasks = tasksAsync.asData?.value ?? [];
    _itemWidth = (MediaQuery.of(context).size.width - AppTokens.pageMargin * 2) / 7;

    return SizedBox(
      height: 72,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _scrollDays.length,
        padding: EdgeInsets.symmetric(horizontal: AppTokens.pageMargin),
        itemExtent: _itemWidth,
        itemBuilder: (context, index) {
          final day = _scrollDays[index];
          final isSelected = _isSameDay(day, _selectedDay);
          final isToday = _isSameDay(day, DateTime.now());
          final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
          final dayHasTasks = tasks.any((t) => t.dueDate != null && _isSameDay(t.dueDate!, day));

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDay = day);
              _centerDate(day);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: AppTokens.xs),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _dayLabels[day.weekday % 7],
                    style: AppTypography.meta(
                      color: isSelected
                          ? AppColors.onPrimary
                          : isWeekend
                              ? AppColors.weekendRed
                              : AppColors.inkMuted,
                      weight: 600,
                      size: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.inkMuted,
                      fontSize: isSelected ? 20 : 16,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: dayHasTasks
                          ? (isSelected ? AppColors.onPrimary : AppColors.primary)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTokens.pageMargin),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          color: const Color(0xFF1D1D1D),
          child: Row(
            children: CalendarTab.values.map((tab) {
              final isSelected = _tab == tab;
              return Expanded(
                child: Pressable(
                  onTap: () => setState(() => _tab = tab),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: AppTokens.sm),
                    color: isSelected ? const Color(0xFF8586E7) : Colors.transparent,
                    child: Center(
                      child: Text(
                        tab.label,
                        style: AppTypography.body(
                          color: isSelected ? AppColors.onPrimary : AppColors.inkMuted,
                          weight: isSelected ? 600 : 400,
                          size: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(AsyncValue<List<Task>> tasksAsync, AsyncValue<List<Category>> categoriesAsync) {
    return tasksAsync.when(
      data: (tasks) {
        var filteredTasks = _filterTasksForDay(tasks, _selectedDay);
        if (_tab == CalendarTab.completed) {
          filteredTasks = filteredTasks.where((t) => t.isCompleted).toList();
        } else {
          filteredTasks = filteredTasks.where((t) => !t.isCompleted).toList();
        }
        filteredTasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });

        if (filteredTasks.isEmpty) {
          return _EmptyCalendarState(
            selectedDay: _selectedDay,
            tab: _tab,
            onAddTask: () => _showAddTaskSheet(context, categoriesAsync),
          );
        }

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
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(
        child: Text('Error: $e', style: AppTypography.body(color: AppColors.primary)),
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
      _selectedDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
      _scrollDays = _generateScrollDays(_selectedDay);
    });
    _centerDate(_selectedDay);
  }

  List<Task> _filterTasksForDay(List<Task> tasks, DateTime day) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.isAfter(startOfDay.subtract(const Duration(milliseconds: 1))) &&
          task.dueDate!.isBefore(endOfDay);
    }).toList();
  }

  void _showAddTaskSheet(BuildContext context, AsyncValue<List<Category>> categoriesAsync) {
    AddTaskSheet.show(
      context: context,
      categories: categoriesAsync.value ?? [],
      initialDate: _selectedDay,
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
        try {
          final repo = ref.read(taskRepositoryProvider);
          await repo.deleteTask(task.id);
        } on AppException catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
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

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

enum CalendarTab { today, completed }

extension CalendarTabLabel on CalendarTab {
  String get label => switch (this) {
    CalendarTab.today => 'Today',
    CalendarTab.completed => 'Completed',
  };
}

class _EmptyCalendarState extends StatelessWidget {
  final DateTime selectedDay;
  final CalendarTab tab;
  final VoidCallback onAddTask;

  const _EmptyCalendarState({
    required this.selectedDay,
    required this.tab,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDay(selectedDay, DateTime.now());

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTokens.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/onboarding/home_empty.png',
              height: 150,
              errorBuilder: (_, _, _) => Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryDim,
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                ),
                child: Icon(
                  tab == CalendarTab.completed
                      ? Icons.check_circle_outline_rounded
                      : Icons.calendar_month_rounded,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: AppTokens.xl),
            Text(
              tab == CalendarTab.completed
                  ? 'No completed tasks'
                  : isToday
                      ? 'No tasks for today'
                      : 'No tasks on ${DateFormat('MMM d').format(selectedDay)}',
              style: AppTypography.screenTitle(color: AppColors.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.md),
            Text(
              tab == CalendarTab.completed
                  ? 'Complete some tasks to see them here'
                  : 'Tap + to add a task for this day',
              style: AppTypography.body(color: AppColors.inkMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.xl),
            ElevatedButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text('Add Task', style: AppTypography.buttonLabel()),
            ),
          ],
        ),
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}


