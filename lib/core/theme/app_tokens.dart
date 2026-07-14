// Axis Design Tokens — Spacing, Radius, Shadows
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTokens {
  // Spacing — base unit 4px
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double xxl = 36;

  // Page
  static const double pageMargin = 20;
  static const double bentoGap = 12;

  // Radius
  static const double radiusSm = 12;
  static const double radiusMd = 20;
  static const double radiusLg = 28;
  static const double radiusXl = 32;
  static const double radiusPill = 9999;

  // Motion durations (ms)
  static const int durationInstant = 80;
  static const int durationFast = 140;
  static const int durationNormal = 200;
  static const int durationSlow = 300;
  static const int durationCompletion = 180;
  static const int durationStagger = 40;

  // Color-matched shadows
  static List<BoxShadow> shadowColor(Color color, {double opacity = 0.2, double blur = 20, double y = 8}) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: blur,
        offset: Offset(0, y),
      ),
    ];
  }

  static List<BoxShadow> get shadowSage => shadowColor(AppColors.blockSage);
  static List<BoxShadow> get shadowLavender => shadowColor(AppColors.blockLavender);
  static List<BoxShadow> get shadowPeach => shadowColor(AppColors.blockPeach);
  static List<BoxShadow> get shadowCoral => shadowColor(AppColors.blockCoral);
  static List<BoxShadow> get shadowSky => shadowColor(AppColors.blockSky);
  static List<BoxShadow> get shadowBlack => shadowColor(AppColors.blockBlack, opacity: 0.25, blur: 30, y: 10);
  static List<BoxShadow> get shadowAccent => shadowColor(AppColors.accent, opacity: 0.25, blur: 30, y: 10);

  // ── Backward-compatible shadow aliases ──
  static List<BoxShadow> get shadowSm => shadowCardWhite;
  static List<BoxShadow> get shadowMd => shadowCardWhite;
  static List<BoxShadow> get shadowLg => shadowCardWhite;

  // ── Backward-compatible duration aliases ──
  static const int durationPress = durationFast;
  static const int durationHold = durationSlow;
  static const int durationSettle = durationNormal;

  static List<BoxShadow> get shadowCardWhite => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
