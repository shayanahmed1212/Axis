// Three-page onboarding carousel with skip/back/next controls.
// Completion is persisted via [onboardingCompleteProvider] so it only
// shows once per install. Respects `disableAnimations` accessibility
// setting by switching to instant page transitions.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:axis/services/settings_providers.dart';
import 'package:axis/theme/app_theme.dart';
import 'package:axis/widgets/ui_elements.dart';

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
    _completeOnboarding();
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
        title = 'Manage your tasks';
        subtitle = 'You can easily manage all of your daily tasks in Axis for free.';
        break;
      case 1:
        imagePath = 'assets/images/onboarding/onboarding_2.png';
        title = 'Create daily routine';
        subtitle = 'In Axis you can create your personalized routine to stay productive.';
        break;
      case 2:
        imagePath = 'assets/images/onboarding/onboarding_3.png';
        title = 'Organize your tasks';
        subtitle = 'You can organize your daily tasks by adding your tasks into separate categories.';
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
