// Focus Repository — Firestore CRUD for focus sessions
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:axis/core/errors/app_exception.dart';
import 'package:axis/core/errors/app_exception_types.dart';
import 'package:axis/features/focus/domain/focus_session.dart';

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
      throw AppException(type: AppExceptionType.permissionDenied, message: 'User not authenticated');
    }
    return _firestore.collection('users').doc(uid).collection('focus_sessions');
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
    Query<Map<String, dynamic>> query = _collection.orderBy('started_at', descending: true);
    if (limit != null) query = query.limit(limit);
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => FocusSession.fromFirestore(doc)).toList();
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

final focusSessionsStreamProvider = StreamProvider<List<FocusSession>>((ref) {
  final repo = ref.watch(focusRepositoryProvider);
  return repo.watchSessions();
});

final focusSessionsFutureProvider = FutureProvider<List<FocusSession>>((ref) {
  final repo = ref.watch(focusRepositoryProvider);
  return repo.getSessions(limit: 50);
});