import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/task.dart';
import '../domain/task_filter.dart';
import 'task_providers.dart';

class TaskController {
  final Ref _ref;

  TaskController(this._ref);

  Future<void> createTask({
    required String title,
    String? description,
    int priority = 5,
    DateTime? dueDate,
  }) async {
    final repository = _ref.read(taskRepositoryProvider);
    final task = Task(
      id: '',
      title: title,
      description: description,
      isCompleted: false,
      priority: priority,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await repository.createTask(task);
  }

  Future<void> updateTask(Task task) async {
    final repository = _ref.read(taskRepositoryProvider);
    await repository.updateTask(task.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> toggleCompletion(Task task) async {
    final repository = _ref.read(taskRepositoryProvider);
    await repository.toggleTaskCompletion(task.id, !task.isCompleted);
  }

  Future<void> deleteTask(String taskId) async {
    final repository = _ref.read(taskRepositoryProvider);
    await repository.deleteTask(taskId);
  }

  void setFilter(TaskFilter filter) {
    _ref.read(taskFilterProvider.notifier).state = filter;
  }
}

final taskControllerProvider = Provider<TaskController>((ref) {
  return TaskController(ref);
});
