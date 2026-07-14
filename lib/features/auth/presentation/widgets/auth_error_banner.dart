// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';

class AuthErrorBanner extends StatelessWidget {
  final String? message;
  final VoidCallback? onDismiss;

  const AuthErrorBanner({super.key, this.message, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message!,
              style: GoogleFonts.getFont(
                AppTypography.bodyFamily,
                fontSize: AppTypography.bodySmSize,
                fontWeight: FontWeight(AppTypography.bodySmWeight),
                color: AppColors.error,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close, color: AppColors.inkSubtle, size: 18),
            ),
        ],
      ),
    );
  }
}
