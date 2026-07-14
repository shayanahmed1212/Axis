// Axis Complete Application Theme
// Instrument-precision dark theme with golden calibration accent
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_declarations, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

class AxisThemeExtension extends ThemeExtension<AxisThemeExtension> {
  final Color primaryColor;
  final Color primaryHoverColor;
  final Color primaryFocusColor;
  final Color accentColor;
  final Color accentSoftColor;
  final Color successColor;
  final Color errorColor;
  final Color hairlineColor;
  final Color hairlineStrongColor;
  final Color textPrimaryColor;
  final Color textMutedColor;
  final Color textSubtleColor;
  final Color surface1Color;
  final Color surface2Color;
  final Color surface3Color;
  final Color canvasColor;

  const AxisThemeExtension({
    required this.primaryColor,
    required this.primaryHoverColor,
    required this.primaryFocusColor,
    required this.accentColor,
    required this.accentSoftColor,
    required this.successColor,
    required this.errorColor,
    required this.hairlineColor,
    required this.hairlineStrongColor,
    required this.textPrimaryColor,
    required this.textMutedColor,
    required this.textSubtleColor,
    required this.surface1Color,
    required this.surface2Color,
    required this.surface3Color,
    required this.canvasColor,
  });

  @override
  AxisThemeExtension copyWith({
    Color? primaryColor,
    Color? primaryHoverColor,
    Color? primaryFocusColor,
    Color? accentColor,
    Color? accentSoftColor,
    Color? successColor,
    Color? errorColor,
    Color? hairlineColor,
    Color? hairlineStrongColor,
    Color? textPrimaryColor,
    Color? textMutedColor,
    Color? textSubtleColor,
    Color? surface1Color,
    Color? surface2Color,
    Color? surface3Color,
    Color? canvasColor,
  }) {
    return AxisThemeExtension(
      primaryColor: primaryColor ?? this.primaryColor,
      primaryHoverColor: primaryHoverColor ?? this.primaryHoverColor,
      primaryFocusColor: primaryFocusColor ?? this.primaryFocusColor,
      accentColor: accentColor ?? this.accentColor,
      accentSoftColor: accentSoftColor ?? this.accentSoftColor,
      successColor: successColor ?? this.successColor,
      errorColor: errorColor ?? this.errorColor,
      hairlineColor: hairlineColor ?? this.hairlineColor,
      hairlineStrongColor: hairlineStrongColor ?? this.hairlineStrongColor,
      textPrimaryColor: textPrimaryColor ?? this.textPrimaryColor,
      textMutedColor: textMutedColor ?? this.textMutedColor,
      textSubtleColor: textSubtleColor ?? this.textSubtleColor,
      surface1Color: surface1Color ?? this.surface1Color,
      surface2Color: surface2Color ?? this.surface2Color,
      surface3Color: surface3Color ?? this.surface3Color,
      canvasColor: canvasColor ?? this.canvasColor,
    );
  }

  @override
  AxisThemeExtension lerp(ThemeExtension<AxisThemeExtension> other, double t) {
    if (other is! AxisThemeExtension) return this;
    return AxisThemeExtension(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      primaryHoverColor: Color.lerp(primaryHoverColor, other.primaryHoverColor, t)!,
      primaryFocusColor: Color.lerp(primaryFocusColor, other.primaryFocusColor, t)!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      accentSoftColor: Color.lerp(accentSoftColor, other.accentSoftColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      hairlineColor: Color.lerp(hairlineColor, other.hairlineColor, t)!,
      hairlineStrongColor: Color.lerp(hairlineStrongColor, other.hairlineStrongColor, t)!,
      textPrimaryColor: Color.lerp(textPrimaryColor, other.textPrimaryColor, t)!,
      textMutedColor: Color.lerp(textMutedColor, other.textMutedColor, t)!,
      textSubtleColor: Color.lerp(textSubtleColor, other.textSubtleColor, t)!,
      surface1Color: Color.lerp(surface1Color, other.surface1Color, t)!,
      surface2Color: Color.lerp(surface2Color, other.surface2Color, t)!,
      surface3Color: Color.lerp(surface3Color, other.surface3Color, t)!,
      canvasColor: Color.lerp(canvasColor, other.canvasColor, t)!,
    );
  }
}

ThemeData getAxisTheme() {
  final bodyFont = AppTypography.bodyFamily;
  final displayFont = AppTypography.displayFamily;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: bodyFont,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.primaryFocus,
      onSecondary: AppColors.onPrimary,
      error: AppColors.error,
      onError: AppColors.onPrimary,
      surface: AppColors.surface1,
      onSurface: AppColors.ink,
      outline: AppColors.hairline,
    ),
    scaffoldBackgroundColor: AppColors.canvas,
    cardColor: AppColors.surface1,
    dialogBackgroundColor: AppColors.surface2,
    dividerColor: AppColors.hairline,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.canvas,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.getFont(
        displayFont,
        fontSize: AppTypography.headlineSize,
        fontWeight: FontWeight(AppTypography.headlineWeight),
        letterSpacing: AppTypography.headlineLetterSpacing,
        color: AppColors.ink,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.surface1,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        side: const BorderSide(color: AppColors.hairline, width: 1),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
        textStyle: GoogleFonts.getFont(bodyFont,
            fontSize: AppTypography.buttonSize,
            fontWeight: FontWeight(AppTypography.buttonWeight),
            letterSpacing: AppTypography.buttonLetterSpacing),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        backgroundColor: AppColors.surface1,
        side: const BorderSide(color: AppColors.hairline, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
        textStyle: GoogleFonts.getFont(bodyFont,
            fontSize: AppTypography.buttonSize,
            fontWeight: FontWeight(AppTypography.buttonWeight),
            letterSpacing: AppTypography.buttonLetterSpacing),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: AppColors.surface1,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: const BorderSide(color: AppColors.hairline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: const BorderSide(color: AppColors.hairline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: GoogleFonts.getFont(bodyFont,
          fontSize: AppTypography.bodySmSize,
          fontWeight: FontWeight(AppTypography.bodySmWeight),
          color: AppColors.inkSubtle),
      labelStyle: GoogleFonts.getFont(bodyFont,
          fontSize: AppTypography.bodySize,
          fontWeight: FontWeight(AppTypography.bodyWeight),
          color: AppColors.inkMuted),
      errorStyle: GoogleFonts.getFont(bodyFont,
          fontSize: AppTypography.bodySmSize,
          fontWeight: FontWeight(AppTypography.bodySmWeight),
          color: AppColors.error),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surface2,
      contentTextStyle: GoogleFonts.getFont(bodyFont,
          fontSize: AppTypography.bodySize,
          fontWeight: FontWeight(AppTypography.bodyWeight),
          color: AppColors.ink),
      actionTextColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
      behavior: SnackBarBehavior.floating,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusXl)),
    ),

    extensions: <ThemeExtension<AxisThemeExtension>>[
      const AxisThemeExtension(
        primaryColor: AppColors.primary,
        primaryHoverColor: AppColors.primaryHover,
        primaryFocusColor: AppColors.primaryFocus,
        accentColor: AppColors.accent,
        accentSoftColor: AppColors.accentSoft,
        successColor: AppColors.success,
        errorColor: AppColors.error,
        hairlineColor: AppColors.hairline,
        hairlineStrongColor: AppColors.hairlineStrong,
        textPrimaryColor: AppColors.ink,
        textMutedColor: AppColors.inkMuted,
        textSubtleColor: AppColors.inkSubtle,
        surface1Color: AppColors.surface1,
        surface2Color: AppColors.surface2,
        surface3Color: AppColors.surface3,
        canvasColor: AppColors.canvas,
      ),
    ],
  );
}

// Backward-compatible alias
ThemeData getFlowTheme() => getAxisTheme();

extension AxisTheme on BuildContext {
  AxisThemeExtension get axis => Theme.of(this).extension<AxisThemeExtension>()!;
}

// Backward-compatible alias
extension FlowTheme on BuildContext {
  AxisThemeExtension get flow => Theme.of(this).extension<AxisThemeExtension>()!;
}
