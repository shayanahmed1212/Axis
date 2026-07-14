import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';

enum SnackBarType { success, error, warning, info }

class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.success,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        bgColor = AppColors.success;
        textColor = AppColors.onPrimary;
        icon = Icons.check_circle;
      case SnackBarType.error:
        bgColor = AppColors.error;
        textColor = AppColors.onPrimary;
        icon = Icons.error;
      case SnackBarType.warning:
        bgColor = AppColors.primary;
        textColor = AppColors.onPrimary;
        icon = Icons.warning;
      case SnackBarType.info:
        bgColor = AppColors.surface2;
        textColor = AppColors.ink;
        icon = Icons.info;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.getFont(
                  AppTypography.bodyFamily,
                  fontSize: AppTypography.bodySize,
                  // ignore: prefer_const_constructors
                  fontWeight: FontWeight(AppTypography.bodyWeight),
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: onAction != null && actionLabel != null
            ? SnackBarAction(label: actionLabel, textColor: textColor, onPressed: onAction)
            : null,
      ),
    );
  }
}
