import 'package:flutter/material.dart';
import 'orbit_painter.dart';
import 'avatar_badge.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// The main orbit network visualization section.
///
/// Renders concentric orbit rings (via [OrbitPainter]) with a central profile
/// circle and two avatar badges positioned at connection nodes.
///
/// Design ref: 362 × 328 px section from Figma "Home v1".
class OrbitVisualization extends StatelessWidget {
  const OrbitVisualization({
    super.key,
    this.onCenterTap,
    this.onHmTap,
    this.onAkTap,
  });

  final VoidCallback? onCenterTap;
  final VoidCallback? onHmTap;
  final VoidCallback? onAkTap;

  // Canvas dimensions matching the orbit SVG group in Figma
  static const _designW = 390.95;
  static const _designH = 279.14;

  // Display width matches the content column width (362px)
  static const _displayW = 362.0;
  static const _displayH = _displayW * _designH / _designW; // ~258px
  static const _sectionH = 290.0;

  // Node coordinates in design space (from Figma)
  static const _hmX = 57.98;
  static const _hmY = 45.26;
  static const _akX = 225.39;
  static const _akY = 204.84;
  static const _centerX = _designW / 2; // ~195.5
  static const _centerY = _designH / 2; // ~139.5

  // Avatar badge size
  static const _badgeSize = 38.0;
  static const _profileSize = 54.0;
  static const _topPad = (_sectionH - _displayH) / 2;

  double _toScreenX(double designX) => designX * (_displayW / _designW);
  double _toScreenY(double designY) => _topPad + designY * (_displayH / _designH);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _displayW,
      height: _sectionH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Layer 1: ghost orbit texture (25% opacity — matching Figma overlay)
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: CustomPaint(
                painter: const OrbitPainter(opacity: 1.0),
              ),
            ),
          ),

          // Layer 2: main orbit lines at full opacity
          Positioned.fill(
            child: CustomPaint(
              painter: const OrbitPainter(opacity: 1.0),
            ),
          ),

          // Layer 3: center profile circle (tappable — user's own profile)
          Positioned(
            left: _toScreenX(_centerX) - _profileSize / 2,
            top: _toScreenY(_centerY) - _profileSize / 2,
            child: GestureDetector(
              onTap: onCenterTap,
              child: _ProfileCircle(),
            ),
          ),

          // Layer 4: HM avatar badge (tappable)
          Positioned(
            left: _toScreenX(_hmX) - _badgeSize / 2,
            top: _toScreenY(_hmY) - _badgeSize / 2,
            child: GestureDetector(
              onTap: onHmTap,
              child: const AvatarBadge(
                initials: 'HM',
                size: _badgeSize,
                strokeWidth: 2.5,
              ),
            ),
          ),

          // Layer 5: AK avatar badge (tappable)
          Positioned(
            left: _toScreenX(_akX) - _badgeSize / 2,
            top: _toScreenY(_akY) - _badgeSize / 2,
            child: GestureDetector(
              onTap: onAkTap,
              child: const AvatarBadge(
                initials: 'AK',
                size: _badgeSize,
                strokeWidth: 2.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: OrbitVisualization._profileSize,
      height: OrbitVisualization._profileSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.avatarFill,
        border: Border.all(color: AppColors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'You',
        style: AppTextStyles.avatarInitials12.copyWith(fontSize: 11),
      ),
    );
  }
}
