// Focus Screen — Pomodoro timer + weekly chart + app usage list
// ignore_for_file: unnecessary_brace_in_string_interps, prefer_const_constructors

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/widgets/bottom_nav_bar.dart';
import 'package:axis/core/errors/app_exception.dart';
import 'package:axis/features/focus/application/focus_providers.dart';
import 'package:axis/features/focus/data/focus_repository.dart';
import 'package:axis/features/focus/domain/focus_session.dart';
import 'package:axis/features/tasks/application/task_providers.dart';
import 'package:axis/features/tasks/presentation/screens/add_task_sheet.dart';
import 'package:axis/features/focus/presentation/widgets/focus_widgets.dart';

class _TimerProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _TimerProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 6;
    const strokeWidth = 5.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TimerProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  void _saveSession(int completedSeconds) async {
    if (completedSeconds > 0) {
      final repo = ref.read(focusRepositoryProvider);
      await repo.saveSession(FocusSession(
        id: '',
        startedAt:
            DateTime.now().subtract(Duration(seconds: completedSeconds)),
        durationSeconds: completedSeconds,
        userId: '',
        createdAt: DateTime.now(),
      ));
    }
  }

  void _showCompletionDialog(int seconds) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusLg)),
        title: Text('Focus Complete!',
            style: AppTypography.sheetTitle(color: AppColors.ink)),
        content: Text(
          'Great job! You focused for ${_formatTime(seconds)}.',
          style: AppTypography.body(color: AppColors.ink),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done', style: AppTypography.buttonLabel()),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(focusTimerProvider, (prev, next) {
      if (prev != null &&
          prev.isFocusing &&
          !next.isFocusing &&
          prev.elapsedSeconds >= prev.totalSeconds) {
        final completed = prev.totalSeconds;
        _saveSession(completed);
        _showCompletionDialog(completed);
      }
    });

    final timerState = ref.watch(focusTimerProvider);
    final sessionState = ref.watch(focusSessionStateProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        title: Text('Focus Mode',
            style: AppTypography.screenTitle(color: AppColors.ink)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.pageMargin),
        child: Column(
          children: [
            SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(280, 280),
                    painter: _TimerProgressPainter(
                      progress: timerState.progress,
                      trackColor: AppColors.surfaceCharcoal,
                      progressColor: AppColors.primary,
                    ),
                  ),
                  Text(
                    timerState.formattedTime,
                    style: AppTypography.cardTitle(
                        size: 56, weight: 700, color: AppColors.ink),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: timerState.isFocusing
                    ? () =>
                        ref.read(focusTimerProvider.notifier).stop()
                    : () =>
                        ref.read(focusTimerProvider.notifier).start(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                      vertical: AppTokens.md),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusSm)),
                ),
                child: Text(
                  timerState.isFocusing
                      ? 'Stop Focusing'
                      : 'Start Focusing',
                  style: AppTypography.buttonLabel(
                      color: AppColors.onPrimary),
                ),
              ),
            ),
            const SizedBox(height: AppTokens.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Overview',
                    style:
                        AppTypography.sheetTitle(color: AppColors.ink)),
                Row(
                  children: [
                    Text('This Week',
                        style: AppTypography.body(
                            color: AppColors.ink, weight: 500)),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.inkMuted, size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTokens.md),
            WeeklyFocusChart(
                metrics: sessionState.weeklyOverview),
            const SizedBox(height: AppTokens.xxl),
            ApplicationsSection(
                apps: sessionState.monitoredApps),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/calendar'); break;
            case 2: break;
            case 3: context.go('/profile'); break;
          }
        },
        onFabTap: () => AddTaskSheet.show(
          context: context,
          categories: const [],
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
        ),
      ),
    );
  }
}


