// Task model — Updated with category, priority 1-10, subtasks, reminder
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'task_priority.dart';

part 'task.freezed.dart';

@freezed
abstract class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    String? description,
    required bool isCompleted,
    @Default(5) int priority, // 1-10 scale
    String? categoryId,
    DateTime? dueDate,
    DateTime? reminderAt,
    @Default([]) List<SubTask> subtasks,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Task;

  const Task._();

  static final Task empty = Task(
    id: '',
    title: '',
    description: null,
    isCompleted: false,
    priority: 5,
    categoryId: null,
    dueDate: null,
    reminderAt: null,
    subtasks: [],
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'priority': priority,
      'category_id': categoryId,
      'due_date': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'reminder_at': reminderAt != null ? Timestamp.fromDate(reminderAt!) : null,
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Task(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      isCompleted: data['is_completed'] as bool? ?? false,
      priority: data['priority'] is String
          ? int.tryParse(data['priority'] as String) ?? 5
          : data['priority'] as int? ?? 5,
      categoryId: data['category_id'] as String?,
      dueDate: data['due_date'] != null ? (data['due_date'] as Timestamp).toDate() : null,
      reminderAt: data['reminder_at'] != null ? (data['reminder_at'] as Timestamp).toDate() : null,
      subtasks: (data['subtasks'] as List<dynamic>?)
              ?.map((e) => SubTask.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  TaskPriority get priorityEnum => TaskPriority.fromInt(priority);

  int get completedSubtasksCount => subtasks.where((s) => s.isCompleted).length;
  int get totalSubtasksCount => subtasks.length;
  double get subtaskProgress => totalSubtasksCount > 0 ? completedSubtasksCount / totalSubtasksCount : 0.0;
}

@freezed
abstract class SubTask with _$SubTask {
  const factory SubTask({
    required String id,
    required String title,
    required bool isCompleted,
  }) = _SubTask;

  const SubTask._();

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      isCompleted: map['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted,
    };
  }
}