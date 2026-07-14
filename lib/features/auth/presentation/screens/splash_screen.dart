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
      next.whenData((user) {
        if (user != null) {
          final onboardingComplete = ref.read(onboardingCompleteProvider);
          if (onboardingComplete) {
            context.go('/dashboard');
          } else {
            context.go('/onboarding');
          }
        } else {
          context.go('/login');
        }
      });
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
