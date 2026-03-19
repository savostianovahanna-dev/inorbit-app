import 'package:flutter/material.dart';
import 'package:inorbit/core/theme/app_colors.dart';
import 'package:inorbit/shared/widgets/dark_button.dart';

class ContinueButton extends StatelessWidget {
  const ContinueButton({
    super.key,
    required this.label,
    required this.onTap,
    this.showCheck = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomPad),
      child: DarkButton(
        label: label,
        onTap: onTap,
        trailingIcon: showCheck
            ? CustomPaint(
                size: const Size(18, 18),
                painter: _CheckIconPainter(),
              )
            : null,
      ),
    );
  }
}

class _CheckIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.white
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;
    final path =
        Path()
          ..moveTo(size.width * 0.17, size.height * 0.50)
          ..lineTo(size.width * 0.42, size.height * 0.75)
          ..lineTo(size.width * 0.83, size.height * 0.25);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckIconPainter old) => false;
}
