// Reusable UI primitives: text fields, press animations, auth banner,
// password field, and focus-screen chart/app-usage components.
//
// [Pressable] wraps any child with a press-scale animation (0.94x on
// touch-down, spring back on release) and optional haptic feedback —
// used throughout the app as a lightweight alternative to [InkWell]
// for non-Material regions.
//
// [WeeklyFocusChart] renders a bar chart (via `fl_chart`) from
// [DailyFocusMetric] data, highlighting today's bar in the accent colour.
// [ApplicationsSection] lists per-app usage durations from the mocked
// [appUsageStreamProvider].
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:axis/theme/app_theme.dart';
import 'package:axis/models/focus_metrics.dart';

// ignore_for_file: prefer_const_constructors

class AppTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? maxLength;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.maxLength,
    this.suffixIcon,
    this.prefixIcon,
    this.focusNode,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label!,
              style: AppTypography.meta(color: AppColors.ink),
            ),
          ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          maxLines: maxLines,
          maxLength: maxLength,
          onFieldSubmitted: onFieldSubmitted,
          style: AppTypography.body(color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.body(color: AppColors.inkMuted),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: AppColors.surfaceCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              borderSide: const BorderSide(color: AppColors.hairline, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              borderSide: const BorderSide(color: AppColors.hairline, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

/// Apple's universal micro-interaction: scale(0.95) on press, spring back on release.
/// Wraps any child to make it feel tappable with consistent press feedback.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final double scale;
  final Duration duration;
  final bool enableHaptic;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.scale = 0.94,
    this.duration = const Duration(milliseconds: AppTokens.durationFast),
    this.enableHaptic = true,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(Pressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scale != widget.scale) {
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: widget.scale,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.enabled) return;
    _controller.forward();
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    _reverse();
  }

  void _onTapCancel() {
    _reverse();
  }

  void _reverse() {
    if (_isPressed) {
      _controller.reverse();
      setState(() => _isPressed = false);
    }
  }

  void _handleTap() {
    if (!widget.enabled) return;
    if (widget.enableHaptic) {
      HapticFeedback.selectionClick();
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap != null ? _handleTap : null,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  final String? message;
  final VoidCallback? onDismiss;

  const AuthErrorBanner({super.key, this.message, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: const EdgeInsets.only(bottom: 17),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message!,
              style: AppTypography.body(color: AppColors.error),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close_rounded, color: AppColors.ink, size: 16),
            ),
        ],
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const PasswordField({super.key, this.controller, this.validator});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Password',
            style: AppTypography.meta(color: AppColors.ink),
          ),
        ),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          validator: widget.validator,
          style: AppTypography.body(color: AppColors.ink),
          decoration: InputDecoration(
            hintText: 'Enter password',
            hintStyle: AppTypography.body(color: AppColors.inkMuted),
            suffixIcon: IconButton(
              icon: Icon(
                _obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AppColors.ink,
                size: 20,
              ),
              onPressed: () => setState(() => _obscured = !_obscured),
            ),
            filled: true,
            fillColor: AppColors.surfaceCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              borderSide: const BorderSide(color: AppColors.hairline, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              borderSide: const BorderSide(color: AppColors.hairline, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Focus Widgets — WeeklyFocusChart, ApplicationsSection
// ═══════════════════════════════════════════════════════════════

class WeeklyFocusChart extends StatelessWidget {
  final List<DailyFocusMetric> metrics;

  const WeeklyFocusChart({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayLabels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final todayIndex = now.weekday % 7;

    final Map<int, int> minutesPerDay = {};
    for (var i = 0; i < 7; i++) {
      final metric = metrics.length > i ? metrics[i] : null;
      minutesPerDay[i] = metric != null ? metric.totalDuration.inMinutes : 0;
    }

    const maxMinutes = 360;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxMinutes.toDouble(),
          minY: 0,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value <= 0) return const SizedBox.shrink();
                  final hours = (value / 60).round();
                  if (hours >= 1 && hours <= 6) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        '${hours}h',
                        style: AppTypography.meta(size: 10, color: AppColors.inkMuted),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < 7) {
                    final minutes = minutesPerDay[index] ?? 0;
                    final isToday = index == todayIndex;
                    if (isToday || minutes > 0) {
                      final hours = minutes ~/ 60;
                      final mins = minutes % 60;
                      final label = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          label,
                          style: AppTypography.meta(
                            size: 10,
                            color: isToday ? AppColors.primary : AppColors.inkMuted,
                            weight: 500,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < 7) {
                    final isToday = index == todayIndex;
                    final isWeekend = index == 0 || index == 6;
                    Color color;
                    if (isToday) {
                      color = AppColors.primary;
                    } else if (isWeekend) {
                      color = const Color(0xFFFF5C5C);
                    } else {
                      color = AppColors.inkMuted;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: AppTokens.xs),
                      child: Text(
                        dayLabels[index],
                        style: AppTypography.body(color: color, weight: isToday ? 600 : 400),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 60,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: AppColors.hairline, strokeWidth: 0.5);
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            final minutes = minutesPerDay[index] ?? 0;
            final isToday = index == todayIndex;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: minutes.toDouble(),
                  width: 24,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  color: isToday ? AppColors.primary : const Color(0xFFA5A5A5),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class ApplicationsSection extends StatelessWidget {
  final List<AppUsageMetric> apps;

  const ApplicationsSection({super.key, required this.apps});

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      final mins = d.inMinutes % 60;
      return mins > 0 ? '${d.inHours}h ${mins}m' : '${d.inHours}h';
    }
    return '${d.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Applications', style: AppTypography.sheetTitle(color: AppColors.ink)),
        const SizedBox(height: AppTokens.md),
        if (apps.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTokens.lg),
            child: Center(
              child: Text(
                'No application data available',
                style: AppTypography.body(color: AppColors.inkMuted),
              ),
            ),
          )
        else
          ...List.generate(apps.length, (index) {
            final app = apps[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.sm),
              child: Container(
                padding: const EdgeInsets.all(AppTokens.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCharcoal,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: app.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      ),
                      child: Icon(app.icon, color: app.color, size: 22),
                    ),
                    const SizedBox(width: AppTokens.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(app.appName, style: AppTypography.body(weight: 500, color: AppColors.ink)),
                          const SizedBox(height: 2),
                          Text(
                            'You spent ${_formatDuration(app.duration)} on ${app.appName} today',
                            style: AppTypography.meta(color: AppColors.inkMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.hairline,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        icon: Icon(Icons.info_outline_rounded, color: AppColors.inkFaint, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
