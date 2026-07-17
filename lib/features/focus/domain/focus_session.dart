// Focus Session model — Firestore-backed focus timer sessions
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'focus_session.freezed.dart';

@freezed
abstract class FocusSession with _$FocusSession {
  const factory FocusSession({
    required String id,
    required DateTime startedAt,
    required int durationSeconds,
    required String userId,
    required DateTime createdAt,
  }) = _FocusSession;

  const FocusSession._();

  factory FocusSession.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FocusSession(
      id: doc.id,
      startedAt: (data['started_at'] as Timestamp).toDate(),
      durationSeconds: data['duration_seconds'] as int,
      userId: data['user_id'] as String,
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'started_at': Timestamp.fromDate(startedAt),
      'duration_seconds': durationSeconds,
      'user_id': userId,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}

enum FocusState { idle, running, paused, completed }