// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:axis/features/auth/presentation/screens/splash_screen.dart';
import 'package:axis/features/auth/presentation/screens/login_screen.dart';
import 'package:axis/features/auth/presentation/screens/register_screen.dart';
import 'package:axis/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:axis/features/tasks/presentation/screens/dashboard_screen.dart';
import 'package:axis/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:axis/features/tasks/presentation/screens/task_form_screen.dart';
import 'package:axis/profile/presentation/screens/profile_screen.dart';
import 'package:axis/features/settings/presentation/screens/settings_screen.dart';
import 'package:axis/features/auth/application/auth_controller.dart';
import 'package:axis/features/onboarding/presentation/screens/onboarding_screen.dart';

class AppRouter {
  final WidgetRef ref;

  AppRouter(this.ref);

  GoRouter get router => _router;

  late final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthStateNotifier(ref),
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.asData?.value != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forgot-password') ||
          state.matchedLocation == '/splash';

      final isOnboardingRoute = state.matchedLocation == '/onboarding';

      if (!isAuthenticated && !isAuthRoute && !isOnboardingRoute) {
        return '/login';
      }
      if (isAuthenticated && isAuthRoute) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/task/new', builder: (_, __) => const TaskFormScreen()),
      GoRoute(path: '/task/:id', builder: (_, state) => TaskDetailScreen(taskId: state.pathParameters['id']!)),
      GoRoute(path: '/task/edit/:id', builder: (_, state) => TaskFormScreen(taskId: state.pathParameters['id'])),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );
}

class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(this.ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }

  final WidgetRef ref;
}