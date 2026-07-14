// Onboarding — block color hero panels, accent dots, Sora titles
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/core/config/settings_providers.dart';
import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/widgets/pressable.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingCompleteProvider.notifier).complete();
    if (mounted) context.go('/dashboard');
  }

  void _skip() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: AppTokens.durationSlow),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: 3,
            physics: reduceMotion
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return _OnboardingPage(index: index);
            },
          ),

          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + AppTokens.xs,
            right: AppTokens.lg,
            child: Pressable(
              onTap: _skip,
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.xs),
                child: Text(
                  'Skip',
                  style: GoogleFonts.inter(
                    fontSize: AppTypography.captionSize,
                    fontWeight: FontWeight(AppTypography.captionWeight),
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.lg,
                  vertical: AppTokens.xxl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page dots — accent when active
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: reduceMotion
                              ? Duration.zero
                              : const Duration(milliseconds: AppTokens.durationNormal),
                          margin: const EdgeInsets.symmetric(horizontal: AppTokens.xxs),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.accent : AppColors.hairline,
                            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: AppTokens.xxl),

                    // Action button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _currentPage < 2
                            ? () {
                                _pageController.nextPage(
                                  duration: reduceMotion
                                      ? Duration.zero
                                      : const Duration(milliseconds: AppTokens.durationSlow),
                                  curve: Curves.easeOut,
                                );
                              }
                            : _completeOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.accentInk,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                          ),
                        ),
                        child: Text(
                          _currentPage < 2 ? 'Continue' : 'Get Started',
                          style: GoogleFonts.inter(
                            fontSize: AppTypography.buttonSize,
                            fontWeight: FontWeight(AppTypography.buttonWeight),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final int index;
  const _OnboardingPage({required this.index});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final String title;
    final String subtitle;
    final Color bgColor;
    final Color textColor;

    switch (index) {
      case 0:
        icon = Icons.check_circle_outline_rounded;
        title = 'Welcome to Axis';
        subtitle = 'Organize your tasks with clarity';
        bgColor = AppColors.blockLavender;
        textColor = AppColors.blockLavenderText;
        break;
      case 1:
        icon = Icons.trending_up_rounded;
        title = 'Stay Focused';
        subtitle = 'Track priorities and deadlines';
        bgColor = AppColors.blockSage;
        textColor = AppColors.blockSageText;
        break;
      case 2:
        icon = Icons.shield_outlined;
        title = 'Your Data, Your Control';
        subtitle = 'Private, secure, and always in sync';
        bgColor = AppColors.blockSky;
        textColor = AppColors.blockSkyText;
        break;
      default:
        icon = Icons.check_circle_outline_rounded;
        title = '';
        subtitle = '';
        bgColor = AppColors.blockLavender;
        textColor = AppColors.blockLavenderText;
    }

    return Container(
      color: AppColors.canvas,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Block color hero card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTokens.xxl),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(AppTokens.radiusXl),
                ),
                child: Column(
                  children: [
                    Icon(icon, size: 64, color: textColor),
                    const SizedBox(height: AppTokens.lg),
                    Text(
                      title,
                      style: GoogleFonts.sora(
                        fontSize: AppTypography.screenTitleSize,
                        fontWeight: FontWeight(AppTypography.screenTitleWeight),
                        letterSpacing: AppTypography.screenTitleTracking,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: AppTokens.sm),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: AppTypography.bodySize,
                        fontWeight: FontWeight(AppTypography.bodyWeight),
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
