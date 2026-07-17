// Task data layer — Firestore stream provider + repository.
//
// [taskListProvider] is the primary data source consumed by [HomeScreen]
// and [CalendarScreen]. It waits on [authReadyProvider] to settle the
// Firebase Auth token before opening the Firestore snapshot listener
// (avoiding the common registration-to-read race), then yields the
// filtered task list via [TaskRepository.watchTasks].
//
// [taskFilterProvider] is a write-through StateProvider — changing it
// from either screen immediately triggers a new snapshot query via the
// `filter` argument in [taskListProvider].
// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:axis/models/task.dart';
import 'package:axis/models/task_filter.dart';
import 'package:axis/utils/app_utils.dart';
import 'package:axis/services/notification_service.dart';

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

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return TaskRepository(firestore: firestore, auth: auth);
});

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

/// Waits for a *settled* auth session before anything opens a Firestore
/// listener. Right after registration/login, Firebase Auth's state-change
/// event can fire before the new ID token has fully attached to Firestore's
/// channel — forcing one successful getIdToken() here closes that race,
/// which is what was causing the permission-denied error immediately after
/// a fresh registration.
final authReadyProvider = FutureProvider<String?>((ref) async {
  final auth = ref.watch(firebaseAuthProvider);
  final user = auth.currentUser;
  if (user == null) return null;
  await user.getIdToken(true);
  return user.uid;
});

final taskListProvider = StreamProvider<List<Task>>((ref) async* {
  final uid = await ref.watch(authReadyProvider.future);
  if (uid == null) {
    yield [];
    return;
  }

  final repository = ref.watch(taskRepositoryProvider);
  final filter = ref.watch(taskFilterProvider);

  yield* repository.watchTasks(filter: filter);
});

final taskDetailProvider =
    FutureProvider.family<Task, String>((ref, id) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTaskById(id);
});

/// Unfiltered task stream used by the notification layer so that
/// filter changes on the home screen never cancel active notifications.
final allTasksProvider = StreamProvider<List<Task>>((ref) async* {
  final uid = await ref.watch(authReadyProvider.future);
  if (uid == null) {
    yield [];
    return;
  }
  final repository = ref.watch(taskRepositoryProvider);
  yield* repository.watchTasks();
});

class TaskRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TaskRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _tasksCollection {
    final uid = _userId;
    if (uid == null) {
      throw AppException(
          type: AppExceptionType.permissionDenied,
          message: 'User not authenticated');
    }
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  Future<Task> createTask(Task task) async {
    try {
      final docRef = _tasksCollection.doc();
      final newTask = task.copyWith(id: docRef.id);
      await docRef.set(newTask.toMap());
      try {
        await NotificationService.showTaskNotification(newTask);
      } catch (_) {}
      return newTask;
    } on FirebaseException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Task> getTaskById(String taskId) async {
    return retryFuture(() async {
      try {
        final doc = await _tasksCollection.doc(taskId).get();
        if (!doc.exists) {
          throw AppException(
              type: AppExceptionType.notFound, message: 'Task not found');
        }
        return Task.fromFirestore(doc);
      } on FirebaseException catch (e) {
        throw _mapError(e);
      }
    });
  }

  /// Streams the user's tasks with automatic retry on transient
  /// permission-denied errors (which can fire right after registration
  /// before the Auth token fully syncs to Firestore).
  Stream<List<Task>> watchTasks({TaskFilter? filter}) {
    return retryStream(() {
      Query<Map<String, dynamic>> query =
          _tasksCollection.orderBy('created_at', descending: true);

      if (filter != null) {
        switch (filter) {
          case TaskFilter.active:
            query = query.where('is_completed', isEqualTo: false);
          case TaskFilter.completed:
            query = query.where('is_completed', isEqualTo: true);
          case TaskFilter.all:
            break;
        }
      }

      return query.snapshots().transform(
        StreamTransformer<
            QuerySnapshot<Map<String, dynamic>>,
            List<Task>>.fromHandlers(
          handleData: (snapshot, sink) {
            sink.add(
                snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
          },
          handleError: (error, stackTrace, sink) {
            if (error is FirebaseException) {
              sink.addError(_mapError(error), stackTrace);
            } else {
              sink.addError(error, stackTrace);
            }
          },
        ),
      );
    });
  }

  Future<Task> updateTask(Task task) async {
    try {
      final data = task.toMap()
        ..['updated_at'] = Timestamp.fromDate(DateTime.now());
      await _tasksCollection.doc(task.id).update(data);
      if (task.isCompleted) {
        NotificationService.cancel(task.id);
      } else if (task.dueDate != null) {
        NotificationService.showTaskNotification(task);
      }
      return task;
    } on FirebaseException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
      NotificationService.cancel(taskId);
    } on FirebaseException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      await _tasksCollection.doc(taskId).update({
        'is_completed': isCompleted,
        'updated_at': Timestamp.fromDate(DateTime.now()),
      });
      if (isCompleted) {
        NotificationService.cancel(taskId);
      }
    } on FirebaseException catch (e) {
      throw _mapError(e);
    }
  }

  AppException _mapError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return AppException(
            type: AppExceptionType.permissionDenied,
            message: 'Permission denied');
      case 'not-found':
        return AppException(
            type: AppExceptionType.notFound, message: 'Resource not found');
      case 'unavailable':
        return AppException(
            type: AppExceptionType.networkError,
            message: 'Service unavailable');
      default:
        return AppException(
            type: AppExceptionType.unknown,
            message: e.message ?? 'An error occurred');
    }
  }
}
