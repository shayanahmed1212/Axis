// Progress Ring Compact — bold accent stroke, centered numeral
import 'package:flutter/material.dart';
import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_typography.dart';

class ProgressRingCompact extends StatelessWidget {
  final double ratio;
  final double size;

  const ProgressRingCompact({super.key, required this.ratio, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: ratio,
              strokeWidth: 8,
              backgroundColor: AppColors.canvas,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '${(ratio * 100).round()}%',
            style: AppTypography.display(
              size: 20,
              weight: 800,
              letterSpacing: -0.02,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
