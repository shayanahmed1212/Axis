// Axis Color System — Confident Color-Block Bento
// Every card is a solid color block. Accent yellow is interactive-only.
import 'package:flutter/material.dart';

class AppColors {
  // Canvas & neutrals
  static const Color canvas = Color(0xFFF6F5F1);
  static const Color surfaceDark = Color(0xFF15161A);
  static const Color ink = Color(0xFF15161A);
  static const Color inkOnDark = Color(0xFFFFFFFF);
  static const Color inkMuted = Color(0xFF6B6D76);
  static const Color inkMutedOnDark = Color(0xFFB7B9C2);

  // Block palette — full-bleed card fills
  static const Color blockSage = Color(0xFFC8E6C9);
  static const Color blockSageText = Color(0xFF1E3A24);
  static const Color blockLavender = Color(0xFFDED9F7);
  static const Color blockLavenderText = Color(0xFF2E2555);
  static const Color blockPeach = Color(0xFFF8DFC0);
  static const Color blockPeachText = Color(0xFF5A3A12);
  static const Color blockCoral = Color(0xFFF7C9CB);
  static const Color blockCoralText = Color(0xFF5C1D22);
  static const Color blockSky = Color(0xFFC9E4F5);
  static const Color blockSkyText = Color(0xFF123A54);
  static const Color blockBlack = Color(0xFF15161A);
  static const Color blockBlackText = Color(0xFFFFFFFF);

  // Accent — interactive/primary ONLY
  static const Color accent = Color(0xFFFFC93C);
  static const Color accentInk = Color(0xFF15161A);

  // Semantic
  static const Color success = Color(0xFF2E7D46);
  static const Color error = Color(0xFFC23B3F);

  // Card surface (for task cards that aren't block-color)
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1F24);

  // Priority ribbon colors
  static const Color priorityHigh = blockCoral;
  static const Color priorityHighText = blockCoralText;
  static const Color priorityMedium = accent;
  static const Color priorityMediumText = accentInk;
  static const Color priorityLow = blockSage;
  static const Color priorityLowText = blockSageText;

  // Hairline
  static const Color hairline = Color(0xFFE5E5EA);
  static const Color hairlineOnDark = Color(0xFF2A2B30);

  // ── Backward-compatible aliases (old Apple system → new bento) ──
  static const Color primary = accent;
  static const Color onPrimary = accentInk;
  static const Color primaryFocus = accent;
  static const Color primaryDim = Color(0xFFE6B800);
  static const Color primaryBright = accent;
  static Color get primarySoft => accent.withOpacity(0.10);
  static const Color surfacePearl = cardWhite;
  static const Color surface0 = canvas;
  static const Color surface1 = canvas;
  static const Color surface2 = cardWhite;
  static const Color surface3 = cardWhite;
  static const Color canvasParchment = canvas;
  static const Color onDark = inkOnDark;
  static const Color hairlineStrong = hairline;
  static const Color dividerSoft = hairline;
  static const Color inkSubtle = inkMuted;
  static const Color priorityLowSoft = blockSage;
  static Color get priorityMediumSoft => accent.withOpacity(0.10);
  static const Color priorityHighSoft = blockCoral;
}
