// Shared utilities — error types, result monad, haptics, validators,
// date formatting, Firebase error mapping, and string constants.
//
// [AppException] is the app's single exception type. Services catch
// Firebase/platform exceptions and re-throw [AppException] so screens
// never deal with Firebase-specific error types. [AppExceptionMapper]
// centralises the Firebase→AppException translation logic.
//
// [Validators] provides pure functions (no side effects, no state) for
// form field validation — each returns a human-readable error string or
// null. [AppStrings] collects every user-facing string for future i18n.
// ignore_for_file: unnecessary_import, prefer_const_constructors

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Categorised error types matched against Firebase error codes in
/// [AppExceptionMapper]. Using an enum instead of string constants
/// ensures exhaustive handling in catch sites.`
enum AppExceptionType {
  invalidCredentials,
  userNotFound,
  alreadyExists,
  notFound,
  permissionDenied,
  networkError,
  invalidInput,
  unknown,
  internalError,
}

class AppException implements Exception {
  final AppExceptionType type;
  final String message;
  final String? details;

  const AppException({
    required this.type,
    required this.message,
    this.details,
  });

  @override
  String toString() => message;

  factory AppException.fromJson(Map<String, dynamic> json) {
    return AppException(
      type: AppExceptionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AppExceptionType.unknown,
      ),
      message: json['message'] as String? ?? 'An error occurred',
      details: json['details'] as String?,
    );
  }

  factory AppException.unknown([String? message]) {
    return AppException(
      type: AppExceptionType.unknown,
      message: message ?? 'An unexpected error occurred',
    );
  }
}

sealed class Result<S, E> {
  const Result();
}

final class Success<S, E> extends Result<S, E> {
  final S data;
  const Success(this.data);
}

final class Failure<S, E> extends Result<S, E> {
  final E error;
  const Failure(this.error);
}

/// Centralized haptic feedback for Axis.
/// Each method maps to a specific interaction type.
class AppHaptics {
  /// Light tick — checkbox toggle, chip selection, swipe threshold crossing
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Subtle impact — button press, successful save
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact — delete confirmation, significant action
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Error feedback — failed action
  static void error() {
    HapticFeedback.heavyImpact();
  }
}

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
final emailRegex = RegExp(
  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$",
);    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validateConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != originalPassword) return 'Passwords do not match';
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? validateTaskTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Title is required';
    if (value.trim().length < 2) return 'Title must be at least 2 characters';
    return null;
  }

  static String? validateDescriptionLength(String? value, {int maxLength = 500}) {
    if (value == null) return null;
    if (value.length > maxLength) return 'Description must be less than $maxLength characters';
    return null;
  }
}

// Date formatting utilities
class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}

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

// App constants for strings, routes, and other non-trivial values
class AppStrings {
  // Auth screen strings
  static const String welcomeBack = 'Welcome Back';
  static const String signInToYourAccount = 'Sign in to your account';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String signIn = 'Sign In';
  static const String dontHaveAccount = 'Don\'t have an account?';
  static const String signUp = 'Sign Up';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String sendResetLink = 'Send Reset Link';
  static const String backToLogin = 'Back to Login';

  // Register screen strings
  static const String createAccount = 'Create Account';
  static const String fullName = 'Full Name';
  static const String confirmPassword = 'Confirm Password';
  static const String alreadyHaveAccount = 'Already have an account?';

  // Task dashboard strings
  static const String myTasks = 'My Tasks';
  static const String addTask = 'Add Task';
  static const String all = 'All';
  static const String active = 'Active';
  static const String completed = 'Completed';
  static const String noTasksYet = 'No tasks yet';
  static const String noTasksMessage = 'Add your first task to get started';
  static const String noActiveTasks = 'No active tasks';
  static const String noCompletedTasks = 'No completed tasks';

  // Task form strings
  static const String editTask = 'Edit Task';
  static const String newTask = 'New Task';
  static const String title = 'Title';
  static const String enterTitle = 'Enter task title';
  static const String description = 'Description';
  static const String enterDescription = 'Enter task description (optional)';
  static const String dueDate = 'Due Date';
  static const String priority = 'Priority';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String selectPriority = 'Select priority';
  static const String low = 'Low';
  static const String medium = 'Medium';
  static const String high = 'High';

  // Empty states
  static const String emptyStateTitle = 'All clear!';
  static const String emptyStateMessage = 'You\'ve completed all your tasks';
  static const String swipeToDelete = 'Swipe left to delete';

  // Error states
  static const String errorTitle = 'Something went wrong';
  static const String retry = 'Retry';
  static const String networkError = 'Network error. Please check your connection.';

  // Success states
  static const String taskSaved = 'Task saved successfully';
  static const String taskDeleted = 'Task deleted';
  static const String undo = 'Undo';
  static const String passwordResetSent = 'Password reset link sent to your email';

  // Validation errors
  static const String errorRequiredField = 'This field is required';
  static const String errorInvalidEmail = 'Please enter a valid email';
  static const String errorPasswordTooShort = 'Password must be at least 6 characters';
  static const String errorPasswordsDontMatch = 'Passwords do not match';
  static const String errorTitleTooShort = 'Title must be at least 2 characters';

  // Auth error messages
  static const String errorInvalidCredentials = 'Invalid email or password';
  static const String errorEmailAlreadyInUse = 'This email is already in use';
  static const String errorWeakPassword = 'Password is too weak';
  static const String errorUserDisabled = 'Your account has been disabled';
  static const String errorTooManyRequests = 'Too many attempts. Please try again later';

  // Profile screen
  static const String profile = 'Profile';
  static const String emailLabel = 'Email';
  static const String logout = 'Logout';
  static const String logoutConfirm = 'Are you sure you want to logout?';
  static const String cancelAction = 'Cancel';
  static const String logoutAction = 'Logout';
}

/// Wraps a [Stream] factory with automatic retry on transient
/// permission-denied errors. Each retry waits `500ms * attempt` before
/// re-subscribing to the stream. After [maxRetries] the error propagates.
///
/// Use this on initial Firestore snapshot streams that may fail right
/// after registration/login because the Auth token hasn't synced yet.
Stream<T> retryStream<T>(
  Stream<T> Function() factory, {
  int maxRetries = 3,
}) async* {
  int attempts = 0;
  while (attempts < maxRetries) {
    try {
      yield* factory();
      return;
    } on AppException catch (e) {
      attempts++;
      if (e.type != AppExceptionType.permissionDenied || attempts >= maxRetries) {
        rethrow;
      }
      await Future<void>.delayed(Duration(milliseconds: 500 * attempts));
    }
  }
}

/// Same retry-with-backoff pattern for one-shot Firestore queries (futures).
Future<T> retryFuture<T>(
  Future<T> Function() factory, {
  int maxRetries = 3,
}) async {
  int attempts = 0;
  while (true) {
    try {
      return await factory();
    } on AppException catch (e) {
      attempts++;
      if (e.type != AppExceptionType.permissionDenied || attempts >= maxRetries) {
        rethrow;
      }
      await Future<void>.delayed(Duration(milliseconds: 500 * attempts));
    }
  }
}
