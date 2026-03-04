import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "Topics to discuss" section — a heading followed by a wrapping row of
/// topic chips and an "Add topic" outlined chip.
class TopicsSection extends StatelessWidget {
  const TopicsSection({super.key, this.topics = const []});

  final List<String> topics;

  static const _defaultTopics = [
    'Her new job',
    'Books to read: Light out',
    'Going to the gym idea',
  ];

  @override
  Widget build(BuildContext context) {
    final displayTopics = topics.isEmpty ? _defaultTopics : topics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Topics to discuss',
          style: AppTextStyles.sectionHeading.copyWith(
            color: AppColors.textPrimary.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...displayTopics.map((t) => _TopicChip(label: t)),
            const _AddTopicChip(),
          ],
        ),
      ],
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.tagBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(label, style: AppTextStyles.tagLabel),
    );
  }
}

class _AddTopicChip extends StatelessWidget {
  const _AddTopicChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 0.63),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CustomPaint(painter: _PlusIconPainter()),
          ),
          const SizedBox(width: 4),
          Text('Add topic', style: AppTextStyles.tagLabel),
        ],
      ),
    );
  }
}

class _PlusIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 1.17
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Horizontal bar
    canvas.drawLine(Offset(cx - 4.08, cy), Offset(cx + 4.08, cy), paint);
    // Vertical bar
    canvas.drawLine(Offset(cx, cy - 4.08), Offset(cx, cy + 4.08), paint);
  }

  @override
  bool shouldRepaint(_PlusIconPainter old) => false;
}
