import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Outlined "+ Add topic" button chip.
/// Tap fires [onTap]; the actual text input is managed by the parent.
class AddTopicInput extends StatelessWidget {
  const AddTopicInput({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              child: CustomPaint(painter: _PlusPainter()),
            ),
            const SizedBox(width: 4),
            Text('Add topic', style: AppTextStyles.tagLabel),
          ],
        ),
      ),
    );
  }
}

class _PlusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 1.17
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(cx - 4.08, cy), Offset(cx + 4.08, cy), paint);
    canvas.drawLine(Offset(cx, cy - 4.08), Offset(cx, cy + 4.08), paint);
  }

  @override
  bool shouldRepaint(_PlusPainter old) => false;
}
