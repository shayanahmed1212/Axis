// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final Color? confirmColor;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.confirmColor,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: () {
          Navigator.of(ctx).pop(true);
          onConfirm?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusXl)),
      title: Text(
        title,
        style: GoogleFonts.getFont(
          AppTypography.displayFamily,
          fontSize: AppTypography.headlineSize,
          fontWeight: FontWeight(AppTypography.headlineWeight),
          letterSpacing: AppTypography.headlineLetterSpacing,
          color: AppColors.ink,
        ),
      ),
      content: Text(
        message,
        style: GoogleFonts.getFont(
          AppTypography.bodyFamily,
          fontSize: AppTypography.bodySize,
          fontWeight: FontWeight(AppTypography.bodyWeight),
          color: AppColors.inkMuted,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelLabel,
            style: GoogleFonts.getFont(
              AppTypography.bodyFamily,
              fontSize: AppTypography.buttonSize,
              fontWeight: FontWeight(AppTypography.buttonWeight),
              color: AppColors.inkSubtle,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? AppColors.error,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
          ),
          child: Text(
            confirmLabel,
            style: GoogleFonts.getFont(
              AppTypography.bodyFamily,
              fontSize: AppTypography.buttonSize,
              fontWeight: FontWeight(AppTypography.buttonWeight),
            ),
          ),
        ),
      ],
    );
  }
}
