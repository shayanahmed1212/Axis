// Focus Widgets — WeeklyFocusChart, ApplicationsSection
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/features/focus/domain/focus_metrics.dart';

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
                        style: AppTypography.meta(
                            size: 10, color: AppColors.inkMuted),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                      final label = hours > 0
                          ? '${hours}h ${mins}m'
                          : '${mins}m';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          label,
                          style: AppTypography.meta(
                            size: 10,
                            color: isToday
                                ? AppColors.primary
                                : AppColors.inkMuted,
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
                      color = Color(0xFFFF5C5C);
                    } else {
                      color = AppColors.inkMuted;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: AppTokens.xs),
                      child: Text(
                        dayLabels[index],
                        style: AppTypography.body(
                          color: color,
                          weight: isToday ? 600 : 400,
                        ),
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
              return FlLine(
                color: AppColors.hairline,
                strokeWidth: 0.5,
              );
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
                  color:
                      isToday ? AppColors.primary : Color(0xFFA5A5A5),
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
        Text('Applications',
            style: AppTypography.sheetTitle(color: AppColors.ink)),
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
                  borderRadius:
                      BorderRadius.circular(AppTokens.radiusSm),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: app.color.withOpacity(0.15),
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusSm),
                      ),
                      child: Icon(app.icon, color: app.color, size: 22),
                    ),
                    const SizedBox(width: AppTokens.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(app.appName,
                              style: AppTypography.body(
                                  weight: 500, color: AppColors.ink)),
                          const SizedBox(height: 2),
                          Text(
                            'You spent ${_formatDuration(app.duration)} on ${app.appName} today',
                            style: AppTypography.meta(
                                color: AppColors.inkMuted),
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
                        icon: Icon(Icons.info_outline_rounded,
                            color: AppColors.inkFaint, size: 18),
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
