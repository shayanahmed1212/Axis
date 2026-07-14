// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
          context.go('/dashboard');
        } else {
          context.go('/login');
        }
      });
    });

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Axis mark — a single centered line, the calibration reference
            Container(
              width: 2,
              height: 48,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.accent, AppColors.primary],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Axis',
              style: GoogleFonts.getFont(
                AppTypography.displayFamily,
                fontSize: AppTypography.displaySize,
                fontWeight: FontWeight(AppTypography.displayWeight),
                letterSpacing: AppTypography.displayLetterSpacing,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find your center.',
              style: GoogleFonts.getFont(
                AppTypography.bodyFamily,
                fontSize: AppTypography.bodySmSize,
                fontWeight: FontWeight(AppTypography.bodySmWeight),
                color: AppColors.inkSubtle,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
