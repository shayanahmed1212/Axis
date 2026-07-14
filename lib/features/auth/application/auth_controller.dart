// ignore_for_file: prefer_const_constructors, unused_field

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:axis/features/auth/domain/app_user.dart';
import 'package:axis/features/auth/data/auth_repository.dart';
import 'package:axis/core/errors/app_exception.dart';
import 'package:axis/core/errors/app_exception_types.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

final authControllerProvider = Provider<AuthController>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository, ref);
});

class AuthController {
  final AuthRepository _repository;
  final Ref _ref;

  AuthController(this._repository, this._ref);

  Future<AppUser?> signIn(String email, String password) async {
    try {
      return await _repository.signInWithEmailAndPassword(email, password);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  Future<AppUser?> register(String email, String password, {String? displayName}) async {
    try {
      return await _repository.registerWithEmailAndPassword(
        email,
        password,
        displayName: displayName,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _repository.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _repository.resetPassword(email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  AppException _mapFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return AppException(type: AppExceptionType.notFound, message: 'No user found with this email');
      case 'wrong-password':
        return AppException(type: AppExceptionType.invalidInput, message: 'Invalid email or password');
      case 'email-already-in-use':
        return AppException(type: AppExceptionType.alreadyExists, message: 'This email is already registered');
      case 'weak-password':
        return AppException(type: AppExceptionType.invalidInput, message: 'Password should be at least 6 characters');
      case 'invalid-email':
        return AppException(type: AppExceptionType.invalidInput, message: 'Invalid email address');
      case 'user-disabled':
        return AppException(type: AppExceptionType.internalError, message: 'This account has been disabled');
      case 'too-many-requests':
        return AppException(type: AppExceptionType.internalError, message: 'Too many attempts. Try again later');
      case 'network-request-failed':
        return AppException(type: AppExceptionType.networkError, message: 'Network error. Check your connection');
      default:
        return AppException(type: AppExceptionType.unknown, message: 'An unexpected error occurred');
    }
  }
}