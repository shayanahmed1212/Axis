// Hero Greeting Card — full-width black block at top of dashboard
import 'package:flutter/material.dart';
import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';

class HeroGreetingCard extends StatelessWidget {
  final String greeting;
  final String summary;
  final int taskCount;
  final VoidCallback? onAction;

  const HeroGreetingCard({
    super.key,
    required this.greeting,
    required this.summary,
    required this.taskCount,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.blockBlack,
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        boxShadow: AppTokens.shadowBlack,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  greeting,
                  style: AppTypography.display(
                    size: AppTypography.screenTitleSize,
                    weight: AppTypography.screenTitleWeight,
                    letterSpacing: AppTypography.screenTitleTracking,
                    color: AppColors.inkOnDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 18,
                    color: AppColors.inkOnDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: AppTypography.body(
                size: AppTypography.bodySize,
                weight: AppTypography.bodyWeight,
                color: AppColors.inkMutedOnDark,
              ),
              children: [
                const TextSpan(text: 'You have '),
                TextSpan(
                  text: '$taskCount task${taskCount == 1 ? '' : 's'}',
                  style: AppTypography.body(
                    size: AppTypography.bodySize,
                    weight: AppTypography.sectionHeaderWeight,
                    color: AppColors.accent,
                  ),
                ),
                const TextSpan(text: ' for today'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
