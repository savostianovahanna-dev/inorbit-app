import 'dart:io';
import 'dart:math' show pi;
import 'dart:ui';

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
    this.photoPaths = const [],
  });

  final String emoji;
  final String title;
  final String date;
  final String description;

  /// Actual file paths or Cloudinary URLs for photos attached to this moment.
  final List<String> photoPaths;
}

/// Single moment entry inside the history card.
class MomentCard extends StatelessWidget {
  const MomentCard({super.key, required this.moment, this.onDelete});

  final MomentData moment;
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
            _MomentMenuButton(onDelete: onDelete),
          ],
        ),

        // Date
        const SizedBox(height: 4),
        Text(moment.date, style: AppTextStyles.momentDate),

        // Description — only when non-empty
        if (moment.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(moment.description, style: AppTextStyles.bodyRegular14),
        ],

        // Photos
        if (moment.photoPaths.isNotEmpty) ...[
          const SizedBox(height: 10),
          _PhotoThumbnails(moment: moment),
        ],
      ],
    );
  }
}

// ─── Context menu (Delete only) ───────────────────────────────────────────────

class _MomentMenuButton extends StatelessWidget {
  const _MomentMenuButton({this.onDelete});

  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (v) {
        if (v == 'delete') onDelete?.call();
      },
      offset: const Offset(0, 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.zero,
      color: AppColors.white,
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
              value: 'delete',
              child: Text(
                'Delete',
                style: AppTextStyles.bodyRegular14.copyWith(color: Colors.red),
              ),
            ),
          ],
    );
  }
}

class _ThreeDotsHPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
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

// ─── Photo thumbnails ─────────────────────────────────────────────────────────

class _PhotoThumbnails extends StatelessWidget {
  const _PhotoThumbnails({required this.moment});

  final MomentData moment;

  List<String> get paths => moment.photoPaths;

  static Widget _img(String path, {double? height}) {
    final isRemote = path.startsWith('http');
    final placeholder = Container(
      width: double.infinity,
      height: height,
      color: AppColors.textSecondary.withValues(alpha: 0.15),
    );
    Widget raw;
    if (isRemote) {
      raw = Image.network(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        errorBuilder: (_, __, ___) => placeholder,
      );
    } else {
      raw = Image.file(
        File(path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(width: double.infinity, height: height, child: raw),
    );
  }

  void _openPopup(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _PhotoPopup(moment: moment),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (paths.isEmpty) return const SizedBox.shrink();

    // ── Single photo ─────────────────────────────────────────────────────────
    if (paths.length == 1) {
      return _img(paths[0], height: 160);
    }

    // ── 2+ photos: stacked card effect, tap to open popup ────────────────────
    const photoH = 165.0;
    const extraH = 20.0; // room for rotated edges to peek out symmetrically

    return GestureDetector(
      onTap: () => _openPopup(context),
      child: SizedBox(
        height: photoH + extraH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Second photo — behind, rotated 7° around its own center,
            // same top position so top-left overhang == bottom-right overhang
            Positioned(
              top: extraH / 2,
              left: 0,
              right: 0,
              child: Transform.rotate(
                angle: 7 * pi / 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: photoH,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _img(paths[1], height: photoH),
                        Container(color: Colors.black.withValues(alpha: 0.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // First photo — in front, no rotation
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _img(paths[0], height: photoH),
            ),

            // Photo count badge — only when there are more than 2 photos
            if (paths.length > 2)
              Positioned(
                top: 12,
                right: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: 36,
                      height: 36,
                      color: Colors.black.withValues(alpha: 0.45),
                      alignment: Alignment.center,
                      child: Text(
                        '${paths.length}',
                        style: AppTextStyles.tagLabel.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Photo popup dialog ───────────────────────────────────────────────────────

class _PhotoPopup extends StatelessWidget {
  const _PhotoPopup({required this.moment});

  final MomentData moment;

  static Widget _img(String path) {
    final isRemote = path.startsWith('http');
    final placeholder = Container(
      width: double.infinity,
      height: 240,
      color: AppColors.textSecondary.withValues(alpha: 0.15),
    );
    Widget raw;
    if (isRemote) {
      raw = Image.network(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 240,
        errorBuilder: (_, __, ___) => placeholder,
      );
    } else {
      raw = Image.file(
        File(path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 240,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(width: double.infinity, height: 240, child: raw),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Moment info ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 52, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              moment.emoji,
                              style: const TextStyle(fontSize: 18, height: 1),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              moment.title,
                              style: AppTextStyles.momentTitle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(moment.date, style: AppTextStyles.momentDate),
                        if (moment.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            moment.description,
                            style: AppTextStyles.bodyRegular14,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── Photos — one per row ──────────────────────────────
                  const SizedBox(height: 16),
                  for (final path in moment.photoPaths)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _img(path),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            // ── Close button ───────────────────────────────────────────────
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
