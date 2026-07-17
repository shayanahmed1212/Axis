// SharedPreferences-backed settings providers for onboarding state,
// haptics toggle, appearance mode, accent color, typography, and locale.
// Each is a [StateNotifierProvider] that persists immediately on change
// so the user's preference survives app restarts.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppearanceMode { system, light, dark }

late SharedPreferences _sharedPrefs;

Future<void> initSettings() async {
  _sharedPrefs = await SharedPreferences.getInstance();
}

// --- Onboarding ---
final onboardingCompleteProvider =
    StateNotifierProvider<OnboardingCompleteNotifier, bool>((ref) {
  return OnboardingCompleteNotifier();
});

class OnboardingCompleteNotifier extends StateNotifier<bool> {
  OnboardingCompleteNotifier()
      : super(_sharedPrefs.getBool('onboardingComplete') ?? false);

  Future<void> complete() async {
    state = true;
    await _sharedPrefs.setBool('onboardingComplete', true);
  }
}

// --- Haptics ---
final hapticsEnabledProvider =
    StateNotifierProvider<HapticsEnabledNotifier, bool>((ref) {
  return HapticsEnabledNotifier();
});

class HapticsEnabledNotifier extends StateNotifier<bool> {
  HapticsEnabledNotifier()
      : super(_sharedPrefs.getBool('hapticsEnabled') ?? true);

  Future<void> toggle() async {
    state = !state;
    await _sharedPrefs.setBool('hapticsEnabled', state);
  }

  Future<void> set(bool value) async {
    state = value;
    await _sharedPrefs.setBool('hapticsEnabled', value);
  }
}

// --- Appearance ---
final appearanceModeProvider =
    StateNotifierProvider<AppearanceModeNotifier, AppearanceMode>((ref) {
  return AppearanceModeNotifier();
});

class AppearanceModeNotifier extends StateNotifier<AppearanceMode> {
  AppearanceModeNotifier()
      : super(AppearanceMode.values[
            (_sharedPrefs.getInt('appearanceMode') ?? 0).clamp(0, 2)]);

  Future<void> set(AppearanceMode mode) async {
    state = mode;
    await _sharedPrefs.setInt('appearanceMode', mode.index);
  }
}

// --- Accent Color ---
final accentColorProvider =
    StateNotifierProvider<AccentColorNotifier, String>((ref) {
  return AccentColorNotifier();
});

class AccentColorNotifier extends StateNotifier<String> {
  AccentColorNotifier()
      : super(_sharedPrefs.getString('accentColor') ?? 'Purple');

  Future<void> set(String colorName) async {
    state = colorName;
    await _sharedPrefs.setString('accentColor', colorName);
  }
}

/// Maps an accent color name to its [Color] value.
Color accentColorFromName(String name) {
  switch (name) {
    case 'Purple':   return const Color(0xFF8687E7);
    case 'Blue':     return const Color(0xFF4D96FF);
    case 'Teal':     return const Color(0xFF4ECDC4);
    case 'Pink':     return const Color(0xFFFF6B9D);
    case 'Orange':   return const Color(0xFFFF9F43);
    case 'Green':    return const Color(0xFF6BCB77);
    default:         return const Color(0xFF8687E7);
  }
}

// --- Typography ---
final typographyProvider =
    StateNotifierProvider<TypographyNotifier, String>((ref) {
  return TypographyNotifier();
});

class TypographyNotifier extends StateNotifier<String> {
  TypographyNotifier()
      : super(_sharedPrefs.getString('typography') ?? 'Inter');

  Future<void> set(String family) async {
    state = family;
    await _sharedPrefs.setString('typography', family);
  }
}

// --- Locale ---
final localeCodeProvider =
    StateNotifierProvider<LocaleCodeNotifier, String>((ref) {
  return LocaleCodeNotifier();
});

class LocaleCodeNotifier extends StateNotifier<String> {
  LocaleCodeNotifier()
      : super(_sharedPrefs.getString('localeCode') ?? 'en');

  Future<void> set(String code) async {
    state = code;
    await _sharedPrefs.setString('localeCode', code);
  }
}
