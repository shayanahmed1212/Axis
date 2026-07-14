import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/utils/validators.dart';

void main() {
  group('Validators.validateEmail', () {
    test('returns error for empty email', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail(null), isNotNull);
    });

    test('returns error for invalid email', () {
      expect(Validators.validateEmail('notanemail'), isNotNull);
      expect(Validators.validateEmail('@domain.com'), isNotNull);
      expect(Validators.validateEmail('user@'), isNotNull);
    });

    test('returns null for valid email', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
      expect(Validators.validateEmail('user.name+tag@domain.co'), isNull);
    });
  });

  group('Validators.validatePassword', () {
    test('returns error for empty password', () {
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword(null), isNotNull);
    });

    test('returns error for short password', () {
      expect(Validators.validatePassword('abc'), isNotNull);
      expect(Validators.validatePassword('12345'), isNotNull);
    });

    test('returns null for valid password', () {
      expect(Validators.validatePassword('password123'), isNull);
      expect(Validators.validatePassword('abcdef'), isNull);
    });
  });

  group('Validators.validateConfirmPassword', () {
    test('returns error when passwords do not match', () {
      expect(Validators.validateConfirmPassword('pass1', 'pass2'), isNotNull);
    });

    test('returns null when passwords match', () {
      expect(Validators.validateConfirmPassword('password', 'password'), isNull);
    });
  });

  group('Validators.validateTaskTitle', () {
    test('returns error for empty title', () {
      expect(Validators.validateTaskTitle(''), isNotNull);
      expect(Validators.validateTaskTitle(null), isNotNull);
    });

    test('returns error for short title', () {
      expect(Validators.validateTaskTitle('a'), isNotNull);
    });

    test('returns null for valid title', () {
      expect(Validators.validateTaskTitle('Buy groceries'), isNull);
      expect(Validators.validateTaskTitle('Finish project report'), isNull);
    });
  });
}