// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

ThemeData getAxisTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppTypography.fontFamily,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.primary,
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
      inversePrimary: AppColors.primary,
      shadow: Colors.black,
      scrim: Colors.black87,
      surfaceTint: AppColors.primary,
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
        backgroundColor: AppColors.primary,
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
        foregroundColor: AppColors.primary,
        backgroundColor: Colors.transparent,
        disabledForegroundColor: AppColors.inkMuted,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg, vertical: AppTokens.md),
        side: const BorderSide(color: AppColors.primary, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        textStyle: AppTypography.buttonLabel(color: AppColors.primary),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.inkMuted,
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.md, vertical: AppTokens.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        textStyle: AppTypography.buttonLabel(color: AppColors.primary),
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
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
      actionTextColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusSm)),
      behavior: SnackBarBehavior.floating,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceCard,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.inkMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: AppTypography.meta(weight: 500, color: AppColors.primary),
      unselectedLabelStyle: AppTypography.meta(color: AppColors.inkMuted),
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.inkMuted,
      indicatorColor: AppColors.primary,
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
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      shape: const CircleBorder(),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.hairline,
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
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
