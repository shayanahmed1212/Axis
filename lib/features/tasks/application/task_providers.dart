import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:axis/features/tasks/domain/task.dart';
import 'package:axis/features/tasks/domain/task_filter.dart';
import 'package:axis/features/tasks/data/task_repository.dart';
import 'package:axis/core/errors/app_exception.dart';
import 'package:axis/core/errors/app_exception_types.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

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

  // Belt-and-suspenders: retry once on a transient permission-denied even
  // if it somehow gets past authReadyProvider, since this specific error
  // is known to be self-healing on retry in this exact scenario.
  int attempts = 0;
  while (true) {
    try {
      yield* repository.watchTasks(filter: filter);
      return;
    } on AppException catch (e) {
      attempts++;
      if (e.type != AppExceptionType.permissionDenied || attempts > 1) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
  }
});

final taskDetailProvider = FutureProvider.family<Task, String>((ref, id) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTaskById(id);
});