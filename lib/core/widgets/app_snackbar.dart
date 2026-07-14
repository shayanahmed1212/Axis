// ignore_for_file: prefer_const_constructors

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
        bgColor = AppColors.blockBlack;
        textColor = AppColors.inkOnDark;
        icon = Icons.check_circle_rounded;
      case SnackBarType.error:
        bgColor = AppColors.error;
        textColor = AppColors.cardWhite;
        icon = Icons.error_rounded;
      case SnackBarType.warning:
        bgColor = AppColors.accent;
        textColor = AppColors.accentInk;
        icon = Icons.warning_rounded;
      case SnackBarType.info:
        bgColor = AppColors.blockBlack;
        textColor = AppColors.inkOnDark;
        icon = Icons.info_rounded;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.getFont(
                  AppTypography.bodyFamily,
                  fontSize: AppTypography.bodySize,
                  fontWeight: FontWeight(AppTypography.bodyWeight),
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusSm)),
        margin: const EdgeInsets.all(17),
        duration: const Duration(seconds: 3),
        action: onAction != null && actionLabel != null
            ? SnackBarAction(label: actionLabel, textColor: AppColors.accent, onPressed: onAction)
            : null,
      ),
    );
  }
}
