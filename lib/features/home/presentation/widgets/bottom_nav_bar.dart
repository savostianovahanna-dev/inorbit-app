import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

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
          height: 76 + bottomPad,
          padding: EdgeInsets.only(bottom: bottomPad),
          decoration: const BoxDecoration(
            // Semi-transparent to let blur show through
            color: Color(0xD9F5F5F7),
            border: Border(
              top: BorderSide(color: AppColors.navBorder, width: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _NavItem(
                icon: _OrbitIcon(),
                label: 'Orbit',
                isActive: activeTab == NavTab.orbit,
                onTap: () => onTabChanged(NavTab.orbit),
              ),
              _NavItem(
                icon: _StatsIcon(),
                label: 'Stats',
                isActive: activeTab == NavTab.stats,
                onTap: () => onTabChanged(NavTab.stats),
              ),
              _NavItem(
                icon: _SettingsIcon(),
                label: 'Settings',
                isActive: activeTab == NavTab.settings,
                onTap: () => onTabChanged(NavTab.settings),
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
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final Widget icon;
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
        padding: isActive
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: isActive
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
            icon,
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

// --- Custom icons drawn with CustomPaint to avoid any icon font dependency ---

class _OrbitIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _OrbitIconPainter()),
    );
  }
}

class _OrbitIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    // Outer ellipse
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width * 0.95, height: size.height * 0.55),
      paint,
    );
    // Inner ellipse (rotated feel)
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width * 0.55, height: size.height * 0.95),
      paint,
    );
    // Center dot
    canvas.drawCircle(center, 2.5, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_OrbitIconPainter old) => false;
}

class _StatsIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _StatsIconPainter()),
    );
  }
}

class _StatsIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary
      ..style = PaintingStyle.fill;

    final barW = size.width / 5;
    final gap = barW * 0.5;
    final bars = [0.45, 0.70, 1.0, 0.60];

    for (var i = 0; i < bars.length; i++) {
      final x = (barW + gap) * i + gap / 2;
      final h = size.height * bars[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - h, barW, h),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StatsIconPainter old) => false;
}

class _SettingsIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _SettingsIconPainter()),
    );
  }
}

class _SettingsIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    // Outer gear circle
    canvas.drawCircle(center, size.width * 0.38, paint);
    // Inner circle (the "hole")
    canvas.drawCircle(center, size.width * 0.18, paint);
    // Three tick marks around the gear
    paint.strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final angle = i * 3.14159 / 3;
      final r1 = size.width * 0.38;
      final r2 = size.width * 0.48;
      canvas.drawLine(
        Offset(center.dx + r1 * _cos(angle), center.dy + r1 * _sin(angle)),
        Offset(center.dx + r2 * _cos(angle), center.dy + r2 * _sin(angle)),
        paint,
      );
    }
  }

  double _cos(double a) => a == 0 ? 1 : (a == 3.14159 ? -1 : (a < 2 ? 0.5 : (a < 4 ? -0.5 : 0.5)));
  double _sin(double a) => (a == 0 ? 0 : (a == 3.14159 ? 0 : (a < 2 ? 0.866 : (a < 4 ? 0.866 : -0.866))));

  @override
  bool shouldRepaint(_SettingsIconPainter old) => false;
}
