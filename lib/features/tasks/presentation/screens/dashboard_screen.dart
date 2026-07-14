// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/widgets/floating_bottom_nav.dart';
import 'package:axis/core/widgets/hero_greeting_card.dart';
import 'package:axis/core/widgets/bento_stat_card.dart';
import 'package:axis/core/widgets/task_ribbon_card.dart';
import 'package:axis/core/widgets/segmented_filter.dart';
import 'package:axis/core/widgets/app_snackbar.dart';
import 'package:axis/features/tasks/application/task_providers.dart';
import 'package:axis/features/tasks/application/task_controller.dart';
import 'package:axis/features/tasks/domain/task.dart';
import 'package:axis/features/tasks/domain/task_priority.dart';
import 'package:axis/features/tasks/domain/task_filter.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with TickerProviderStateMixin {
  TaskFilter _filter = TaskFilter.all;
  late final AnimationController _staggerController;
  late final Animation<double> _staggerAnimation;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _staggerAnimation = CurvedAnimation(
      parent: _staggerController,
      curve: Curves.easeOut,
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListProvider);
    final controller = ref.read(taskControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (tasks) => _buildContent(tasks, controller),
        ),
      ),
      bottomNavigationBar: FloatingBottomNav(
        currentTab: NavTab.home,
        onTabChanged: (tab) {
          if (tab == NavTab.profile) context.go('/profile');
        },
        onCreateTask: () => context.push('/task/new'),
      ),
    );
  }

  Widget _buildContent(List<Task> tasks, TaskController controller) {
    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final pending = tasks.where((t) => !t.isCompleted).length;
    final highPriority = tasks.where((t) => !t.isCompleted && t.priority == TaskPriority.high).length;
    final todayCount = tasks.where((t) => !t.isCompleted).length;

    final filteredTasks = switch (_filter) {
      TaskFilter.all => tasks,
      TaskFilter.active => tasks.where((t) => !t.isCompleted).toList(),
      TaskFilter.completed => tasks.where((t) => t.isCompleted).toList(),
    };

    final greeting = _getGreeting();

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppTokens.pageMargin, 12, AppTokens.pageMargin, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Axis', style: AppTypography.display(size: 22, weight: 700, color: AppColors.ink)),
                GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.accent,
                    child: Text('A', style: TextStyle(color: AppColors.accentInk, fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Hero greeting
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppTokens.pageMargin, 16, AppTokens.pageMargin, 0),
            child: HeroGreetingCard(
              greeting: greeting,
              summary: 'You have $todayCount tasks for today',
              taskCount: todayCount,
            ),
          ),
        ),

        // Stat grid with stagger
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppTokens.pageMargin, AppTokens.bentoGap, AppTokens.pageMargin, 0),
            child: AnimatedBuilder(
              animation: _staggerAnimation,
              builder: (context, _) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _StaggeredCard(index: 0, animation: _staggerAnimation, child: BentoStatCard(label: 'Total', value: '$total', backgroundColor: AppColors.blockSky, textColor: AppColors.blockSkyText, shadow: AppTokens.shadowSky))),
                        const SizedBox(width: AppTokens.bentoGap),
                        Expanded(child: _StaggeredCard(index: 1, animation: _staggerAnimation, child: BentoStatCard(label: 'Done', value: '$completed', backgroundColor: AppColors.blockSage, textColor: AppColors.blockSageText, shadow: AppTokens.shadowSage))),
                      ],
                    ),
                    const SizedBox(height: AppTokens.bentoGap),
                    Row(
                      children: [
                        Expanded(child: _StaggeredCard(index: 2, animation: _staggerAnimation, child: BentoStatCard(label: 'Pending', value: '$pending', backgroundColor: AppColors.blockPeach, textColor: AppColors.blockPeachText, shadow: AppTokens.shadowPeach))),
                        const SizedBox(width: AppTokens.bentoGap),
                        Expanded(child: _StaggeredCard(index: 3, animation: _staggerAnimation, child: BentoStatCard(label: 'Urgent', value: '$highPriority', backgroundColor: AppColors.blockCoral, textColor: AppColors.blockCoralText, shadow: AppTokens.shadowCoral))),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        // Section header + filter
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppTokens.pageMargin, 24, AppTokens.pageMargin, 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your Tasks', style: AppTypography.body(size: AppTypography.sectionHeaderSize, weight: AppTypography.sectionHeaderWeight, color: AppColors.ink)),
                    Text('${filteredTasks.length} tasks', style: AppTypography.body(size: AppTypography.captionSize, weight: AppTypography.captionWeight, color: AppColors.inkMuted)),
                  ],
                ),
                const SizedBox(height: 12),
                SegmentedFilter(currentFilter: _filter, onChanged: (f) => setState(() => _filter = f)),
              ],
            ),
          ),
        ),

        // Task list or empty state
        if (filteredTasks.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.pageMargin),
              child: _EmptyState(filter: _filter),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.pageMargin),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = filteredTasks[index];
                  return TaskRibbonCard(
                    task: task,
                    onTap: () => context.push('/task/${task.id}'),
                    onToggleComplete: (completed) async {
                      try {
                        await controller.toggleCompletion(task);
                      } catch (e) {
                        if (!mounted) return;
                        AppSnackbar.show(context, 'Failed to update task', type: SnackBarType.error);
                      }
                    },
                  );
                },
                childCount: filteredTasks.length,
              ),
            ),
          ),

        // Bottom padding for nav bar
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _EmptyState extends StatelessWidget {
  final TaskFilter filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.blockLavender,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_task_rounded, size: 36, color: AppColors.blockLavenderText),
          ),
          const SizedBox(height: 20),
          Text('No tasks yet', style: AppTypography.body(size: 16, weight: 600, color: AppColors.ink)),
          const SizedBox(height: 8),
          Text('Tap the + below to add one', style: AppTypography.body(size: 13, weight: 400, color: AppColors.inkMuted)),
        ],
      ),
    );
  }
}

class _StaggeredCard extends StatelessWidget {
  final int index;
  final Animation<double> animation;
  final Widget child;

  const _StaggeredCard({
    required this.index,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = index * 0.15;
    final end = start + 0.4;
    final interval = Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutBack);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value = interval.transform(animation.value.clamp(0.0, 1.0));
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }
}
