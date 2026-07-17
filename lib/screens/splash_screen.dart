// Premium animated splash screen with a branded scale+fade entrance.
// Runs a 2.5s minimum lifecycle while initialisation checks settle,
// then routes to onboarding (first launch), the home screen (signed-in,
// onboarded), or login (signed-out). The native splash layer has already
// been replaced via [flutter_native_splash] so there is zero white flash
// during engine boot.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/theme/app_theme.dart';
import 'package:axis/services/settings_providers.dart';
import 'package:axis/services/auth_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(curved);
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(curved);

    _controller.forward();
    _startNavigationTimer();
  }

  Future<void> _startNavigationTimer() async {
    await Future<void>.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    final authState = ref.read(authStateProvider);
    final user = authState.asData?.value;
    final onboardingComplete = ref.read(onboardingCompleteProvider);

    if (user != null && onboardingComplete) {
      context.go('/');
    } else if (user != null) {
      context.go('/onboarding');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    border: Border.all(color: AppColors.primary, width: 2.5),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.onPrimary,
                    size: 48,
                  ),
                ),
                const SizedBox(height: AppTokens.md),
                Text(
                  'AXIS',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 8.0,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
