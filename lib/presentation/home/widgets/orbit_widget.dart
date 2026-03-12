import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/friend.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

/// Tilt applied to all rings (–15° counter-clockwise).
const _kTilt = -math.pi / 12;

class _RingSpec {
  const _RingSpec({
    required this.tier,
    required this.rxFactor, // radius-x as a fraction of container width
    required this.ry,       // radius-y in logical pixels (fixed)
    required this.seconds,  // seconds for one full orbit
  });
  final String tier;
  final double rxFactor;
  final double ry;
  final int seconds;
}

const _kRings = [
  _RingSpec(tier: 'inner_circle', rxFactor: 0.145, ry: 33, seconds: 20),
  _RingSpec(tier: 'regulars',     rxFactor: 0.265, ry: 59, seconds: 35),
  _RingSpec(tier: 'casuals',      rxFactor: 0.400, ry: 85, seconds: 50),
];

const _kAvatarSize   = 36.0; // friend avatars
const _kUserSize     = 44.0; // center user avatar
const _kContainerH   = 220.0;

// ─── Widget ───────────────────────────────────────────────────────────────────

class OrbitWidget extends StatefulWidget {
  const OrbitWidget({
    super.key,
    required this.friends,
    this.userAvatarPath,
    required this.userInitials,
  });

  final List<Friend> friends;
  final String? userAvatarPath;
  final String userInitials;

  @override
  State<OrbitWidget> createState() => _OrbitWidgetState();
}

class _OrbitWidgetState extends State<OrbitWidget>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final Listenable _merged;

  @override
  void initState() {
    super.initState();
    _controllers = [
      for (final ring in _kRings)
        AnimationController(
          vsync: this,
          duration: Duration(seconds: ring.seconds),
        )..repeat(),
    ];
    _merged = Listenable.merge(_controllers);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder is outside AnimatedBuilder so constraints are read once,
    // not on every animation frame.
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cx = w / 2;
        const cy = _kContainerH / 2;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: w,
            height: _kContainerH,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // ── Layer 1: background image ──────────────────────────────
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      // Fallback colour when image is missing
                      color: Color(0xFF0F1B2D),
                      image: DecorationImage(
                        image: AssetImage('assets/images/home.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // ── Layer 2: rings (static, redrawn only on resize) ────────
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RingsPainter(containerWidth: w),
                  ),
                ),

                // ── Layer 3: friend avatars (animated every frame) ─────────
                AnimatedBuilder(
                  animation: _merged,
                  builder: (context, _) => Stack(
                    children: [
                      for (int i = 0; i < _kRings.length; i++)
                        ..._friendAvatars(
                          ring: _kRings[i],
                          cx: cx,
                          cy: cy,
                          containerWidth: w,
                          t: _controllers[i].value,
                        ),
                    ],
                  ),
                ),

                // ── Layer 4: center user avatar (static) ───────────────────
                Positioned(
                  left: cx - _kUserSize / 2,
                  top: cy - _kUserSize / 2,
                  child: _UserAvatar(
                    initials: widget.userInitials,
                    avatarPath: widget.userAvatarPath,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Friend avatar positioning ──────────────────────────────────────────────

  List<Widget> _friendAvatars({
    required _RingSpec ring,
    required double cx,
    required double cy,
    required double containerWidth,
    required double t, // 0.0 → 1.0 animation progress
  }) {
    final friends =
        widget.friends.where((f) => f.orbitTier == ring.tier).toList();
    if (friends.isEmpty) return const [];

    final rx   = containerWidth * ring.rxFactor;
    final ry   = ring.ry;
    final n    = friends.length;
    final cosT = math.cos(_kTilt);
    final sinT = math.sin(_kTilt);
    final half = _kAvatarSize / 2;

    return [
      for (int i = 0; i < n; i++)
        () {
          // Evenly distribute on the ring, then advance by animation progress.
          final angle = i * (2 * math.pi / n) + t * 2 * math.pi;

          // Point on the un-tilted ellipse.
          final ex = rx * math.cos(angle);
          final ey = ry * math.sin(angle);

          // Rotate by _kTilt so the ellipse appears tilted.
          final px = cx + ex * cosT - ey * sinT;
          final py = cy + ex * sinT + ey * cosT;

          return Positioned(
            left: px - half,
            top:  py - half,
            child: _FriendAvatar(
              initials:  _initials(friends[i].name),
              isOverdue: friends[i].isOverdue,
            ),
          );
        }(),
    ];
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Returns up to two-letter initials from a display name.
String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
}

// ─── CustomPainter ────────────────────────────────────────────────────────────

/// Draws the three tilted elliptical orbit rings at 15 % white opacity.
/// Static — only repaints when container width changes.
class _RingsPainter extends CustomPainter {
  const _RingsPainter({required this.containerWidth});

  final double containerWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Translate to center, rotate, draw, restore.
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(_kTilt);

    for (final ring in _kRings) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width:  containerWidth * ring.rxFactor * 2,
          height: ring.ry * 2,
        ),
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.containerWidth != containerWidth;
}

// ─── Avatars ──────────────────────────────────────────────────────────────────

class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar({
    required this.initials,
    required this.isOverdue,
  });

  final String initials;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kAvatarSize,
      height: _kAvatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E3A6E),
        border: Border.all(
          // Orange ring for friends who need attention.
          color: isOverdue ? AppColors.orange : AppColors.white,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(initials, style: AppTextStyles.avatarInitials12),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({
    required this.initials,
    this.avatarPath,
  });

  final String initials;
  final String? avatarPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kUserSize,
      height: _kUserSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E3A6E),
        border: Border.all(color: AppColors.white, width: 2.5),
        // avatarPath is a local file path (from image_picker), not an asset.
        image: avatarPath != null
            ? DecorationImage(
                image: FileImage(File(avatarPath!)),
                fit: BoxFit.cover,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: avatarPath == null
          ? Text(initials, style: AppTextStyles.avatarInitials12)
          : null,
    );
  }
}
