// Minimal two-locale string map for English and Urdu.
// Add new keys here and reference them via [AppLocalizations.of(localeCode).key].
import 'package:flutter/material.dart';

class AppLocalizations {
  final String localeCode;

  const AppLocalizations(this.localeCode);

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'settings': 'Settings',
      'change_app_color': 'Change app color',
      'change_app_typography': 'Change app typography',
      'change_app_language': 'Change app language',
      'import_from_google_calendar': 'Import from Google Calendar',
      'choose_accent_color': 'Choose Accent Color',
      'choose_typography': 'Choose Typography',
      'choose_language': 'Choose Language',
      'import': 'Import',
    },
    'ur': {
      'settings': 'ترتیبات',
      'change_app_color': 'ایپ کا رنگ تبدیل کریں',
      'change_app_typography': 'ٹائپوگرافی تبدیل کریں',
      'change_app_language': 'زبان تبدیل کریں',
      'import_from_google_calendar': 'Google کیلنڈر سے درآمد کریں',
      'choose_accent_color': 'ایکسنٹ رنگ منتخب کریں',
      'choose_typography': 'ٹائپوگرافی منتخب کریں',
      'choose_language': 'زبان منتخب کریں',
      'import': 'درآمد',
    },
  };

  static AppLocalizations of(String localeCode) => AppLocalizations(localeCode);

  String get settings => _get('settings');
  String get changeAppColor => _get('change_app_color');
  String get changeAppTypography => _get('change_app_typography');
  String get changeAppLanguage => _get('change_app_language');
  String get importFromGoogleCalendar => _get('import_from_google_calendar');
  String get chooseAccentColor => _get('choose_accent_color');
  String get chooseTypography => _get('choose_typography');
  String get chooseLanguage => _get('choose_language');
  String get import => _get('import');

  String _get(String key) =>
      _strings[localeCode]?[key] ?? _strings['en']?[key] ?? key;

  static Locale localeFromCode(String code) {
    switch (code) {
      case 'ur': return const Locale('ur');
      default:   return const Locale('en');
    }
  }
}
