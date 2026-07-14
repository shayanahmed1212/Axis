// Axis Typography — Sora for display, Inter for UI
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Display font — Sora for big numbers and screen titles
  static const String displayFamily = 'Sora';
  // Body font — Inter for everything else
  static const String bodyFamily = 'Inter';

  // Hero numeral — big stat card numbers
  static const double heroNumeralSize = 40;
  static const int heroNumeralWeight = 800;
  static const double heroNumeralTracking = -0.02;

  // Screen title
  static const double screenTitleSize = 26;
  static const int screenTitleWeight = 700;
  static const double screenTitleTracking = -0.01;

  // Section header
  static const double sectionHeaderSize = 18;
  static const int sectionHeaderWeight = 700;

  // Card title (task title)
  static const double cardTitleSize = 16;
  static const int cardTitleWeight = 600;

  // Body
  static const double bodySize = 14;
  static const int bodyWeight = 400;

  // Meta/caption
  static const double captionSize = 12;
  static const int captionWeight = 500;
  static const double captionTracking = 0.01;

  // Ribbon tag text
  static const double ribbonSize = 10;
  static const int ribbonWeight = 700;
  static const double ribbonTracking = 0.04;

  // Button label
  static const double buttonSize = 15;
  static const int buttonWeight = 600;

  // Helper — get Sora TextStyle
  static TextStyle display({
    double? size,
    int? weight,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.sora(
      fontSize: size ?? screenTitleSize,
      fontWeight: FontWeight(weight ?? screenTitleWeight),
      letterSpacing: letterSpacing ?? screenTitleTracking,
      color: color,
    );
  }

  // ── Backward-compatible aliases (old Apple system → new bento) ──
  static const double headlineSize = screenTitleSize;
  static const int headlineWeight = screenTitleWeight;
  static const double headlineLetterSpacing = screenTitleTracking;
  static const double titleSize = sectionHeaderSize;
  static const int titleWeight = sectionHeaderWeight;
  static const double titleLetterSpacing = 0.0;
  static const double bodySmSize = captionSize;
  static const int bodySmWeight = captionWeight;
  static const double bodyLetterSpacing = 0.0;
  static const double buttonLetterSpacing = 0.0;
  static const double captionLetterSpacing = captionTracking;
  static const double displaySize = screenTitleSize;
  static const int displayWeight = screenTitleWeight;
  static const double displayLetterSpacing = screenTitleTracking;

  // Helper — get Inter TextStyle
  static TextStyle body({
    double? size,
    int? weight,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: size ?? bodySize,
      fontWeight: FontWeight(weight ?? bodyWeight),
      letterSpacing: letterSpacing,
      color: color,
    );
  }
}
