// Axis Design Tokens — Color Palette
// The instrument face: dark surfaces with cool undertones,
// steel blue as working color, warm golden as the calibration mark.
import 'package:flutter/material.dart';

class AppColors {
  // Canvas and surface colors — the instrument face
  // Cool blue-black undertones, like machined metal catching different light
  static const Color canvas = Color(0xFF0A0B0D);
  static const Color surface1 = Color(0xFF111318);
  static const Color surface2 = Color(0xFF181B22);
  static const Color surface3 = Color(0xFF1E2129);

  // Text colors — hierarchy through lightness, not decoration
  static const Color ink = Color(0xFFECEDF0);
  static const Color inkMuted = Color(0xFFA8ADB8);
  static const Color inkSubtle = Color(0xFF6B7080);

  // Primary — technical ink, the working color of the interface
  // Cooler and more restrained than a brand blue: the shade of a machinist's scale
  static const Color primary = Color(0xFF4A7CDB);
  static const Color primaryHover = Color(0xFF6A9AE8);
  static const Color primaryFocus = Color(0xFF3D6BC4);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Accent — golden amber, the calibration mark
  // Warm gold on cool steel: the single illuminated mark on an instrument dial.
  // Used in exactly two places: completion animation stroke, active filter pill.
  static const Color accent = Color(0xFFC9A84C);
  static const Color accentSoft = Color(0x26C9A84C);

  // Status colors — instrument indicator lights, not gamified confetti
  static const Color success = Color(0xFF3DAA6A);
  static const Color error = Color(0xFFD94A4A);

  // Border colors — engraved guidelines, visible only when you look
  static const Color hairline = Color(0xFF1E2129);
  static const Color hairlineStrong = Color(0xFF2A2D36);

  // Semantic synonyms
  static const Color completed = success;
  static const Color incomplete = hairline;
}
