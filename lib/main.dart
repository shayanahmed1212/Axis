// App entry point. Initialises Firebase, SharedPreferences, and the
// persistent notification engine before entering the widget tree so all
// providers have their dependencies ready. The [ProviderScope] enables
// Riverpod's scoped-provider resolution across the entire widget subtree.
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'app_router.dart';
import 'services/settings_providers.dart';
import 'services/notification_service.dart';
import 'services/notification_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    if (details.exception is PlatformException) {
      return;
    }
    FlutterError.dumpErrorToConsole(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (error is PlatformException) {
      return true;
    }
    return false;
  };

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initSettings();
  await NotificationService.init();
  runApp(const ProviderScope(child: AxisApp()));
}

class AxisApp extends ConsumerWidget {
  const AxisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Warm up the notification provider so it starts listening to tasks
    ref.watch(taskNotificationProvider);

    final router = AppRouter(ref).router;
    final accentColorName = ref.watch(accentColorProvider);
    final fontFamily = ref.watch(typographyProvider);
    final localeCode = ref.watch(localeCodeProvider);
    final accentColor = accentColorFromName(accentColorName);

    return MaterialApp.router(
      title: 'Axis',
      debugShowCheckedModeBanner: false,
      theme: getAxisTheme(accentColor: accentColor, fontFamily: fontFamily),
      locale: AppLocalizations.localeFromCode(localeCode),
      supportedLocales: const [Locale('en'), Locale('ur')],
      localizationsDelegates: const [],
      routerConfig: router,
    );
  }
}
