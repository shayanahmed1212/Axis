// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'primary_button.dart';

class AppErrorState extends StatelessWidget {
  final String message;
  final String title;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    required this.message,
    required this.title,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0x1AD94A4A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.getFont(
                AppTypography.displayFamily,
                fontSize: AppTypography.headlineSize,
                fontWeight: FontWeight(AppTypography.headlineWeight),
                letterSpacing: AppTypography.headlineLetterSpacing,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.getFont(
                AppTypography.bodyFamily,
                fontSize: AppTypography.bodySize,
                fontWeight: FontWeight(AppTypography.bodyWeight),
                color: AppColors.inkMuted,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(text: 'Retry', onPressed: onRetry, isFullWidth: true),
            ],
          ],
        ),
      ),
    );
  }
}
