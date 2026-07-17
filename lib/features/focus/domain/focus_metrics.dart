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
