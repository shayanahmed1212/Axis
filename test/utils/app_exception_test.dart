// ignore_for_file: duplicate_ignore, prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../lib/utils/app_utils.dart';

class MockAppException extends Mock implements AppException {}

void main() {
  group('AppException', () {
    test('creates unknown exception correctly', () {
      final exception = AppException.unknown();
      expect(exception.type, AppExceptionType.unknown);
      expect(exception.message, 'An unexpected error occurred');
    });

    test('creates exception with custom message', () {
      // ignore: prefer_const_constructors
      final exception = AppException(
        type: AppExceptionType.permissionDenied,
        message: 'No permission',
        details: 'User lacks read access',
      );
      expect(exception.type, AppExceptionType.permissionDenied);
      expect(exception.message, 'No permission');
      expect(exception.details, 'User lacks read access');
    });

    test('toString returns message', () {
      final exception = AppException(
        type: AppExceptionType.networkError,
        message: 'Network error',
      );
      expect(exception.toString(), 'Network error');
    });

    test('fromJson correctly parses map', () {
      final json = {
        'type': 'networkError',
        'message': 'Connection failed',
        'details': null,
      };
      final exception = AppException.fromJson(json);
      expect(exception.type, AppExceptionType.networkError);
      expect(exception.message, 'Connection failed');
    });
  });
}