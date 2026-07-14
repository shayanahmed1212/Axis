import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    String? displayName,
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
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  static AppUser fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['display_name'] as String?,
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }
}