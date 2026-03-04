import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// App bar row: "InOrbit" title on the left, "+" add button on the right.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, this.onAddFriend});

  final VoidCallback? onAddFriend;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('InOrbit', style: AppTextStyles.titleBold24),
        const Spacer(),
        _PlusButton(onTap: onAddFriend),
      ],
    );
  }
}

class _PlusButton extends StatelessWidget {
  const _PlusButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.cardBorder, width: 0.63),
        ),
        child: Center(
          child: CustomPaint(
            size: const Size(14, 14),
            painter: _PlusIconPainter(),
          ),
        ),
      ),
    );
  }
}

class _PlusIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    // Horizontal
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    // Vertical
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_PlusIconPainter old) => false;
}
