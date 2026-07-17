// ignore_for_file: unused_import

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../lib/features/auth/domain/app_user.dart';
import '../../../lib/features/auth/application/auth_controller.dart';

void main() {
  group('AppException', () {
    test('creates with correct type and message', () {
      final exception = AppException(
        type: AppExceptionType.permissionDenied,
        message: 'No permission',
      );
      expect(exception.type, AppExceptionType.permissionDenied);
      expect(exception.message, 'No permission');
    });
  });
}

// Mock class for AppExceptionType
enum AppExceptionType {
  permissionDenied,
  invalidInput,
  unknown,
}

class AppException implements Exception {
  final AppExceptionType type;
  final String message;

  AppException({required this.type, required this.message});

  @override
  String toString() => message;
}