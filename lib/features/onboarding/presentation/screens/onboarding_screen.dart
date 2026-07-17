// Onboarding Carousel — Uses provided illustration PNGs from assets/images/onboarding/
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    if (mounted) context.go('/login');
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
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.canvasDark,
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
              return _OnboardingPage(
                index: index,
                currentPage: _currentPage,
              );
            },
          ),

          // Skip button — top-left
          Positioned(
            top: topPadding + AppTokens.xs,
            left: AppTokens.lg,
            child: Pressable(
              onTap: _skip,
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.xs),
                child: Text(
                  'SKIP',
                  style: AppTypography.meta(color: AppColors.inkMuted),
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
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.lg,
                  0,
                  AppTokens.lg,
                  AppTokens.xxl,
                ),
                child: Row(
                  children: [
                    // BACK button — hidden on first slide
                    if (_currentPage > 0)
                      Pressable(
                        onTap: () {
                          _pageController.previousPage(
                            duration: reduceMotion
                                ? Duration.zero
                                : const Duration(milliseconds: AppTokens.durationSlow),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppTokens.sm, horizontal: AppTokens.sm),
                          child: Text(
                            'BACK',
                            style: AppTypography.buttonLabel(color: AppColors.inkMuted),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 60),

                    const Spacer(),

                    // NEXT / GET STARTED button
                    SizedBox(
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
                        child: Text(
                          _currentPage < 2 ? 'NEXT' : 'GET STARTED',
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
  final int currentPage;
  const _OnboardingPage({required this.index, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    final String imagePath;
    final String title;
    final String subtitle;

    switch (index) {
      case 0:
        imagePath = 'assets/images/onboarding/onboarding_1.png';
        title = 'Welcome to Axis';
        subtitle = 'Organize your life with clarity and focus';
        break;
      case 1:
        imagePath = 'assets/images/onboarding/onboarding_2.png';
        title = 'Stay Focused';
        subtitle = 'Track priorities, deadlines, and progress';
        break;
      case 2:
        imagePath = 'assets/images/onboarding/onboarding_3.png';
        title = 'Your Data, Your Control';
        subtitle = 'Private, secure, and always in sync';
        break;
      default:
        imagePath = 'assets/images/onboarding/onboarding_1.png';
        title = '';
        subtitle = '';
    }

    return Container(
      color: AppColors.canvasDark,
      child: Column(
        children: [
          // Illustration — upper ~55%
          Expanded(
            flex: 6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Dot indicator
          Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final isActive = i == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: AppTokens.durationNormal),
                  margin: const EdgeInsets.symmetric(horizontal: AppTokens.xxs),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.hairline,
                    borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  ),
                );
              }),
            ),
          ),

          // Headline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
            child: Text(
              title,
              style: AppTypography.onboardingHeadline(color: AppColors.ink),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: AppTokens.sm),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.body(color: AppColors.inkMuted),
            ),
          ),

          // Bottom spacer for controls
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
