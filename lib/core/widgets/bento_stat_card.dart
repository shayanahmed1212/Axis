// Bento Stat Card — full-bleed color block with bold numeral
import 'package:flutter/material.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';

class BentoStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color backgroundColor;
  final Color textColor;
  final List<BoxShadow>? shadow;
  final Widget? trailing;

  const BentoStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.textColor,
    this.shadow,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        boxShadow: shadow ?? AppTokens.shadowCardWhite,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTypography.body(
                  size: AppTypography.captionSize,
                  weight: AppTypography.captionWeight,
                  letterSpacing: AppTypography.captionTracking,
                  color: textColor.withOpacity(0.7),
                ),
              ),
              trailing != null ? trailing! : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.display(
              size: AppTypography.heroNumeralSize,
              weight: AppTypography.heroNumeralWeight,
              letterSpacing: AppTypography.heroNumeralTracking,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
