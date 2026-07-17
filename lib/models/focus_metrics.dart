// Data-classes for the focus screen's analytics section.
// [DailyFocusMetric] aggregates session durations per weekday (index 0-6)
// and feeds the bar chart in [WeeklyFocusChart]. [AppUsageMetric] holds
// mocked per-app usage data from the stream in [focus_service.dart].
import 'package:flutter/material.dart';

class DailyFocusMetric {
  final int dayIndex;
  final Duration totalDuration;

  const DailyFocusMetric({
    required this.dayIndex,
    required this.totalDuration,
  });
}

class AppUsageMetric {
  final String appName;
  final IconData icon;
  final Color color;
  final Duration duration;

  const AppUsageMetric({
    required this.appName,
    required this.icon,
    required this.color,
    required this.duration,
  });
}
