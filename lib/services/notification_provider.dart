// Riverpod provider that watches the unfiltered task stream and
// synchronises persistent notifications with the current task set.
// New or updated tasks with a due date trigger [NotificationService.showTaskNotification],
// completed tasks and removed (deleted) tasks trigger [NotificationService.cancel].
// A 60-second periodic timer refreshes past-due notifications.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:axis/services/task_service.dart';
import 'package:axis/services/notification_service.dart';
import 'package:axis/models/task.dart';

final taskNotificationProvider = Provider<TaskNotificationManager>((ref) {
  final manager = TaskNotificationManager();

  ref.listen(allTasksProvider, (prev, next) {
    next.whenData((tasks) => manager.sync(tasks));
  });

  ref.onDispose(() => manager.dispose());

  return manager;
});

class TaskNotificationManager {
  Set<String> _previousIds = {};
  Timer? _pastDueTimer;

  /// Called on every emission of [allTasksProvider].
  ///
  /// - Active tasks with a due date → show/update persistent notification.
  /// - Completed tasks              → cancel notification.
  /// - Tasks removed from the list (deleted) → cancel notification.
  void sync(List<Task> tasks) {
    final currentIds = tasks.map((t) => t.id).toSet();

    for (final task in tasks) {
      if (task.isCompleted) {
        NotificationService.cancel(task.id);
      } else if (task.dueDate != null) {
        NotificationService.showTaskNotification(task);
      }
    }

    // Cancel notifications for deleted tasks
    for (final id in _previousIds) {
      if (!currentIds.contains(id)) {
        NotificationService.cancel(id);
      }
    }

    _previousIds = currentIds;
    _startPastDueTimer(tasks);
  }

  /// Every 60 seconds, refresh notifications for past-due tasks so the
  /// body/title switches to the "PAST DUE" state as soon as the deadline
  /// elapses while the app is running.
  void _startPastDueTimer(List<Task> tasks) {
    _pastDueTimer?.cancel();
    _pastDueTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      for (final task in tasks) {
        final dueDate = task.dueDate;
        if (dueDate != null && dueDate.isBefore(DateTime.now()) && !task.isCompleted) {
          NotificationService.showTaskNotification(task);
        }
      }
    });
  }

  void dispose() {
    _pastDueTimer?.cancel();
  }
}
