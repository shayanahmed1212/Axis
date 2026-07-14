// Authentication repository for Firebase operations
// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:axis/features/auth/domain/app_user.dart';
import 'package:axis/core/utils/error_mapper.dart';
import 'package:axis/core/errors/app_exception.dart';
import 'package:axis/core/errors/app_exception_types.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw AppException(type: AppExceptionType.unknown, message: 'Failed to sign in');
      }
      return await _getUserProfile(uid);
    } on FirebaseAuthException catch (e) {
      throw AppExceptionMapper.mapFirebaseAuthError(e);
    } on FirebaseException catch (e) {
      throw AppExceptionMapper.mapFirestoreError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
        type: AppExceptionType.unknown,
        message: 'An unexpected error occurred during sign in',
      );
    }
  }

  Future<AppUser> registerWithEmailAndPassword(String email, String password, {String? displayName}) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw AppException(type: AppExceptionType.unknown, message: 'Failed to register user');
      }

      final user = AppUser(
        id: uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );
      await _saveUserProfile(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw AppExceptionMapper.mapFirebaseAuthError(e);
    } on FirebaseException catch (e) {
      throw AppExceptionMapper.mapFirestoreError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
        type: AppExceptionType.unknown,
        message: 'An unexpected error occurred during registration',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AppExceptionMapper.mapFirebaseAuthError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
        type: AppExceptionType.unknown,
        message: 'An unexpected error occurred during sign out',
      );
    }
  }

  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await _getUserProfile(user.uid);
    });
  }

  Future<AppUser> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw AppException(type: AppExceptionType.userNotFound, message: 'No user is currently signed in');
    }
    return await _getUserProfile(firebaseUser.uid);
  }

  Future<AppUser> _getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        return AppUser(
          id: uid,
          email: _auth.currentUser?.email ?? '',
          displayName: _auth.currentUser?.displayName,
          createdAt: DateTime.now(),
        );
      }
      return AppUser.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw AppExceptionMapper.mapFirestoreError(e);
    }
  }

  Future<void> _saveUserProfile(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'email': user.email,
        'display_name': user.displayName,
        'created_at': Timestamp.fromDate(user.createdAt),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw AppExceptionMapper.mapFirestoreError(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AppExceptionMapper.mapFirebaseAuthError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
        type: AppExceptionType.unknown,
        message: 'An unexpected error occurred during password reset',
      );
    }
  }

  Future<AppException?> getAuthError(FirebaseAuthException error) async {
    return AppExceptionMapper.mapFirebaseAuthError(error);
  }
}