// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'primary_button.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final IconData icon;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.onActionPressed,
    this.actionLabel,
    this.icon = Icons.inbox_outlined,
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
                color: AppColors.surface2,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.hairlineStrong),
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
            if (onActionPressed != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(text: actionLabel!, onPressed: onActionPressed, isFullWidth: true),
            ],
          ],
        ),
      ),
    );
  }
}
