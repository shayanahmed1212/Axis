// Floating Bottom Navigation — black pill bar with embedded FAB
import 'package:flutter/material.dart';
import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/utils/haptics.dart';

enum NavTab { home, search, notifications, profile }

class FloatingBottomNav extends StatelessWidget {
  final NavTab currentTab;
  final ValueChanged<NavTab> onTabChanged;
  final VoidCallback onCreateTask;

  const FloatingBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
    required this.onCreateTask,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 16),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.blockBlack,
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          boxShadow: AppTokens.shadowBlack,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavIcon(
              icon: Icons.home_rounded,
              isActive: currentTab == NavTab.home,
              onTap: () { AppHaptics.selectionClick(); onTabChanged(NavTab.home); },
            ),
            _NavIcon(
              icon: Icons.search_rounded,
              isActive: currentTab == NavTab.search,
              onTap: () { AppHaptics.selectionClick(); onTabChanged(NavTab.search); },
            ),
            // Embedded FAB
            GestureDetector(
              onTap: () { AppHaptics.mediumImpact(); onCreateTask(); },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: AppTokens.shadowAccent,
                ),
                child: const Icon(Icons.add_rounded, size: 26, color: AppColors.accentInk),
              ),
            ),
            _NavIcon(
              icon: Icons.notifications_outlined,
              isActive: currentTab == NavTab.notifications,
              onTap: () { AppHaptics.selectionClick(); onTabChanged(NavTab.notifications); },
            ),
            _NavIcon(
              icon: Icons.person_outline_rounded,
              isActive: currentTab == NavTab.profile,
              onTap: () { AppHaptics.selectionClick(); onTabChanged(NavTab.profile); },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavIcon({required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.accent : AppColors.inkMutedOnDark,
            ),
            if (isActive) ...[
              const SizedBox(height: 3),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
