// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/config/app_config.dart';
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
        title: Text(
          'Profile',
          style: GoogleFonts.getFont(
            AppTypography.bodyFamily,
            fontSize: AppTypography.cardTitleSize,
            fontWeight: FontWeight(AppTypography.cardTitleWeight),
            color: AppColors.ink,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.surface2,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (user?.email ?? 'U')[0].toUpperCase(),
                      style: GoogleFonts.getFont(
                        AppTypography.displayFamily,
                        fontSize: 32,
                        fontWeight: FontWeight(AppTypography.displayWeight),
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (user?.displayName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      user!.displayName!,
                      style: GoogleFonts.getFont(
                        AppTypography.displayFamily,
                        fontSize: AppTypography.headlineSize,
                        fontWeight: FontWeight(AppTypography.headlineWeight),
                        letterSpacing: AppTypography.headlineLetterSpacing,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                Text(
                  user?.email ?? 'No email',
                  style: GoogleFonts.getFont(
                    AppTypography.bodyFamily,
                    fontSize: AppTypography.bodySize,
                    fontWeight: FontWeight(AppTypography.bodyWeight),
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface1,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.hairline, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'App Version',
                        style: GoogleFonts.getFont(
                          AppTypography.bodyFamily,
                          fontSize: AppTypography.bodySize,
                          fontWeight: FontWeight(AppTypography.bodyWeight),
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        AppConfig.appVersion,
                        style: GoogleFonts.getFont(
                          AppTypography.bodyFamily,
                          fontSize: AppTypography.bodySize,
                          fontWeight: FontWeight(AppTypography.bodyWeight),
                          color: AppColors.inkSubtle,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref.read(authControllerProvider).signOut();
                        if (context.mounted) context.go('/login');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to logout: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Logout',
                      style: GoogleFonts.getFont(
                        AppTypography.bodyFamily,
                        fontSize: AppTypography.buttonSize,
                        fontWeight: FontWeight(AppTypography.buttonWeight),
                        letterSpacing: AppTypography.buttonLetterSpacing,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
