import 'package:flutter/material.dart';

class AppColors {
  static const Color canvasDark = Color(0xFF121212);
  static const Color surfaceCard = Color(0xFF363636);
  static const Color surfaceCardAlt = Color(0xFF22222E);
  static const Color hairline = Color(0xFF2C2C38);
  static const Color navBar = Color(0xFF363636);
  static const Color ink = Color(0xFFFFFFFF);
  static const Color inkMuted = Color(0xFFB9B9B9);
  static const Color inkFaint = Color(0xFF55555F);
  static const Color primary = Color(0xFF8687E7);
  static const Color primaryDim = Color(0xFF4A4470);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFFF5C5C);
  static const Color weekendRed = Color(0xFFFF4949);
  static const Color surfaceCharcoal = Color(0xFF272727);
  static const Color mutedLavender = Color(0xFF8A8FD9);
  static const Color catGrocery = Color(0xFFB5E6A8);
  static const Color catWork = Color(0xFFFFD080);
  static const Color catSport = Color(0xFF9EE7E0);
  static const Color catDesign = Color(0xFFB8E8D3);
  static const Color catUniversity = Color(0xFF8586E7);
  static const Color catSocial = Color(0xFFF0B5DD);
  static const Color catMusic = Color(0xFFD4A9EB);
  static const Color catHealth = Color(0xFFA8E3C5);
  static const Color catMovie = Color(0xFFA4D5F0);
  static const Color catHome = Color(0xFFFF8080);

  static const List<Color> categoryColors = [
    catGrocery, catWork, catSport, catDesign,
    catUniversity, catSocial, catMusic, catHealth,
    catMovie, catHome,
  ];

  static const List<String> categoryColorNames = [
    'Grocery', 'Work', 'Sport', 'Design',
    'University', 'Social', 'Music', 'Health',
    'Movie', 'Home',
  ];

  // Backward-compatible aliases
  static const Color canvas = canvasDark;
  static const Color surface = surfaceCard;
  static const Color surface1 = surfaceCard;
  static const Color surface2 = surfaceCardAlt;
  static const Color surfaceMuted = surfaceCardAlt;
  static const Color accent = primary;
  static const Color accentMuted = primaryDim;
  static const Color onAccent = onPrimary;
  static const Color success = primary;
}
