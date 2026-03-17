import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../extensions/context_extensions.dart';

/// Shared bottom navigation bar for MindScrolling.
///
/// Used by Feed, Insights, and any other tab-host screen.
/// Pass [currentIndex] to highlight the active tab.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: context.tr.feed,
            isActive: currentIndex == 0,
            onTap: () => context.go('/feed'),
          ),
          _NavItem(
            icon: Icons.bookmark_border,
            activeIcon: Icons.bookmark,
            label: context.tr.vault,
            isActive: currentIndex == 1,
            onTap: () => context.push('/vault'),
          ),
          _NavItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            label: context.tr.map,
            isActive: currentIndex == 2,
            onTap: () => context.push('/philosophy-map'),
          ),
          _NavItem(
            icon: Icons.auto_awesome_outlined,
            activeIcon: Icons.auto_awesome,
            label: context.tr.insight,
            isActive: currentIndex == 3,
            activeColor: AppColors.philosophy,
            onTap: () => context.push('/insights'),
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: context.tr.settings,
            isActive: currentIndex == 4,
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeColor,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? (activeColor ?? AppColors.stoicism)
        : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.caption.copyWith(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
