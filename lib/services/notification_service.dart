// Persistent (ongoing) local notification engine for task reminders.
// Uses [flutter_local_notifications] with an Android channel configured
// with [ongoing: true] and [autoCancel: false] so the notification stays
// in the shade and cannot be swiped away until the task is completed.
// Past-due tasks are visually promoted with a red accent and a warning
// prefix in the title.
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:axis/utils/app_utils.dart';
import 'package:axis/models/task.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(settings);
      _initialized = true;
    } catch (e) {
      // Logged but intentionally swallowed — the app should still boot.
    }
  }

  /// Shows or updates a persistent notification for [task].
  ///
  /// If the task has a due date that has already passed and is not
  /// completed, the notification body changes to "PAST DUE" and the
  /// title is prefixed with a warning icon. The notification ID is
  /// derived from the task's string ID so re-calling with the same
  /// task simply updates the existing notification.
  static Future<void> showTaskNotification(Task task) async {
    if (!_initialized) return;
    if (task.id.isEmpty) return;

    final id = task.id.hashCode & 0x7FFFFFFF;
    final now = DateTime.now();
    final dueDate = task.dueDate;
    final isPastDue =
        dueDate != null && dueDate.isBefore(now) && !task.isCompleted;

    final androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Persistent reminders for your scheduled tasks',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      playSound: true,
      enableVibration: true,
      color: isPastDue ? const Color(0xFFFF5C5C) : null,
      subText: isPastDue ? 'PAST DUE' : null,
    );

    final title = isPastDue ? '⚠️ PAST DUE: ${task.title}' : task.title;
    final body = () {
      if (isPastDue) return 'This task was supposed to be done at ${_formatDateTime(dueDate)}!';
      if (dueDate == null) return 'Tap to view details';
      return '🕒 Scheduled for: ${_formatDateTime(dueDate)}';
    }();

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }

  /// Cancels the persistent notification associated with [taskId].
  static Future<void> cancel(String taskId) async {
    if (!_initialized) return;
    final id = taskId.hashCode & 0x7FFFFFFF;
    await _plugin.cancel(id);
  }

  static String _formatDateTime(DateTime? date) {
    if (date == null) return 'No deadline';
    return '${DateFormatter.formatDate(date)} at ${DateFormatter.formatTime(date)}';
  }
}
