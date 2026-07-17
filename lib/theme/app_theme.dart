// Design-token system — colours, spacing, radii, typography, and the
// Material [ThemeData] factory.
//
// [AppColors] defines the full palette. Category colors (`catGrocery` ..)
// are used as both category badge fills and the dot-picker palette in
// [CreateCategorySheet]. [AppTokens] centralises every layout constant
// so visual tweaks don't require hunting through 20+ files.
//
// [AppTypography] builds [TextStyle]s via `GoogleFonts.getFont()` with
// sensible defaults per role (screenTitle, taskTitle, body, meta, etc.)
// — callers override only what differs.
//
// [getAxisTheme] wires everything into a [ThemeData] that the Material
// `App.router` uses as its base theme. Every sub-theme (buttons, inputs,
// dialogs, snackbars, etc.) is explicitly configured to inherit the
// dark palette rather than relying on Material defaults. It accepts an
// optional [accentColor] and [fontFamily] so the accent/typography
// settings in [SettingsScreen] take effect immediately.
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const Color catGrocery = Color(0xFF66BB6A);
  static const Color catWork = Color(0xFFFFA726);
  static const Color catSport = Color(0xFF26C6DA);
  static const Color catDesign = Color(0xFFEC407A);
  static const Color catUniversity = Color(0xFF8687E7);
  static const Color catSocial = Color(0xFFEF5350);
  static const Color catMusic = Color(0xFFAB47BC);
  static const Color catHealth = Color(0xFF42A5F5);
  static const Color catMovie = Color(0xFFFFCA28);
  static const Color catHome = Color(0xFF8D6E63);

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

class AppTokens {
  // Radius
  static const double radiusSm = 12;     // cards, fields, buttons, category tiles
  static const double radiusLg = 20;     // bottom sheets top corners
  static const double radiusPill = 9999;

  // Spacing — base unit 4px
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  // Page
  static const double pageMargin = 20;
  static const double cardPadding = 16;

  // Bottom sheet
  static const double sheetTopRadius = 20;
  static const double sheetDragHandleWidth = 36;
  static const double sheetDragHandleHeight = 4;

  // Motion durations (ms)
  static const int durationFast = 140;
  static const int durationNormal = 200;
  static const int durationSlow = 300;

  // Backward-compatible aliases
  static const double radiusMd = radiusSm;
  static const double radiusCard = radiusSm;
  static const double radiusButton = radiusSm;
  static const double radiusSheet = radiusLg;
  static const double pageMarginHorizontal = pageMargin;
  static const double sheetPadding = pageMargin;
  static const double bottomNavHeight = 100;
  static const double bentoGap = sm;
  static const double shadowCardWhite = 8;
  static const double shadowBlack = 16;
  static const double shadowAccent = 12;
}

class AppTypography {
  static String fontFamily = 'Inter';

  // Onboarding headline — 22px / 700
  static const double onboardingHeadlineSize = 22;
  static const int onboardingHeadlineWeight = 700;
  // Screen title ("Index", "Calendar") — 20px / 700
  static const double screenTitleSize = 20;
  static const int screenTitleWeight = 700;

  // Task title — 14px / 600
  static const double taskTitleSize = 14;
  static const int taskTitleWeight = 600;

  // Body / field input text — 14px / 400
  static const double bodySize = 14;
  static const int bodyWeight = 400;

  // Secondary / meta — 12px / 500
  static const double metaSize = 12;
  static const int metaWeight = 500;

  // Button label — 15px / 500
  static const double buttonSize = 15;
  static const int buttonWeight = 500;

  // Section label (e.g. "Settings", "Account") — 13px / 600
  static const double sectionLabelSize = 13;
  static const int sectionLabelWeight = 600;

  static TextStyle onboardingHeadline({
    double? size,
    int? weight,
    Color? color,
  }) {
    return GoogleFonts.getFont(
      fontFamily,
      fontSize: size ?? onboardingHeadlineSize,
      fontWeight: FontWeight(weight ?? onboardingHeadlineWeight),
      color: color,
    );
  }

  static TextStyle screenTitle({
    double? size,
    int? weight,
    Color? color,
  }) {
    return GoogleFonts.getFont(
      fontFamily,
      fontSize: size ?? screenTitleSize,
      fontWeight: FontWeight(weight ?? screenTitleWeight),
      color: color,
    );
  }

  static TextStyle taskTitle({
    double? size,
    int? weight,
    Color? color,
  }) {
    return GoogleFonts.getFont(
      fontFamily,
      fontSize: size ?? taskTitleSize,
      fontWeight: FontWeight(weight ?? taskTitleWeight),
      color: color,
    );
  }

  static TextStyle cardTitle({
    double? size,
    int? weight,
    Color? color,
  }) {
    return GoogleFonts.getFont(
      fontFamily,
      fontSize: size ?? taskTitleSize,
      fontWeight: FontWeight(weight ?? taskTitleWeight),
      color: color,
    );
  }

  static TextStyle body({
    double? size,
    int? weight,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.getFont(
      fontFamily,
      fontSize: size ?? bodySize,
      fontWeight: FontWeight(weight ?? bodyWeight),
      letterSpacing: letterSpacing ?? 0,
      color: color,
    );
  }

  static TextStyle meta({
    double? size,
    int? weight,
    Color? color,
  }) {
    return GoogleFonts.getFont(
      fontFamily,
      fontSize: size ?? metaSize,
      fontWeight: FontWeight(weight ?? metaWeight),
      color: color,
    );
  }

  static TextStyle buttonLabel({
    double? size,
    int? weight,
    Color? color,
  }) {
    return GoogleFonts.getFont(
      fontFamily,
      fontSize: size ?? buttonSize,
      fontWeight: FontWeight(weight ?? buttonWeight),
      color: color,
    );
  }

  static TextStyle sectionLabel({
    double? size,
    int? weight,
    Color? color,
  }) {
    return GoogleFonts.getFont(
      fontFamily,
      fontSize: size ?? sectionLabelSize,
      fontWeight: FontWeight(weight ?? sectionLabelWeight),
      color: color,
    );
  }

  static TextStyle sheetTitle({
    double? size,
    int? weight,
    Color? color,
  }) {
    return GoogleFonts.getFont(
      fontFamily,
      fontSize: size ?? 18,
      fontWeight: FontWeight(weight ?? 600),
      color: color,
    );
  }
}

ThemeData getAxisTheme({
  Color accentColor = AppColors.primary,
  String fontFamily = 'Inter',
}) {
  AppTypography.fontFamily = fontFamily;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: fontFamily,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: accentColor,
      onPrimary: AppColors.onPrimary,
      secondary: accentColor,
      onSecondary: AppColors.onPrimary,
      error: AppColors.error,
      onError: AppColors.onPrimary,
      surface: AppColors.surfaceCard,
      onSurface: AppColors.ink,
      outline: AppColors.hairline,
      surfaceContainerHighest: AppColors.surfaceCardAlt,
      surfaceContainer: AppColors.surfaceCard,
      surfaceContainerLow: AppColors.canvasDark,
      surfaceContainerLowest: AppColors.canvasDark,
      inverseSurface: AppColors.ink,
      onInverseSurface: AppColors.canvasDark,
      inversePrimary: accentColor,
      shadow: Colors.black,
      scrim: Colors.black87,
      surfaceTint: accentColor,
    ),
    scaffoldBackgroundColor: AppColors.canvasDark,
    cardColor: AppColors.surfaceCard,
    dividerColor: AppColors.hairline,
    canvasColor: AppColors.canvasDark,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.canvasDark,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTypography.screenTitle(color: AppColors.ink),
    ),

    cardTheme: CardThemeData(
      color: AppColors.surfaceCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: AppColors.primaryDim,
        disabledForegroundColor: AppColors.inkMuted,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg, vertical: AppTokens.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        textStyle: AppTypography.buttonLabel(color: AppColors.onPrimary),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        backgroundColor: Colors.transparent,
        disabledForegroundColor: AppColors.inkMuted,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg, vertical: AppTokens.md),
        side: BorderSide(color: accentColor, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        textStyle: AppTypography.buttonLabel(color: accentColor),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        disabledForegroundColor: AppColors.inkMuted,
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.md, vertical: AppTokens.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        textStyle: AppTypography.buttonLabel(color: accentColor),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppTokens.md, vertical: AppTokens.md),
      filled: true,
      fillColor: AppColors.surfaceCard,
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
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: AppTypography.meta(color: AppColors.inkMuted),
      labelStyle: AppTypography.meta(color: AppColors.inkMuted),
      errorStyle: AppTypography.meta(color: AppColors.error),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surfaceCard,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusLg)),
      ),
      modalBackgroundColor: AppColors.surfaceCard,
      dragHandleColor: AppColors.hairline,
      dragHandleSize: const Size(36, 4),
      showDragHandle: true,
      constraints: const BoxConstraints(minHeight: 100),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      titleTextStyle: AppTypography.sheetTitle(color: AppColors.ink),
      contentTextStyle: AppTypography.body(color: AppColors.ink),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceCard,
      contentTextStyle: AppTypography.body(color: AppColors.ink),
      actionTextColor: accentColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusSm)),
      behavior: SnackBarBehavior.floating,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceCard,
      selectedItemColor: accentColor,
      unselectedItemColor: AppColors.inkMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: AppTypography.meta(weight: 500, color: accentColor),
      unselectedLabelStyle: AppTypography.meta(color: AppColors.inkMuted),
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: accentColor,
      unselectedLabelColor: AppColors.inkMuted,
      indicatorColor: accentColor,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: AppTypography.meta(weight: 500),
      unselectedLabelStyle: AppTypography.meta(),
      dividerColor: Colors.transparent,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceCardAlt,
      selectedColor: AppColors.primaryDim,
      disabledColor: AppColors.surfaceCardAlt,
      labelStyle: AppTypography.body(color: AppColors.ink),
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.sm, vertical: AppTokens.xxs),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusPill)),
      side: const BorderSide(color: AppColors.hairline, width: 1),
      brightness: Brightness.dark,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      shape: const CircleBorder(),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: accentColor,
      linearTrackColor: AppColors.hairline,
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return accentColor;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.onPrimary),
      side: const BorderSide(color: AppColors.hairline, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: AppColors.primaryDim,
      iconColor: AppColors.inkMuted,
      textColor: AppColors.ink,
      titleTextStyle: AppTypography.body(),
      subtitleTextStyle: AppTypography.meta(color: AppColors.inkMuted),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusSm)),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppTokens.md, vertical: AppTokens.xs),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.hairline,
      thickness: 1,
      space: 1,
    ),
  );
}

ThemeData getFlowTheme() => getAxisTheme();
