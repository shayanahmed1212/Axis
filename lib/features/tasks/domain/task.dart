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
    required TaskPriority priority,
    DateTime? dueDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Task;

  const Task._();

  static final Task empty = Task(
    id: '',
    title: '',
    description: null,
    isCompleted: false,
    priority: TaskPriority.low,
    dueDate: null,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'priority': priority.name,
      'due_date': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  static Task fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Task(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      isCompleted: data['is_completed'] as bool? ?? false,
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: data['due_date'] != null ? (data['due_date'] as Timestamp).toDate() : null,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  String get priorityDisplay => switch (priority) {
    TaskPriority.low => 'Low',
    TaskPriority.medium => 'Medium',
    TaskPriority.high => 'High',
  };
}
