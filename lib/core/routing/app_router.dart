// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:axis/core/config/settings_providers.dart';
import 'package:axis/features/auth/presentation/screens/splash_screen.dart';
import 'package:axis/features/auth/presentation/screens/login_screen.dart';
import 'package:axis/features/auth/presentation/screens/register_screen.dart';
import 'package:axis/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:axis/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:axis/features/tasks/presentation/screens/home_screen.dart';
import 'package:axis/features/tasks/presentation/screens/calendar_screen.dart';
import 'package:axis/features/focus/presentation/screens/focus_screen.dart';
import 'package:axis/features/profile/presentation/screens/profile_screen.dart';
import 'package:axis/features/settings/presentation/screens/settings_screen.dart';
import 'package:axis/features/auth/application/auth_controller.dart';
import 'package:axis/features/categories/presentation/screens/categories_screen.dart';

class AppRouter {
  final WidgetRef ref;

  AppRouter(this.ref);

  GoRouter get router => _router;

  late final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _GoRouterRefreshStream(ref),
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      // Still loading initial auth state — let the splash screen handle navigation
      if (authState.isLoading) return null;

      final isAuthenticated = authState.asData?.value != null;
      final isOnboardingComplete = ref.read(onboardingCompleteProvider);

      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forgot-password') ||
          state.matchedLocation == '/splash';

      final isOnboardingRoute = state.matchedLocation == '/onboarding';

      if (!isOnboardingComplete && !isOnboardingRoute && !isAuthRoute) {
        return '/onboarding';
      }

      if (!isAuthenticated && !isAuthRoute && !isOnboardingRoute) {
        return '/login';
      }
      if (isAuthenticated && isAuthRoute) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
      GoRoute(path: '/focus', builder: (_, __) => const FocusScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/categories', builder: (_, __) => const CategoriesScreen()),
    ],
  );
}

/// Listens to both auth state and onboarding state changes to trigger router refreshes.
/// Uses a timer-based polling approach since WidgetRef.listen() returns void.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(this.ref) {
    // Listen to auth state changes - WidgetRef.listen returns void so we
    // just fire-and-forget. The listener stays active as long as this object exists.
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(onboardingCompleteProvider, (_, __) => notifyListeners());
  }

  final WidgetRef ref;
}
