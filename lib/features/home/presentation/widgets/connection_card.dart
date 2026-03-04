import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// White card showing a connection that needs attention.
/// Contains: person header row, dashed divider, reminder message.
class ConnectionCard extends StatelessWidget {
  const ConnectionCard({
    super.key,
    required this.name,
    required this.daysAgo,
    required this.message,
  });

  final String name;
  final String daysAgo;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: orange indicator dot + name + days ago
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name, style: AppTextStyles.bodyMedium16),
              ),
              Text(daysAgo, style: AppTextStyles.labelRegular14),
            ],
          ),
          const SizedBox(height: 14),
          const _DashedDivider(),
          const SizedBox(height: 14),
          // Reminder message
          Text(message, style: AppTextStyles.bodyRegular14),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: _DashPainter()),
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashGap = 7.0;

    final paint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, 0),
        Offset((x + dashWidth).clamp(0.0, size.width), 0),
        paint,
      );
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => false;
}
