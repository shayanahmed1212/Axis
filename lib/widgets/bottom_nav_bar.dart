// Four-tab bottom navigation bar with a centred floating-action button.
// The FAB either shows (when [onFabTap] is provided) or the bar renders
// as a simple row of four icons. The extra left/right padding on tabs 1
// and 2 makes room for the overhanging FAB circle.
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:axis/theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onFabTap;
  final IconData fabIcon;
  final double height;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onFabTap,
    this.fabIcon = Icons.add_rounded,
    this.height = AppTokens.bottomNavHeight,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'Index'),
      _NavItem(icon: Icons.calendar_month_rounded, label: 'Calendar'),
      _NavItem(icon: Icons.access_time_rounded, label: 'Focus'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];

    if (onFabTap != null) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.navBar,
          border: Border(top: BorderSide(color: AppColors.hairline, width: 0.5)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = currentIndex == index;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == 1 ? 24 : 0,
                      left: index == 2 ? 24 : 0,
                    ),
                    child: InkWell(
                      onTap: () => onTap(index),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          Icon(
                            item.icon,
                            color: isSelected ? AppColors.primary : AppColors.inkMuted,
                            size: 24,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: AppTypography.meta(
                              color: isSelected ? AppColors.primary : AppColors.inkMuted,
                              weight: isSelected ? 500 : 400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            Positioned(
              top: -28,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: onFabTap,
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(fabIcon, color: AppColors.onPrimary, size: 32),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.navBar,
        border: Border(top: BorderSide(color: AppColors.hairline, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = currentIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Icon(item.icon, color: isSelected ? AppColors.primary : AppColors.inkMuted, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: AppTypography.meta(
                      color: isSelected ? AppColors.primary : AppColors.inkMuted,
                      weight: isSelected ? 500 : 400,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
