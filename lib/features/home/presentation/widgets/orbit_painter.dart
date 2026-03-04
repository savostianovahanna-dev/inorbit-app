import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Draws the concentric orbit ring visualization.
///
/// Design reference: 390.95 × 279.14 px orbit group from Figma.
/// All coordinates are expressed as fractions of the design dimensions
/// and scaled proportionally to the actual canvas size.
class OrbitPainter extends CustomPainter {
  const OrbitPainter({this.opacity = 1.0});

  final double opacity;

  // Design reference dimensions
  static const _dW = 390.95;
  static const _dH = 279.14;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / _dW;
    final scaleY = size.height / _dH;

    final center = Offset(size.width / 2, size.height / 2);

    // --- Ring paint ---
    final ringPaint = Paint()
      ..color = AppColors.orbitDark.withValues(alpha: opacity * 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Ring 1 — innermost
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 70 * scaleX, height: 54 * scaleY),
      ringPaint,
    );

    // Ring 2
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 145 * scaleX, height: 106 * scaleY),
      ringPaint,
    );

    // Ring 3
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 240 * scaleX, height: 175 * scaleY),
      ringPaint,
    );

    // Ring 4 — outermost
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 360 * scaleX, height: 265 * scaleY),
      ringPaint,
    );

    // --- Connector lines from center to node positions ---
    // Node "HM": Figma (57.98, 45.26) in the orbit group
    // Node "AK": Figma (225.39, 204.84)
    final hmNode = Offset(57.98 * scaleX, 45.26 * scaleY);
    final akNode = Offset(225.39 * scaleX, 204.84 * scaleY);

    final linePaint = Paint()
      ..color = AppColors.orbitDark.withValues(alpha: opacity * 0.12)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, hmNode, linePaint);
    canvas.drawLine(center, akNode, linePaint);

    // Additional subtle lines for visual richness
    final extraNodes = [
      _pointOnEllipse(center, 180 * scaleX / 2, 130 * scaleY / 2, -0.7),
      _pointOnEllipse(center, 240 * scaleX / 2, 175 * scaleY / 2, 1.2),
      _pointOnEllipse(center, 145 * scaleX / 2, 106 * scaleY / 2, 2.5),
    ];
    for (final node in extraNodes) {
      canvas.drawLine(center, node, linePaint);
    }

    // --- Small dots at node positions ---
    final dotPaint = Paint()
      ..color = AppColors.orbitDark.withValues(alpha: opacity * 0.35)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(hmNode, 3.5, dotPaint);
    canvas.drawCircle(akNode, 3.5, dotPaint);
    for (final node in extraNodes) {
      canvas.drawCircle(node, 2.5, dotPaint);
    }

    // --- Center dot ---
    final centerDotPaint = Paint()
      ..color = AppColors.orbitDark.withValues(alpha: opacity * 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.0, centerDotPaint);
  }

  Offset _pointOnEllipse(Offset center, double rx, double ry, double angle) {
    return Offset(
      center.dx + rx * math.cos(angle),
      center.dy + ry * math.sin(angle),
    );
  }

  @override
  bool shouldRepaint(OrbitPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
