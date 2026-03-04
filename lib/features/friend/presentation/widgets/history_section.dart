import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'moment_card.dart';

/// "History" section — a heading followed by a white card containing
/// moment entries separated by dashed dividers.
class HistorySection extends StatelessWidget {
  const HistorySection({super.key});

  static const _moments = [
    MomentData(
      emoji: '☕',
      title: 'Coffee',
      date: 'Jan 11, 2026',
      description: "Caught up at the usual spot. She's thinking about switching careers.",
      photoCount: 2,
    ),
    MomentData(
      emoji: '📞',
      title: 'Call',
      date: 'Dec 28, 2025',
      description: 'Quick holiday call. She sounded happy.',
      photoCount: 0,
    ),
    MomentData(
      emoji: '🍽',
      title: 'Dinner',
      date: 'Dec 3, 2025',
      description: 'Birthday dinner downtown.',
      photoCount: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'History',
            style: AppTextStyles.sectionHeading.copyWith(
              fontSize: 15,
              color: AppColors.textPrimary.withValues(alpha: 0.75),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _moments.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: MomentCard(moment: _moments[i]),
                ),
                if (i < _moments.length - 1)
                  const _DashedMomentDivider(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DashedMomentDivider extends StatelessWidget {
  const _DashedMomentDivider();

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
      // rgba(17,17,17,0.1) — subtle dark divider matching Figma
      ..color = const Color(0x1A111111)
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
  bool shouldRepaint(_DashPainter old) => false;
}
