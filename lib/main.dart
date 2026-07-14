import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/config/settings_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initSettings();
  runApp(const ProviderScope(child: AxisApp()));
}

class AxisApp extends ConsumerWidget {
  const AxisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = AppRouter(ref).router;

    return MaterialApp.router(
      title: 'Axis',
      debugShowCheckedModeBanner: false,
      theme: getAxisTheme(),
      routerConfig: router,
    );
  }
}
