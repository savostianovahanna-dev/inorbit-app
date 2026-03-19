import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// A filled topic chip with truncated label + × delete button.
/// Long-pressing (or tapping when truncated) shows the full label as a tooltip.
class TopicChip extends StatelessWidget {
  const TopicChip({
    super.key,
    required this.label,
    required this.onDelete,
  });

  final String label;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        padding: const EdgeInsets.only(left: 14, top: 8, bottom: 8, right: 8),
        decoration: BoxDecoration(
          color: AppColors.tagBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.tagLabel,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onDelete,
              behavior: HitTestBehavior.opaque,
              child: const _XIcon(),
            ),
          ],
        ),
      ),
    );
  }
}

class _XIcon extends StatelessWidget {
  const _XIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _XPainter()),
    );
  }
}

class _XPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    const inset = 4.5;
    canvas.drawLine(
      Offset(inset, inset),
      Offset(size.width - inset, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(inset, size.height - inset),
      paint,
    );
  }

  @override
  bool shouldRepaint(_XPainter old) => false;
}
