// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/config/app_config.dart';
import 'package:axis/core/utils/haptics.dart';
import 'package:axis/core/widgets/floating_bottom_nav.dart';
import 'package:axis/features/auth/application/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.chevron_left_rounded, size: 28), onPressed: () => context.go('/dashboard')),
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          final email = user?.email ?? '';
          final displayName = (user?.displayName != null && user!.displayName!.isNotEmpty)
              ? user.displayName!
              : (email.isNotEmpty ? email.split('@').first : 'User');
          final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.pageMargin),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: AppTypography.display(size: 28, weight: 700, color: AppColors.accentInk),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(displayName, style: AppTypography.display(size: 20, weight: 700, color: AppColors.ink)),
                const SizedBox(height: 4),
                Text(email, style: AppTypography.body(size: 13, weight: 400, color: AppColors.inkMuted)),
                const SizedBox(height: 32),

                // Account card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.blockBlack,
                    borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                    boxShadow: AppTokens.shadowBlack,
                  ),
                  child: Column(
                    children: const [
                      _AccountRow(label: 'App', value: AppConfig.appName),
                      Divider(height: 1, color: AppColors.hairlineOnDark, indent: 20, endIndent: 20),
                      _AccountRow(label: 'Version', value: 'v${AppConfig.appVersion}'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Sign Out — outlined, not filled
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () async {
                      AppHaptics.mediumImpact();
                      try {
                        await ref.read(authControllerProvider).signOut();
                        if (context.mounted) context.go('/login');
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusPill)),
                    ),
                    child: Text('Sign Out', style: AppTypography.body(size: AppTypography.buttonSize, weight: AppTypography.buttonWeight, color: AppColors.error)),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: FloatingBottomNav(
        currentTab: NavTab.profile,
        onTabChanged: (tab) {
          if (tab == NavTab.home) context.go('/dashboard');
        },
        onCreateTask: () => context.push('/task/new'),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final String label;
  final String value;
  const _AccountRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body(size: 14, weight: 400, color: AppColors.inkOnDark)),
          Text(value, style: AppTypography.body(size: 13, weight: 500, color: AppColors.inkMutedOnDark)),
        ],
      ),
    );
  }
}
