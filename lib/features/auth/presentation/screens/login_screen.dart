import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';

/// Login screen — Figma node 40-1669.
/// Dark (#181B21) background with main photo, orbit rings SVG,
/// InOrbit logo, tagline, and two auth buttons.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF181B21),
      body: Stack(
        children: [
          // ── Main photo (bleeds past top, rounded bottom) ──────────────────
          Positioned(
            top: -42,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 676,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/onboarding1.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // ── Gradient overlay: photo fades into dark bg ────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.28, 0.58],
                  colors: [Colors.transparent, Color(0xFF181B21)],
                ),
              ),
            ),
          ),

          // ── Orbit rings SVG (decorative, offset to the left) ─────────────
          Positioned(
            left: -59,
            top: 0,
            child: SvgPicture.asset(
              'assets/orbits.svg',
              width: 507.5,
              height: 532.59,
            ),
          ),

          // ── Foreground content ────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Flex space above logo — keeps logo at ~28% from top on any screen
                const Spacer(flex: 5),

                // InOrbit logo with orbit rings + title text
                SvgPicture.asset(
                  'assets/login_with_title.svg',
                  width: 210,
                ),

                // Flex space between logo and tagline (~18% of available height)
                const Spacer(flex: 4),

                // Tagline (~y=481 in Figma frame)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Stay close to the people\nwho matter most',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium16.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: -0.80,
                      height: 1.2,
                    ),
                  ),
                ),

                // Flex space between tagline and buttons
                const Spacer(flex: 2),

                // ── Buttons + terms (~y=620 in Figma frame) ──────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _AuthButton(
                        icon: const _AppleIcon(),
                        label: 'Continue with Apple',
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OnboardingScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _AuthButton(
                        icon: const _GoogleIcon(),
                        label: 'Continue with Google',
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OnboardingScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),

                      // Terms of Service line
                      Text(
                        'Terms of Service and Privacy',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelRegular14.copyWith(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 0.5,
                          height: 1.5,
                        ),
                      ),

                      // Home indicator space
                      SizedBox(height: 34 + bottomPad),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Auth button ──────────────────────────────────────────────────────────────
/// Full-width button with button_background.png texture + dark overlay.

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 30,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background texture image
              Positioned.fill(
                child: Image.asset(
                  'assets/button_background.png',
                  fit: BoxFit.cover,
                ),
              ),

              // Dark semi-transparent overlay: rgba(17,17,17,0.75)
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0xFF111111).withValues(alpha: 0.75),
                ),
              ),

              // Icon + label row (centred)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20, height: 20, child: icon),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium16.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Apple icon (20×20, white filled) ────────────────────────────────────────

class _AppleIcon extends StatelessWidget {
  const _AppleIcon();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _AppleIconPainter());
}

class _AppleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;

    // Leaf / stem
    final leaf = Path()
      ..moveTo(w * 0.50, h * 0.22)
      ..cubicTo(w * 0.52, h * 0.02, w * 0.76, h * 0.04, w * 0.70, h * 0.20)
      ..cubicTo(w * 0.62, h * 0.26, w * 0.48, h * 0.26, w * 0.50, h * 0.22)
      ..close();
    canvas.drawPath(leaf, p);

    // Body
    final body = Path()
      ..moveTo(w * 0.50, h * 0.28)
      ..cubicTo(w * 0.27, h * 0.28, w * 0.06, h * 0.40, w * 0.06, h * 0.64)
      ..cubicTo(w * 0.06, h * 0.83, w * 0.20, h * 0.98, w * 0.38, h * 0.98)
      ..cubicTo(w * 0.44, h * 0.96, w * 0.50, h * 0.92, w * 0.56, h * 0.95)
      ..cubicTo(w * 0.62, h * 0.98, w * 0.68, h * 0.98, w * 0.72, h * 0.95)
      ..cubicTo(w * 0.90, h * 0.88, w * 0.94, h * 0.70, w * 0.94, h * 0.64)
      ..cubicTo(w * 0.94, h * 0.40, w * 0.73, h * 0.28, w * 0.50, h * 0.28)
      ..close();
    canvas.drawPath(body, p);
  }

  @override
  bool shouldRepaint(_AppleIconPainter old) => false;
}

// ─── Google icon (20×20, white 'G' stroke) ───────────────────────────────────

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GoogleIconPainter());
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.42;

    final sp = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.11
      ..strokeCap = StrokeCap.round;

    // Arc — open on the right, starts at ~20° goes ~320°
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.35,
      math.pi * 1.80,
      false,
      sp,
    );

    // Horizontal bar of G
    canvas.drawLine(
      center,
      Offset(center.dx + radius, center.dy),
      sp,
    );

    // Short downward tick at the right end of the bar
    canvas.drawLine(
      Offset(center.dx + radius, center.dy),
      Offset(center.dx + radius, center.dy + radius * 0.44),
      sp,
    );
  }

  @override
  bool shouldRepaint(_GoogleIconPainter old) => false;
}
