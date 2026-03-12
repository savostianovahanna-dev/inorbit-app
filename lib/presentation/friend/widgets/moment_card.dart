import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Data model for a single interaction moment.
class MomentData {
  const MomentData({
    required this.emoji,
    required this.title,
    required this.date,
    required this.description,
    this.photoCount = 0,
  });

  final String emoji;
  final String title;
  final String date;
  final String description;

  /// 0 = no photos, 1 = one photo, 2 = two stacked photos (Figma "several")
  final int photoCount;
}

/// Single moment entry inside the history card.
/// Shows an emoji + activity type header, date, description text,
/// and optional placeholder photo thumbnails.
class MomentCard extends StatelessWidget {
  const MomentCard({
    super.key,
    required this.moment,
    this.onEdit,
    this.onDelete,
  });

  final MomentData moment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: [emoji + title] on left, [3-dot menu] on right
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  moment.emoji,
                  style: const TextStyle(fontSize: 16, height: 1),
                ),
                const SizedBox(width: 8),
                Text(moment.title, style: AppTextStyles.momentTitle),
              ],
            ),
            _MomentMenuButton(onEdit: onEdit, onDelete: onDelete),
          ],
        ),

        // Date on its own line
        const SizedBox(height: 4),
        Text(moment.date, style: AppTextStyles.momentDate),
        const SizedBox(height: 8),

        // Description
        Text(
          moment.description,
          style: AppTextStyles.bodyRegular14,
        ),

        // Photo thumbnails (placeholders)
        if (moment.photoCount > 0) ...[
          const SizedBox(height: 10),
          _PhotoThumbnails(count: moment.photoCount),
        ],
      ],
    );
  }
}

class _MomentMenuButton extends StatelessWidget {
  const _MomentMenuButton({this.onEdit, this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MomentMenuAction>(
      onSelected: (action) {
        if (action == _MomentMenuAction.edit) onEdit?.call();
        if (action == _MomentMenuAction.delete) onDelete?.call();
      },
      offset: const Offset(0, 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: CustomPaint(
          size: const Size(24, 16),
          painter: _ThreeDotsHPainter(),
        ),
      ),
      itemBuilder:
          (_) => [
            PopupMenuItem(
              value: _MomentMenuAction.edit,
              child: Text('Edit', style: AppTextStyles.bodyRegular14),
            ),
            PopupMenuItem(
              value: _MomentMenuAction.delete,
              child: Text(
                'Delete',
                style: AppTextStyles.bodyRegular14.copyWith(
                  color: Colors.red,
                ),
              ),
            ),
          ],
    );
  }
}

enum _MomentMenuAction { edit, delete }

class _ThreeDotsHPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.fill;

    final cy = size.height / 2;
    final cx = size.width / 2;
    const r = 1.5;
    const spacing = 6.0;

    canvas.drawCircle(Offset(cx - spacing, cy), r, paint);
    canvas.drawCircle(Offset(cx, cy), r, paint);
    canvas.drawCircle(Offset(cx + spacing, cy), r, paint);
  }

  @override
  bool shouldRepaint(_ThreeDotsHPainter old) => false;
}

class _PhotoThumbnails extends StatelessWidget {
  const _PhotoThumbnails({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 1) {
      return _PhotoBox(height: 139, color: AppColors.textSecondary);
    }

    // Two photos: first full-width, second slightly overlapping below
    return SizedBox(
      height: 173 + 17, // first photo + offset for second
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _PhotoBox(
              height: 173,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          Positioned(
            top: 17,
            left: 3.52,
            right: 0,
            child: _PhotoBox(
              height: 139,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoBox extends StatelessWidget {
  const _PhotoBox({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
