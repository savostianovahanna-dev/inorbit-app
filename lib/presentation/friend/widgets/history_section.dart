import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/moment.dart';
import 'moment_card.dart';

/// "History" section — a heading followed by a white card containing
/// moment entries separated by dashed dividers.
/// Accepts real [moments] from the DB; shows a placeholder when empty.
class HistorySection extends StatelessWidget {
  const HistorySection({super.key, required this.moments});

  final List<Moment> moments;

  static const _typeEmoji = {
    'coffee': '☕',
    'call': '📞',
    'text': '💬',
    'dinner': '🍽',
    'movie': '🎬',
    'shopping': '🛍',
    'other': '✨',
  };

  static const _typeLabel = {
    'coffee': 'Coffee',
    'call': 'Call',
    'text': 'Text',
    'dinner': 'Dinner',
    'movie': 'Movie',
    'shopping': 'Shopping',
    'other': 'Other',
  };

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  MomentData _convert(Moment m) => MomentData(
    emoji: _typeEmoji[m.type] ?? '✨',
    title: _typeLabel[m.type] ?? m.type,
    date: '${_months[m.date.month - 1]} ${m.date.day}, ${m.date.year}',
    description: m.note ?? '',
    photoCount: m.photoPaths.length.clamp(0, 2),
  );

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
          child: moments.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: _EmptyState(),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < moments.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: MomentCard(moment: _convert(moments[i])),
                      ),
                      if (i < moments.length - 1) const _DashedMomentDivider(),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'No moments yet',
          style: AppTextStyles.sectionHeading.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap "Log moment" to record your first connection',
          style: AppTextStyles.bodyRegular14.copyWith(
            color: AppColors.cardBorder,
          ),
          textAlign: TextAlign.center,
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
