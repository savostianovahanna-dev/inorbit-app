import 'package:flutter/material.dart';
import 'package:inorbit/core/theme/app_colors.dart';
import 'package:inorbit/core/theme/app_text_styles.dart';

class AddFriendHeader extends StatelessWidget {
  const AddFriendHeader({
    super.key,
    required this.onBack,
    required this.onClose,
  });
  final VoidCallback onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          onTap: onBack,
          opacity: 0.35,
          child: CustomPaint(
            size: const Size(8, 13),
            painter: _BackChevronPainter(),
          ),
        ),
        Expanded(
          child: Center(
            child: Text('Add friend', style: AppTextStyles.headerTitle),
          ),
        ),
        _CircleIconButton(
          onTap: onClose,
          child: CustomPaint(
            size: const Size(12, 12),
            painter: _CloseIconPainter(),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.child,
    this.onTap,
    this.opacity = 1.0,
  });
  final Widget child;
  final VoidCallback? onTap;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cardBorder, width: 0.63),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _BackChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.textPrimary
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;
    final path =
        Path()
          ..moveTo(size.width, 0)
          ..lineTo(0, size.height / 2)
          ..lineTo(size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BackChevronPainter old) => false;
}

class _CloseIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.textPrimary
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_CloseIconPainter old) => false;
}
