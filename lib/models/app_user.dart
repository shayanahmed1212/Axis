// Firestore-synced user profile. The [authStateProvider] in auth_service.dart
// emits an [AppUser]? stream so downstream providers like [taskListProvider]
// know the current user's uid before opening Firestore listeners.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    String? displayName,
    String? photoURL,
    required DateTime createdAt,
  }) = _AppUser;

  const AppUser._();

  static final AppUser empty = AppUser(
    id: '',
    email: '',
    displayName: null,
    createdAt: DateTime(2024),
  );

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'display_name': displayName,
      'photo_url': photoURL,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  static AppUser fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['display_name'] as String?,
      photoURL: data['photo_url'] as String?,
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }
}
