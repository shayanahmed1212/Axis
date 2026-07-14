import 'package:flutter/services.dart';

/// Centralized haptic feedback for Axis.
/// Each method maps to a specific interaction type.
class AppHaptics {
  /// Light tick — checkbox toggle, chip selection, swipe threshold crossing
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Subtle impact — button press, successful save
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact — delete confirmation, significant action
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Error feedback — failed action
  static void error() {
    HapticFeedback.heavyImpact();
  }
}
