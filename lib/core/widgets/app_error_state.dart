import 'package:flutter/material.dart';
import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/widgets/pressable.dart';

/// Shared full-space error state with a retry action — replaces raw
/// Text('Error: $e') dumps anywhere an AsyncValue.error is handled.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Try again',
    super.key,
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.blockCoral,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 30, color: AppColors.blockCoralText),
            ),
            const SizedBox(height: AppTokens.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body(size: 14, weight: 400, color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppTokens.lg),
            Pressable(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg, vertical: AppTokens.sm),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                ),
                child: Text(
                  retryLabel,
                  style: AppTypography.body(size: 15, weight: 600, color: AppColors.accentInk),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}