// Profile Screen — Avatar, stats, flat menu groups, logout
// ignore_for_file: unnecessary_underscores, prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:axis/core/errors/app_exception.dart';
import 'package:axis/core/services/storage_service.dart';
import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/widgets/bottom_nav_bar.dart';
import 'package:axis/features/auth/application/auth_controller.dart';
import 'package:axis/features/categories/data/category_repository.dart';
import 'package:axis/features/tasks/application/task_providers.dart';
import 'package:axis/features/tasks/presentation/screens/add_task_sheet.dart';
import 'package:axis/widgets/dialogs/custom_category_picker.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.asData?.value;
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      backgroundColor: AppColors.canvasDark,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppTokens.pageMargin),
          children: [
            // ── Avatar ──
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.surfaceCard,
                    backgroundImage: user?.photoURL != null
                        ? _imageProvider(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? Icon(Icons.person_rounded,
                            size: 50, color: AppColors.ink)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.camera_alt_rounded,
                          size: 16, color: AppColors.onPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.lg),
            // ── Display Name ──
            Center(
              child: Text(
                user?.displayName ?? 'User',
                style: AppTypography.taskTitle(
                    color: AppColors.ink, weight: 600),
              ),
            ),
            const SizedBox(height: AppTokens.xl),
            // ── Stats Pills ──
            tasksAsync.when(
              data: (tasks) {
                final active =
                    tasks.where((t) => !t.isCompleted).length;
                final completed =
                    tasks.where((t) => t.isCompleted).length;
                return Row(
                  children: [
                    Expanded(
                      child: _StatPill(
                          label:
                              '$active task${active != 1 ? 's' : ''} left'),
                    ),
                    const SizedBox(width: AppTokens.sm),
                    Expanded(
                      child: _StatPill(
                          label:
                              '$completed task${completed != 1 ? 's' : ''} done'),
                    ),
                  ],
                );
              },
              loading: () => Row(
                children: [
                  Expanded(child: _StatPill(label: '—')),
                  const SizedBox(width: AppTokens.sm),
                  Expanded(child: _StatPill(label: '—')),
                ],
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppTokens.xxl + AppTokens.xs),
            // ── Settings ──
            _SectionHeader(label: 'Settings'),
            _SettingsRow(
              icon: Icons.category_outlined,
              label: 'Manage Categories',
              onTap: () => _showCategoryPicker(context, ref),
            ),
            const SizedBox(height: AppTokens.xs),
            _SettingsRow(
              icon: Icons.settings_outlined,
              label: 'App Settings',
              onTap: () => context.push('/settings'),
            ),
            const SizedBox(height: AppTokens.xl),
            // ── Account ──
            _SectionHeader(label: 'Account'),
            _SettingsRow(
              icon: Icons.person_outline,
              label: 'Change account name',
              onTap: () => _showChangeNameDialog(context, ref),
            ),
            const SizedBox(height: AppTokens.xs),
            _SettingsRow(
              icon: Icons.lock_outline,
              label: 'Change account password',
              onTap: () => _showChangePasswordDialog(context, ref),
            ),
            const SizedBox(height: AppTokens.xs),
            _SettingsRow(
              icon: Icons.image_outlined,
              label: 'Change account Image',
              onTap: () => _showChangeImageSheet(context, ref),
            ),
            const SizedBox(height: AppTokens.xl),
            // ── Axis ──
            _SectionHeader(label: 'Axis'),
            _SettingsRow(
              icon: Icons.info_outline,
              label: 'About US',
              onTap: () => _showComingSoon(context, 'About US'),
            ),
            const SizedBox(height: AppTokens.xs),
            _SettingsRow(
              icon: Icons.help_outline,
              label: 'FAQ',
              onTap: () => _showComingSoon(context, 'FAQ'),
            ),
            const SizedBox(height: AppTokens.xs),
            _SettingsRow(
              icon: Icons.feedback_outlined,
              label: 'Help & Feedback',
              onTap: () => _showComingSoon(context, 'Help & Feedback'),
            ),
            const SizedBox(height: AppTokens.xs),
            _SettingsRow(
              icon: Icons.favorite_outline,
              label: 'Support US',
              onTap: () => _showComingSoon(context, 'Support US'),
            ),
            const SizedBox(height: AppTokens.xxl + AppTokens.xl),
            // ── Logout ──
            _SettingsRow(
              icon: Icons.logout_rounded,
              label: 'Log out',
              isDestructive: true,
              onTap: () => _showLogoutConfirmation(context, ref),
            ),
            const SizedBox(height: AppTokens.xxl),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/calendar'); break;
            case 2: context.go('/focus'); break;
            case 3: break;
          }
        },
        onFabTap: () => AddTaskSheet.show(
          context: context,
          categories: const [],
          onSave: (task) async {
            try {
              final repo = ref.read(taskRepositoryProvider);
              await repo.createTask(task);
            } on AppException catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.message)),
              );
            }
          },
        ),
      ),
    );
  }

  ImageProvider _imageProvider(String url) {
    if (url.startsWith('data:image')) {
      final parts = url.split(',');
      if (parts.length > 1) {
        return MemoryImage(base64Decode(parts[1]));
      }
    }
    return NetworkImage(url);
  }

  void _showCategoryPicker(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.read(categoriesStreamProvider);
    categoriesAsync.whenData((cats) {
      showCustomCategoryPicker(
        context: context,
        categories: cats,
        currentSelection: null,
      );
    });
  }

  void _showChangeNameDialog(BuildContext context, WidgetRef ref) {
    final currentName =
        ref.read(authStateProvider).asData?.value?.displayName ?? '';
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        title: Text('Change Name',
            style: AppTypography.sheetTitle(color: AppColors.ink)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTypography.body(color: AppColors.ink),
          decoration: const InputDecoration(
            hintText: 'Enter new name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTypography.buttonLabel(
                    color: AppColors.inkMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await ref
                    .read(authControllerProvider)
                    .updateDisplayName(name);
                _showSnackBar(context, 'Name updated successfully');
              } on Exception catch (e) {
                _showSnackBar(context, 'Failed to update name: $e');
              }
            },
            child:
                Text('Edit', style: AppTypography.buttonLabel()),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(
      BuildContext context, WidgetRef ref) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        title: Text('Change Password',
            style: AppTypography.sheetTitle(color: AppColors.ink)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                style: AppTypography.body(color: AppColors.ink),
                decoration: const InputDecoration(
                  hintText: 'Current password',
                ),
              ),
              SizedBox(height: AppTokens.sm),
              TextField(
                controller: newController,
                obscureText: true,
                style: AppTypography.body(color: AppColors.ink),
                decoration: const InputDecoration(
                  hintText: 'New password',
                ),
              ),
              SizedBox(height: AppTokens.sm),
              TextField(
                controller: confirmController,
                obscureText: true,
                style: AppTypography.body(color: AppColors.ink),
                decoration: const InputDecoration(
                  hintText: 'Confirm new password',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTypography.buttonLabel(
                    color: AppColors.inkMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final current = currentController.text.trim();
              final newPw = newController.text.trim();
              final confirm = confirmController.text.trim();
              if (current.isEmpty ||
                  newPw.isEmpty ||
                  confirm.isEmpty) {
                _showSnackBar(context, 'All fields are required');
                return;
              }
              if (newPw != confirm) {
                _showSnackBar(
                    context, 'New passwords do not match');
                return;
              }
              if (newPw.length < 6) {
                _showSnackBar(context,
                    'Password must be at least 6 characters');
                return;
              }
              Navigator.pop(ctx);
              try {
                await ref
                    .read(authControllerProvider)
                    .changePassword(current, newPw);
                _showSnackBar(
                    context, 'Password updated successfully');
              } on Exception catch (e) {
                _showSnackBar(
                    context, 'Failed to change password: $e');
              }
            },
            child: Text('Edit',
                style: AppTypography.buttonLabel()),
          ),
        ],
      ),
    );
  }

  void _showChangeImageSheet(
      BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          AppTokens.pageMargin,
          AppTokens.xl,
          AppTokens.pageMargin,
          AppTokens.xl,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTokens.radiusLg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadImage(
                    context, ref, ImageSource.camera);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppTokens.md),
                child: Text('Take picture',
                    style: AppTypography.body(
                        color: AppColors.ink)),
              ),
            ),
            Divider(height: 1, color: AppColors.hairline),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadImage(
                    context, ref, ImageSource.gallery);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppTokens.md),
                child: Text('Import from gallery',
                    style: AppTypography.body(
                        color: AppColors.ink)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(BuildContext context,
      WidgetRef ref, ImageSource source) async {
    try {
      final storage = StorageService();
      final picked = await storage.pickImage(source);
      if (picked == null) return;

      _showSnackBar(context, 'Updating image...');

      final b64 = await storage.imageToBase64(picked);
      await ref
          .read(authControllerProvider)
          .updatePhotoURL(b64);

      _showSnackBar(context, 'Profile image updated');
    } on Exception catch (e) {
      _showSnackBar(context, 'Failed to update image: $e');
    }
  }

  void _showLogoutConfirmation(
      BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        title: Text('Log Out',
            style: AppTypography.sheetTitle(color: AppColors.ink)),
        content: Text('Are you sure you want to log out?',
            style: AppTypography.body(color: AppColors.ink)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTypography.buttonLabel(
                    color: AppColors.inkMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authControllerProvider).signOut();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: Text('Log Out',
                style: AppTypography.buttonLabel()),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    _showSnackBar(context, '$feature coming soon');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: AppTypography.body(color: AppColors.ink)),
        backgroundColor: AppColors.surfaceCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppTokens.radiusSm)),
      ),
    );
  }
}

// ================== Private Widgets ==================

class _StatPill extends StatelessWidget {
  final String label;
  const _StatPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppTokens.sm, horizontal: AppTokens.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTypography.body(
              color: AppColors.inkMuted, weight: 500),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.sm),
      child: Text(
        label,
        style: AppTypography.sectionLabel(color: AppColors.inkMuted),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? AppColors.error : AppColors.ink;
    final iconColor =
        isDestructive ? AppColors.error : AppColors.inkMuted;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.xxs, vertical: AppTokens.sm),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: AppTokens.md),
            Expanded(
              child: Text(label,
                  style: AppTypography.body(color: color)),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.inkFaint, size: 20),
          ],
        ),
      ),
    );
  }
}


