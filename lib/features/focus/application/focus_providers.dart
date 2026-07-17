import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:axis/features/focus/data/focus_repository.dart';
import 'package:axis/features/focus/domain/focus_metrics.dart';

// ── Timer State ──

class FocusTimerState {
  final bool isFocusing;
  final int elapsedSeconds;
  final int totalSeconds;

  const FocusTimerState({
    required this.isFocusing,
    required this.elapsedSeconds,
    required this.totalSeconds,
  });

  double get progress =>
      totalSeconds > 0 ? elapsedSeconds / totalSeconds : 0.0;
  int get remainingSeconds => totalSeconds - elapsedSeconds;

  String get formattedTime {
    final secs = isFocusing ? remainingSeconds : 0;
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static const idle = FocusTimerState(
    isFocusing: false,
    elapsedSeconds: 0,
    totalSeconds: 0,
  );
}

class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  Timer? _timer;

  FocusTimerNotifier() : super(FocusTimerState.idle);

  void start() {
    _timer?.cancel();
    state = const FocusTimerState(
      isFocusing: true,
      elapsedSeconds: 0,
      totalSeconds: 1500,
    );
    _tick();
  }

  void _tick() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final newElapsed = state.elapsedSeconds + 1;
      if (newElapsed >= state.totalSeconds) {
        _complete();
        return;
      }
      state = FocusTimerState(
        isFocusing: true,
        elapsedSeconds: newElapsed,
        totalSeconds: state.totalSeconds,
      );
    });
  }

  void stop() {
    _timer?.cancel();
    state = FocusTimerState.idle;
  }

  void _complete() {
    _timer?.cancel();
    state = FocusTimerState.idle;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusTimerProvider =
    StateNotifierProvider<FocusTimerNotifier, FocusTimerState>((ref) {
  return FocusTimerNotifier();
});

// ── App Usage Stream (mock, replace with real OS tracking) ──

final appUsageStreamProvider = StreamProvider<List<AppUsageMetric>>((ref) {
  return Stream.periodic(const Duration(seconds: 10), (_) {
    final h = DateTime.now().hour;
    return [
      AppUsageMetric(
        appName: 'Instagram',
        icon: Icons.photo_camera_rounded,
        color: const Color(0xFFE1306C),
        duration: Duration(hours: 4, minutes: (h * 3) % 60),
      ),
      AppUsageMetric(
        appName: 'Twitter',
        icon: Icons.alternate_email_rounded,
        color: const Color(0xFF1DA1F2),
        duration: Duration(hours: 2, minutes: (h * 5) % 60),
      ),
      AppUsageMetric(
        appName: 'Facebook',
        icon: Icons.groups_rounded,
        color: const Color(0xFF1877F2),
        duration: Duration(hours: 1, minutes: 30 + (h % 20)),
      ),
      AppUsageMetric(
        appName: 'Telegram',
        icon: Icons.send_rounded,
        color: const Color(0xFF0088CC),
        duration: Duration(minutes: 45 + (h % 15)),
      ),
      AppUsageMetric(
        appName: 'Gmail',
        icon: Icons.email_rounded,
        color: const Color(0xFFEA4335),
        duration: Duration(minutes: 30 + (h % 10)),
      ),
    ];
  });
});

// ── Unified Session State ──

class FocusSessionState {
  final bool isFocusing;
  final Duration elapsedDuration;
  final List<DailyFocusMetric> weeklyOverview;
  final List<AppUsageMetric> monitoredApps;

  const FocusSessionState({
    required this.isFocusing,
    required this.elapsedDuration,
    required this.weeklyOverview,
    required this.monitoredApps,
  });
}

final focusSessionStateProvider = Provider<FocusSessionState>((ref) {
  final timerState = ref.watch(focusTimerProvider);
  final sessions =
      ref.watch(focusSessionsStreamProvider).valueOrNull ?? [];
  final appUsage =
      ref.watch(appUsageStreamProvider).valueOrNull ?? [];

  final now = DateTime.now();
  final Map<int, Duration> durationPerDay = {};
  for (var i = 0; i < 7; i++) { durationPerDay[i] = Duration.zero; }
  for (final session in sessions) {
    final dayIndex = session.startedAt.weekday % 7;
    durationPerDay[dayIndex] = durationPerDay[dayIndex]! +
        Duration(seconds: session.durationSeconds);
  }
  final weeklyMetrics = List.generate(
    7,
    (i) => DailyFocusMetric(
        dayIndex: i, totalDuration: durationPerDay[i]!),
  );

  final sortedApps = List<AppUsageMetric>.from(appUsage)
    ..sort((a, b) => b.duration.compareTo(a.duration));

  return FocusSessionState(
    isFocusing: timerState.isFocusing,
    elapsedDuration: Duration(seconds: timerState.elapsedSeconds),
    weeklyOverview: weeklyMetrics,
    monitoredApps: sortedApps,
  );
});
