// ignore_for_file: unnecessary_import, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../errors/app_exception.dart';
import '../errors/app_exception_types.dart';

class AppExceptionMapper {
  static AppException mapFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return AppException(type: AppExceptionType.notFound, message: 'No user found with this email address.');
      case 'wrong-password':
        return AppException(type: AppExceptionType.invalidInput, message: 'Invalid email or password.');
      case 'email-already-in-use':
        return AppException(type: AppExceptionType.alreadyExists, message: 'This email address is already in use.');
      case 'weak-password':
        return AppException(type: AppExceptionType.invalidInput, message: 'Password is too weak. Use at least 6 characters.');
      case 'user-disabled':
        return AppException(type: AppExceptionType.internalError, message: 'Your account has been disabled.');
      case 'too-many-requests':
        return AppException(type: AppExceptionType.internalError, message: 'Too many attempts. Please try again later.');
      case 'operation-not-allowed':
        return AppException(type: AppExceptionType.permissionDenied, message: 'This operation is not allowed.');
      case 'network-request-failed':
        return AppException(type: AppExceptionType.networkError, message: 'Network error. Please check your connection.');
      default:
        return AppException(type: AppExceptionType.unknown, message: 'An unknown error occurred: ${error.message}');
    }
  }

  static AppException mapFirestoreError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return AppException(type: AppExceptionType.permissionDenied, message: 'You do not have permission to perform this action.');
      case 'not-found':
        return AppException(type: AppExceptionType.notFound, message: 'The requested resource was not found.');
      case 'already-exists':
        return AppException(type: AppExceptionType.alreadyExists, message: 'This resource already exists.');
      case 'unavailable':
        return AppException(type: AppExceptionType.networkError, message: 'Service unavailable. Please try again later.');
      default:
        return AppException(type: AppExceptionType.unknown, message: 'Database error: ${error.message}');
    }
  }
}