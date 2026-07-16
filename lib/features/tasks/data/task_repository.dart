// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:axis/features/tasks/domain/task.dart';
import 'package:axis/features/tasks/domain/task_filter.dart';
import 'package:axis/core/errors/app_exception.dart';
import 'package:axis/core/errors/app_exception_types.dart';

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
      throw AppException(type: AppExceptionType.permissionDenied, message: 'User not authenticated');
    }
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  Future<Task> createTask(Task task) async {
    try {
      final docRef = _tasksCollection.doc();
      final newTask = task.copyWith(id: docRef.id);
      await docRef.set(newTask.toMap());
      return newTask;
    } on FirebaseException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Task> getTaskById(String taskId) async {
    try {
      final doc = await _tasksCollection.doc(taskId).get();
      if (!doc.exists) {
        throw AppException(type: AppExceptionType.notFound, message: 'Task not found');
      }
      return Task.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw _mapError(e);
    }
  }

  /// Streams the user's tasks. Any FirebaseException from the underlying
  /// snapshot stream (e.g. a transient permission-denied right after
  /// registration/login) is now mapped to a typed AppException before it
  /// reaches the UI, instead of leaking the raw Firebase error object.
  Stream<List<Task>> watchTasks({TaskFilter? filter}) {
    Query<Map<String, dynamic>> query = _tasksCollection.orderBy('created_at', descending: true);

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
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>, List<Task>>.fromHandlers(
        handleData: (snapshot, sink) {
          sink.add(snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
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
  }

  Future<Task> updateTask(Task task) async {
    try {
      final data = task.toMap()..['updated_at'] = Timestamp.fromDate(DateTime.now());
      await _tasksCollection.doc(task.id).update(data);
      return task;
    } on FirebaseException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
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
    } on FirebaseException catch (e) {
      throw _mapError(e);
    }
  }

  AppException _mapError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return AppException(type: AppExceptionType.permissionDenied, message: 'Permission denied');
      case 'not-found':
        return AppException(type: AppExceptionType.notFound, message: 'Resource not found');
      case 'unavailable':
        return AppException(type: AppExceptionType.networkError, message: 'Service unavailable');
      default:
        return AppException(type: AppExceptionType.unknown, message: e.message ?? 'An error occurred');
    }
  }
}