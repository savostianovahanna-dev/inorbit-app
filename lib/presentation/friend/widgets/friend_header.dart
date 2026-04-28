import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Navigation header row: back chevron + name title + 3-dot menu.
/// Matches Figma "Header" component (40px tall, space-between layout).
class FriendHeader extends StatelessWidget {
  const FriendHeader({
    super.key,
    required this.name,
    this.onEdit,
    this.onDelete,
  });

  final String name;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SizedBox(
              width: 40,
              height: 40,
              child: CustomPaint(painter: _ChevronPainter()),
            ),
          ),

          // Centered name
          Expanded(
            child: Text(
              name.split(' ').first, // "Anna" from "Anna Kallin"
              style: AppTextStyles.headerTitle,
              textAlign: TextAlign.center,
            ),
          ),

          // 3-dot menu button
          _MenuButton(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({this.onEdit, this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      onSelected: (action) {
        if (action == _MenuAction.edit) onEdit?.call();
        if (action == _MenuAction.delete) onDelete?.call();
      },
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.white,
      child: SizedBox(
        width: 40,
        height: 40,
        child: CustomPaint(painter: _ThreeDotPainter()),
      ),
      itemBuilder:
          (_) => [
            PopupMenuItem(
              value: _MenuAction.edit,
              child: Text('Edit', style: AppTextStyles.bodyRegular14),
            ),
            PopupMenuItem(
              value: _MenuAction.delete,
              child: Text(
                'Delete',
                style: AppTextStyles.bodyRegular14.copyWith(color: Colors.red),
              ),
            ),
          ],
    );
  }
}

enum _MenuAction { edit, delete }

class _ChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.textPrimary
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final path =
        Path()
          ..moveTo(cx + 3, cy - 6)
          ..lineTo(cx - 3, cy)
          ..lineTo(cx + 3, cy + 6);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => false;
}

class _ThreeDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.textPrimary
          ..style = PaintingStyle.fill;

    final cy = size.height / 2;
    final cx = size.width / 2;
    const r = 1.83 / 2;
    const spacing = 6.5;

    canvas.drawCircle(Offset(cx - spacing, cy), r, paint);
    canvas.drawCircle(Offset(cx, cy), r, paint);
    canvas.drawCircle(Offset(cx + spacing, cy), r, paint);
  }

  @override
  bool shouldRepaint(_ThreeDotPainter old) => false;
}
