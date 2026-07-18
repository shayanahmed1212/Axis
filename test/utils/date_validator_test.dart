import 'package:flutter_test/flutter_test.dart';

import '../../lib/utils/app_utils.dart';

void main() {
  group('Validators', () {
    test('validateName returns error for empty', () {
      expect(Validators.validateName(''), isNotNull);
    });

    test('validateName returns null for valid name', () {
      expect(Validators.validateName('John Doe'), isNull);
    });

    test('validateEmail returns error for empty', () {
      expect(Validators.validateEmail(''), isNotNull);
    });

    test('validateEmail returns null for valid email', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
    });

    test('validatePassword returns error for empty', () {
      expect(Validators.validatePassword(''), isNotNull);
    });

    test('validatePassword returns null for valid password', () {
      expect(Validators.validatePassword('password123'), isNull);
    });

    test('validateTaskTitle returns error for empty', () {
      expect(Validators.validateTaskTitle(''), isNotNull);
    });

    test('validateTaskTitle returns null for valid title', () {
      expect(Validators.validateTaskTitle('My Task'), isNull);
    });
  });
}
