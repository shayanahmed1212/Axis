// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:axis/core/config/settings_providers.dart';
import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/features/auth/application/auth_controller.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateProvider, (prev, next) {
      next.when(
        data: (user) {
          if (user != null) {
            final onboardingComplete = ref.read(onboardingCompleteProvider);
            context.go(onboardingComplete ? '/' : '/onboarding');
          } else {
            context.go('/login');
          }
        },
        error: (e, _) {
          context.go('/login');
        },
        loading: () {},
      );
    });

    return Scaffold(
      backgroundColor: AppColors.canvasDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo mark: rounded-square outline + checkmark
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                border: Border.all(color: AppColors.primary, width: 2.5),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.onPrimary,
                size: 48,
              ),
            ),
            const SizedBox(height: AppTokens.md),
            // Wordmark
            Text(
              'Axis',
              style: AppTypography.onboardingHeadline(color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}
