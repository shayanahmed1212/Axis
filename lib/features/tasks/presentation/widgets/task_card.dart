// ignore_for_file: prefer_const_constructors

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/features/tasks/domain/task.dart';
import 'package:axis/features/tasks/domain/task_priority.dart';

/// Custom painter for the calibration stroke — the golden arc that sweeps
/// clockwise like a precision dial finding its mark.
class _CalibrationPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CalibrationPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 1;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background circle — the empty dial face
    final bgPaint = Paint()
      ..color = AppColors.hairlineStrong
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, bgPaint);

    // Golden calibration stroke — sweeps clockwise
    if (progress > 0) {
      final arcPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: math.pi * 1.5,
          colors: [color, color],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress.clamp(0.0, 1.0),
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CalibrationPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggleComplete;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    this.onDelete,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sweepAnimation;
  bool _previousCompleted = false;

  @override
  void initState() {
    super.initState();
    _previousCompleted = widget.task.isCompleted;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppTokens.durationCompletion + AppTokens.durationHold + AppTokens.durationSettle),
    );
    _sweepAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.55, curve: Curves.easeOut), // sweep phase
      ),
    );

    if (widget.task.isCompleted) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.isCompleted != _previousCompleted) {
      _previousCompleted = widget.task.isCompleted;
      if (widget.task.isCompleted) {
        _controller.forward(from: 0);
      } else {
        _controller.reverse(from: 1);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _priorityColor() {
    return switch (widget.task.priority) {
      TaskPriority.low => AppColors.success,
      TaskPriority.medium => AppColors.primary,
      TaskPriority.high => AppColors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.onPrimary),
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: AppTokens.durationNormal),
          padding: const EdgeInsets.all(AppTokens.md),
          decoration: BoxDecoration(
            color: AppColors.surface1,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: AppColors.hairline, width: 1),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => widget.onToggleComplete(!task.isCompleted),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(24, 24),
                      painter: _CalibrationPainter(
                        progress: _sweepAnimation.value,
                        color: AppColors.accent,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: AppTokens.durationNormal),
                            style: GoogleFonts.getFont(
                              AppTypography.displayFamily,
                              fontSize: AppTypography.cardTitleSize,
                              fontWeight: FontWeight(AppTypography.cardTitleWeight),
                              color: task.isCompleted ? AppColors.inkSubtle : AppColors.ink,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              decorationColor: AppColors.inkSubtle,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            child: Text(task.title),
                          ),
                        ),
                      ],
                    ),
                    if (task.description != null && task.description!.isNotEmpty) ...[
                      const SizedBox(height: AppTokens.xxs),
                      Text(
                        task.description!,
                        style: GoogleFonts.getFont(
                          AppTypography.bodyFamily,
                          fontSize: AppTypography.bodySmSize,
                          fontWeight: FontWeight(AppTypography.bodySmWeight),
                          color: AppColors.inkSubtle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppTokens.xs),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppTokens.xs, vertical: 2),
                          decoration: BoxDecoration(
                            color: _priorityColor().withOpacity(0.15),
                            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                          ),
                          child: Text(
                            task.priorityDisplay,
                            style: GoogleFonts.getFont(
                              AppTypography.bodyFamily,
                              fontSize: AppTypography.captionSize,
                              fontWeight: FontWeight(AppTypography.captionWeight),
                              letterSpacing: AppTypography.captionLetterSpacing,
                              color: _priorityColor(),
                            ),
                          ),
                        ),
                        if (task.dueDate != null) ...[
                          const SizedBox(width: AppTokens.xs),
                          Icon(Icons.schedule, size: 12, color: AppColors.inkSubtle),
                          const SizedBox(width: AppTokens.xxs),
                          Text(
                            '${task.dueDate!.month}/${task.dueDate!.day}',
                            style: GoogleFonts.getFont(
                              AppTypography.bodyFamily,
                              fontSize: AppTypography.captionSize,
                              fontWeight: FontWeight(AppTypography.captionWeight),
                              color: AppColors.inkSubtle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
