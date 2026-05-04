import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inorbit/core/shared/shared_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

enum NavTab { orbit, stats, settings }

/// Bottom navigation bar with animated active-pill indicator.
/// Active tab shows a white pill background with icon + label.
/// Inactive tabs show icon + label only.
class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  final NavTab activeTab;
  final ValueChanged<NavTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 54 + bottomPad,
          padding: EdgeInsets.only(bottom: bottomPad),
          decoration: const BoxDecoration(
            // Semi-transparent to let blur show through
            color: Color(0xD9F5F5F7),
            border: Border(
              top: BorderSide(color: AppColors.navBorder, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: _NavItem(
                    iconPath: SharedIcons.navBarOrbit,
                    label: 'Orbit',
                    isActive: activeTab == NavTab.orbit,
                    onTap: () => onTabChanged(NavTab.orbit),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: _NavItem(
                    iconPath: SharedIcons.navBarStats,
                    label: 'Stats',
                    isActive: activeTab == NavTab.stats,
                    onTap: () => onTabChanged(NavTab.stats),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: _NavItem(
                    iconPath: SharedIcons.navBarSettings,
                    label: 'Settings',
                    isActive: activeTab == NavTab.settings,
                    onTap: () => onTabChanged(NavTab.settings),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.iconPath,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding:
            isActive
                ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration:
            isActive
                ? BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
                : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(iconPath, width: 20, height: 20),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.navLabelActive),
            ] else ...[
              const SizedBox(width: 4),
              Text(label, style: AppTextStyles.navLabel),
            ],
          ],
        ),
      ),
    );
  }
}
