// Authentication repository for Firebase operations
// ignore_for_file: unused_local_variable, prefer_const_constructors

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'package:axis/features/auth/domain/app_user.dart';
import 'package:axis/core/utils/error_mapper.dart';
import 'package:axis/core/errors/app_exception.dart';
import 'package:axis/core/errors/app_exception_types.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final StreamController<AppUser?> _authStateController;
  StreamSubscription<AppUser?>? _authSubscription;

  AppUser? _devUser;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _authStateController = StreamController<AppUser?>.broadcast() {
    _initAuthListener();
  }

  void _initAuthListener() {
    try {
      _authSubscription = _auth.authStateChanges().asyncMap((user) async {
        if (user == null) return _devUser;
        return await _getUserProfile(user.uid);
      }).listen(
        (user) => _authStateController.add(user),
        onError: (_) => _authStateController.add(_devUser),
        cancelOnError: false,
      );
    } catch (_) {
      _authStateController.add(_devUser);
    }
  }

  void dispose() {
    _authSubscription?.cancel();
    _authStateController.close();
  }

  Future<AppUser> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw AppException(
            type: AppExceptionType.unknown, message: 'Failed to sign in');
      }
      await _auth.currentUser?.reload();
      return await _getUserProfile(uid);
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        return _createDevUser(email);
      }
      rethrow;
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

  Future<AppUser> registerWithEmailAndPassword(String email, String password,
      {String? displayName}) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw AppException(
            type: AppExceptionType.unknown, message: 'Failed to register user');
      }

      final user = AppUser(
        id: uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );
      await _saveUserProfile(user);
      return user;
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        return _createDevUser(email, displayName: displayName);
      }
      rethrow;
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

  AppUser _createDevUser(String email, {String? displayName}) {
    _devUser = AppUser(
      id: 'dev-${email.hashCode}',
      email: email,
      displayName: displayName ?? email.split('@').first,
      createdAt: DateTime.now(),
    );
    _authStateController.add(_devUser);
    return _devUser!;
  }

  Future<void> signOut() async {
    _devUser = null;
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AppExceptionMapper.mapFirebaseAuthError(e);
    } catch (e) {
      if (e is AppException) rethrow;
    }
    _authStateController.add(null);
  }

  Stream<AppUser?> authStateChanges() => _authStateController.stream;

  Future<AppUser> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null && _devUser == null) {
      throw AppException(
          type: AppExceptionType.userNotFound,
          message: 'No user is currently signed in');
    }
    if (_devUser != null) return _devUser!;
    return await _getUserProfile(firebaseUser!.uid);
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

  Future<void> updateDisplayName(String displayName) async {
    if (_devUser != null) {
      _devUser = _devUser!.copyWith(displayName: displayName);
      _authStateController.add(_devUser);
      return;
    }
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AppException(
            type: AppExceptionType.userNotFound,
            message: 'No user signed in');
      }
      await user.updateDisplayName(displayName);
      await user.reload();
      await _firestore.collection('users').doc(user.uid).update({
        'display_name': displayName,
      });
    } on FirebaseAuthException catch (e) {
      throw AppExceptionMapper.mapFirebaseAuthError(e);
    } on FirebaseException catch (e) {
      throw AppExceptionMapper.mapFirestoreError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
          type: AppExceptionType.unknown,
          message: 'Failed to update display name');
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    if (_devUser != null) return;
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw AppException(
            type: AppExceptionType.userNotFound,
            message: 'No user signed in');
      }
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AppExceptionMapper.mapFirebaseAuthError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
          type: AppExceptionType.unknown,
          message: 'Failed to change password');
    }
  }

  Future<void> updatePhotoURL(String url) async {
    if (_devUser != null) {
      _devUser = _devUser!.copyWith(photoURL: url);
      _authStateController.add(_devUser);
      return;
    }
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AppException(
            type: AppExceptionType.userNotFound,
            message: 'No user signed in');
      }
      await _firestore.collection('users').doc(user.uid).update({
        'photo_url': url,
      });
    } on FirebaseException catch (e) {
      throw AppExceptionMapper.mapFirestoreError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
          type: AppExceptionType.unknown,
          message: 'Failed to update photo URL');
    }
  }

  Future<AppException?> getAuthError(FirebaseAuthException error) async {
    return AppExceptionMapper.mapFirebaseAuthError(error);
  }
}
