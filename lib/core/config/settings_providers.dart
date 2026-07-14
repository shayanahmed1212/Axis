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
  OnboardingCompleteNotifier() : super(_sharedPrefs.getBool('onboardingComplete') ?? false);

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
  HapticsEnabledNotifier() : super(_sharedPrefs.getBool('hapticsEnabled') ?? true);

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
  AppearanceModeNotifier() : super(
    AppearanceMode.values[(_sharedPrefs.getInt('appearanceMode') ?? 0).clamp(0, 2)]
  );

  Future<void> set(AppearanceMode mode) async {
    state = mode;
    await _sharedPrefs.setInt('appearanceMode', mode.index);
  }
}
