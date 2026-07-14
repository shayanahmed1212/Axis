import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:axis/features/tasks/domain/task.dart';
import 'package:axis/features/tasks/domain/task_filter.dart';
import 'package:axis/features/tasks/data/task_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return TaskRepository(firestore: firestore, auth: auth);
});

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

final taskListProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  final filter = ref.watch(taskFilterProvider);
  return repository.watchTasks(filter: filter);
});

final taskDetailProvider = FutureProvider.family<Task, String>((ref, id) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTaskById(id);
});