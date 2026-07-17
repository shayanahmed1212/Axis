import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static const String fontFamily = 'Inter';

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
    return GoogleFonts.inter(
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
    return GoogleFonts.inter(
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
    return GoogleFonts.inter(
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
    return GoogleFonts.inter(
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
    return GoogleFonts.inter(
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
    return GoogleFonts.inter(
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
    return GoogleFonts.inter(
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
    return GoogleFonts.inter(
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
    return GoogleFonts.inter(
      fontSize: size ?? 18,
      fontWeight: FontWeight(weight ?? 600),
      color: color,
    );
  }
}
