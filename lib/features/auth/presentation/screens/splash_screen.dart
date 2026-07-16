// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:axis/core/config/settings_providers.dart';
import 'package:axis/core/theme/app_colors.dart';
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
            context.go(onboardingComplete ? '/dashboard' : '/onboarding');
          } else {
            context.go('/login');
          }
        },
        error: (e, _) {
          // Don't strand the user on a silent black screen forever if the
          // auth stream errors — fall back to login, which is always a
          // safe destination and lets them retry the action that failed.
          context.go('/login');
        },
        loading: () {}, // still initializing — wait for the next event
      );
    });

    return Scaffold(
      backgroundColor: AppColors.blockBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Axis',
              style: AppTypography.display(
                size: 40,
                weight: 700,
                letterSpacing: -0.01,
                color: AppColors.inkOnDark,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}