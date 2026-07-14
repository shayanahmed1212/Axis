// Settings — new bento tokens, canvas bg, cardWhite cards
// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/config/app_config.dart';
import 'package:axis/core/config/settings_providers.dart';
import 'package:axis/core/utils/haptics.dart';
import 'package:axis/core/widgets/pressable.dart';
import 'package:axis/core/widgets/confirm_dialog.dart';
import 'package:axis/core/widgets/app_snackbar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hapticsEnabled = ref.watch(hapticsEnabledProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.sora(
            fontSize: AppTypography.screenTitleSize,
            fontWeight: FontWeight(AppTypography.screenTitleWeight),
            color: AppColors.ink,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: AppTokens.lg),

          // --- INTERACTIONS ---
          _SectionHeader(label: 'Interactions'),
          _CardSection(
            child: Column(
              children: [
                _SwitchTile(
                  title: 'Haptic Feedback',
                  subtitle: 'Vibration on interactions',
                  value: hapticsEnabled,
                  onChanged: (value) {
                    ref.read(hapticsEnabledProvider.notifier).set(value);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTokens.xl),

          // --- DATA ---
          _SectionHeader(label: 'Data'),
          _CardSection(
            child: Column(
              children: [
                _SettingsTile(
                  title: 'Export Tasks',
                  subtitle: 'Save tasks as CSV or JSON',
                  icon: Icons.file_download_outlined,
                  onTap: () => _showExportSheet(context, ref),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTokens.xl),

          // --- ABOUT ---
          _SectionHeader(label: 'About'),
          _CardSection(
            child: Column(
              children: [
                _InfoTile(title: 'App', value: AppConfig.appName),
                Divider(height: 1, indent: 52, color: AppColors.hairline),
                _InfoTile(title: 'Version', value: AppConfig.appVersion),
              ],
            ),
          ),

          const SizedBox(height: AppTokens.xl),

          // --- DANGER ZONE ---
          _SectionHeader(label: 'Danger Zone'),
          _CardSection(
            borderColor: AppColors.error.withOpacity(0.3),
            child: Column(
              children: [
                _SettingsTile(
                  title: 'Delete All Tasks',
                  subtitle: 'This cannot be undone',
                  icon: Icons.delete_forever_outlined,
                  iconColor: AppColors.error,
                  titleColor: AppColors.error,
                  onTap: () => _confirmDeleteAll(context, ref),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTokens.xxl),
        ],
      ),
    );
  }

  void _showExportSheet(BuildContext context, WidgetRef ref) {
    AppHaptics.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusLg)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppTokens.lg),
              Text(
                'Export Tasks',
                style: GoogleFonts.sora(
                  fontSize: AppTypography.sectionHeaderSize,
                  fontWeight: FontWeight(AppTypography.sectionHeaderWeight),
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: AppTokens.xl),
              Pressable(
                onTap: () {
                  AppHaptics.selectionClick();
                  Navigator.pop(ctx);
                  AppSnackbar.show(context, 'CSV export coming soon', type: SnackBarType.success);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTokens.lg),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.table_chart_outlined, color: AppColors.accent, size: 20),
                      const SizedBox(width: AppTokens.sm),
                      Text(
                        'Export as CSV',
                        style: GoogleFonts.inter(
                          fontSize: AppTypography.bodySize,
                          fontWeight: FontWeight(AppTypography.bodyWeight),
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.sm),
              Pressable(
                onTap: () {
                  AppHaptics.selectionClick();
                  Navigator.pop(ctx);
                  AppSnackbar.show(context, 'JSON export coming soon', type: SnackBarType.success);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTokens.lg),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.code_outlined, color: AppColors.accent, size: 20),
                      const SizedBox(width: AppTokens.sm),
                      Text(
                        'Export as JSON',
                        style: GoogleFonts.inter(
                          fontSize: AppTypography.bodySize,
                          fontWeight: FontWeight(AppTypography.bodyWeight),
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.sm),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context, WidgetRef ref) async {
    AppHaptics.mediumImpact();
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete All Tasks',
      message: 'This will permanently remove all your tasks. This action cannot be undone.',
      confirmLabel: 'Delete All',
    );
    if (confirmed == true) {
      AppSnackbar.show(context, 'Delete all tasks coming soon', type: SnackBarType.error);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: AppTypography.captionSize,
          fontWeight: FontWeight(AppTypography.captionWeight),
          letterSpacing: AppTypography.captionTracking,
          color: AppColors.inkMuted,
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final Widget child;
  final Color? borderColor;

  const _CardSection({required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTokens.lg, vertical: AppTokens.xs),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: borderColor ?? AppColors.hairline,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: child,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: AppTypography.bodySize,
          fontWeight: FontWeight(AppTypography.bodyWeight),
          color: AppColors.ink,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: AppTypography.captionSize,
          fontWeight: FontWeight(AppTypography.captionWeight),
          color: AppColors.inkMuted,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.accent,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppColors.inkMuted, size: 20),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: AppTypography.bodySize,
            fontWeight: FontWeight(AppTypography.bodyWeight),
            color: titleColor ?? AppColors.ink,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: AppTypography.captionSize,
            fontWeight: FontWeight(AppTypography.captionWeight),
            color: AppColors.inkMuted,
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: AppTypography.bodySize,
          fontWeight: FontWeight(AppTypography.bodyWeight),
          color: AppColors.ink,
        ),
      ),
      trailing: Text(
        value,
        style: GoogleFonts.inter(
          fontSize: AppTypography.captionSize,
          fontWeight: FontWeight(AppTypography.captionWeight),
          color: AppColors.inkMuted,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppTokens.lg),
    );
  }
}
