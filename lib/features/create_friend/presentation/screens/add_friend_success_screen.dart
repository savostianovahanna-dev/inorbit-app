import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Shown after the user completes all 3 steps of the "Add Friend" flow.
/// Figma: node 58-6490 "Create friend / successfully create"
class AddFriendSuccessScreen extends StatelessWidget {
  const AddFriendSuccessScreen({super.key, required this.friendName});

  final String friendName;

  /// Extract the first word of the name ("Anna Kallin" → "Anna").
  String get _firstName {
    final parts = friendName.trim().split(' ');
    return parts.isNotEmpty ? parts.first : friendName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Top spacing (image at y=126 from frame top, safe-area ~53px → ~73px gap)
            const SizedBox(height: 73),

            // ── Photo / avatar card  (361×282, borderRadius 32) ──────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ProfileCard(firstName: _firstName),
            ),

            // ── Gap between card and text (444 - 408 = 36px in Figma) ─────────
            const SizedBox(height: 36),

            // ── Text + button container ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Title: "Anna is in your orbit"
                  Text(
                    '$_firstName is in your orbit',
                    style: AppTextStyles.successTitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    "We'll remind you to connect in 2 weeks",
                    style: AppTextStyles.bodyRegular16.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.50),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // "Go to the orbit" button
                  _GoToOrbitButton(
                    onTap: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile card ─────────────────────────────────────────────────────────────

/// Rounded card (361×282, r=32) with a gradient background, orbit rings,
/// and a centered avatar initial — mirrors the friend photo in Figma.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 282,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.avatarFill, AppColors.orbitDark],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ── Decorative orbit rings ────────────────────────────────────────
          const Positioned.fill(child: _OrbitRingsPainterWidget()),

          // ── Centered avatar circle with first initial ─────────────────────
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  firstName.isNotEmpty
                      ? firstName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),

          // ── Subtle bottom gradient overlay ────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws concentric, semi-transparent circle rings using CustomPainter.
class _OrbitRingsPainterWidget extends StatelessWidget {
  const _OrbitRingsPainterWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _OrbitRingsPainter());
  }
}

class _OrbitRingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final r in [60.0, 110.0, 165.0, 225.0]) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbitRingsPainter old) => false;
}

// ─── "Go to the orbit" button ─────────────────────────────────────────────────

class _GoToOrbitButton extends StatelessWidget {
  const _GoToOrbitButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          // rgba(17,17,17,0.75) from Figma
          color: const Color(0xFF111111).withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 30,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Go to the orbit',
            style: AppTextStyles.logButtonLabel,
          ),
        ),
      ),
    );
  }
}
