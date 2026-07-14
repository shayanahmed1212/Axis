// ignore_for_file: deprecated_member_use

import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/theme/app_colors.dart';
import '../../../lib/core/theme/app_tokens.dart';

void main() {
  group('AppColors', () {
    test('has correct canvas color', () {
      expect(AppColors.canvas.value, 0xFF010102);
    });

    test('has correct primary color', () {
      expect(AppColors.primary.value, 0xFF5E6AD2);
    });

    test('has correct error color', () {
      expect(AppColors.error.value, 0xFFE5484D);
    });
  });

  group('AppTokens', () {
    test('spacing values are multiples of 4', () {
      expect(AppTokens.xxs % 4, 0);
      expect(AppTokens.xs % 4, 0);
      expect(AppTokens.sm % 4, 0);
      expect(AppTokens.md % 4, 0);
      expect(AppTokens.lg % 4, 0);
      expect(AppTokens.xl % 4, 0);
      expect(AppTokens.xxl % 4, 0);
    });

    test('radius values are positive', () {
      expect(AppTokens.radiusXs, greaterThan(0));
      expect(AppTokens.radiusMd, greaterThan(0));
      expect(AppTokens.radiusLg, greaterThan(0));
    });
  });
}