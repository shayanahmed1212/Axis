// Axis Complete Application Theme — Confident Color-Block Bento
// ignore_for_file: prefer_const_constructors, prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

ThemeData getAxisTheme() {
  final bodyFont = AppTypography.bodyFamily;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: bodyFont,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.accent,
      onPrimary: AppColors.accentInk,
      secondary: AppColors.accent,
      onSecondary: AppColors.accentInk,
      error: AppColors.error,
      onError: AppColors.cardWhite,
      surface: AppColors.canvas,
      onSurface: AppColors.ink,
      outline: AppColors.hairline,
    ),
    scaffoldBackgroundColor: AppColors.canvas,
    cardColor: AppColors.cardWhite,
    dividerColor: AppColors.hairline,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.canvas,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.sora(
        fontSize: AppTypography.screenTitleSize,
        fontWeight: FontWeight(AppTypography.screenTitleWeight),
        letterSpacing: AppTypography.screenTitleTracking,
        color: AppColors.ink,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.cardWhite,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.accentInk,
        disabledBackgroundColor: AppColors.accent.withOpacity(0.4),
        disabledForegroundColor: AppColors.accentInk.withOpacity(0.5),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: AppTypography.buttonSize,
          fontWeight: FontWeight(AppTypography.buttonWeight),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accent,
        backgroundColor: Colors.transparent,
        disabledForegroundColor: AppColors.inkMuted,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        side: const BorderSide(color: AppColors.hairline, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: AppTypography.buttonSize,
          fontWeight: FontWeight(AppTypography.buttonWeight),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
      filled: true,
      fillColor: AppColors.cardWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        borderSide: const BorderSide(color: AppColors.hairline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        borderSide: const BorderSide(color: AppColors.hairline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: AppTypography.bodySize,
        fontWeight: FontWeight(AppTypography.bodyWeight),
        color: AppColors.inkMuted,
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: AppTypography.captionSize,
        fontWeight: FontWeight(AppTypography.captionWeight),
        color: AppColors.inkMuted,
      ),
      errorStyle: GoogleFonts.inter(
        fontSize: AppTypography.captionSize,
        fontWeight: FontWeight(AppTypography.captionWeight),
        color: AppColors.error,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.blockBlack,
      contentTextStyle: GoogleFonts.inter(
        fontSize: AppTypography.bodySize,
        fontWeight: FontWeight(AppTypography.bodyWeight),
        color: AppColors.inkOnDark,
      ),
      actionTextColor: AppColors.accent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusSm)),
      behavior: SnackBarBehavior.floating,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cardWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusLg)),
    ),
  );
}

// Backward-compatible alias
ThemeData getFlowTheme() => getAxisTheme();
