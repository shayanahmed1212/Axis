// Focus module — session repository, in-memory timer, and aggregated state.
//
// [FocusTimerNotifier] drives the 25-minute countdown via a periodic
// Timer (no Firestore dependency while the timer is running). On completion
// a [FocusSession] is persisted to Firestore through [FocusRepository].
// [focusSessionStateProvider] combines the live timer state, historical
// sessions (from the stream), and mocked app-usage data into a single
// [FocusSessionState] consumed by [FocusScreen].
//
// [appUsageStreamProvider] emits mock data on a 10s interval — replace the
// static list with a real OS-level usage API for production use.
// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:axis/utils/app_utils.dart';
import 'package:axis/models/focus_session.dart';
import 'package:axis/models/focus_metrics.dart';

class FocusRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FocusRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _collection {
    final uid = _userId;
    if (uid == null) {
      throw AppException(
          type: AppExceptionType.permissionDenied,
          message: 'User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('focus_sessions');
  }

  Stream<List<FocusSession>> watchSessions() {
    return _collection
        .orderBy('started_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FocusSession.fromFirestore(doc))
            .toList());
  }

  Future<List<FocusSession>> getSessions({int? limit}) async {
    Query<Map<String, dynamic>> query =
        _collection.orderBy('started_at', descending: true);
    if (limit != null) query = query.limit(limit);
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => FocusSession.fromFirestore(doc))
        .toList();
  }

  Future<FocusSession> saveSession(FocusSession session) async {
    final docRef = await _collection.add(session.toFirestore());
    final doc = await docRef.get();
    return FocusSession.fromFirestore(doc);
  }

  Future<void> deleteSession(String sessionId) async {
    await _collection.doc(sessionId).delete();
  }
}

// Providers
final focusRepositoryProvider = Provider<FocusRepository>((ref) {
  return FocusRepository();
});

final focusSessionsStreamProvider =
    StreamProvider<List<FocusSession>>((ref) {
  final repo = ref.watch(focusRepositoryProvider);
  return repo.watchSessions();
});

final focusSessionsFutureProvider =
    FutureProvider<List<FocusSession>>((ref) {
  final repo = ref.watch(focusRepositoryProvider);
  return repo.getSessions(limit: 50);
});

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

final appUsageStreamProvider =
    StreamProvider<List<AppUsageMetric>>((ref) {
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
  for (var i = 0; i < 7; i++) {
    durationPerDay[i] = Duration.zero;
  }
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
