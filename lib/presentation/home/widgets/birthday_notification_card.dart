import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/friend.dart';

// ─── Public widget ────────────────────────────────────────────────────────────

/// Full-width card shown at the top of the friends list when a friend has a
/// birthday today or within the next 7 days.
class BirthdayNotificationCard extends StatelessWidget {
  const BirthdayNotificationCard({
    super.key,
    required this.friend,
    required this.daysUntil,
  });

  final Friend friend;

  /// 0 = today, 1 = tomorrow, 2+ = days until birthday.
  final int daysUntil;

  // ── Content variables — edit here to update all copy & assets ─────────────

  static const String stickerImagePath = 'assets/images/birthday_sticker.png';

  static const String titleSuffixToday = "'s birthday today";
  static const String titleSuffixTomorrow = "'s birthday tomorrow";
  static const String titleSuffixInDays = "'s birthday in";
  static const String titleSuffixDaysUnit = 'days';

  static const String bottomText =
      'A simple hello is enough to keep the connection alive.';

  static const List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top part ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Row(
              children: [
                // Avatar with birthday sticker overlay
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _BirthdayAvatar(friend: friend),
                    Positioned(
                      top: -6,
                      left: -6,
                      child: Image.asset(
                        stickerImagePath,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Title + date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titleText(),
                      style: AppTextStyles.bodyRegular14.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formattedDate(),
                      style: AppTextStyles.bodyRegular14.copyWith(
                        fontSize: 12,
                        color: const Color(0xFFAEAEB2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── Dashed separator ──────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: _BirthdayDivider(),
          ),
          // ── Bottom part ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Text(
              bottomText,
              style: AppTextStyles.bodyRegular14.copyWith(
                fontSize: 12,
                color: const Color(0xFFAEAEB2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _titleText() {
    final first = friend.name.split(' ').first;
    if (daysUntil == 0) return "$first$titleSuffixToday";
    if (daysUntil == 1) return "$first$titleSuffixTomorrow";
    return "$first$titleSuffixInDays $daysUntil $titleSuffixDaysUnit";
  }

  String _formattedDate() {
    if (friend.birthday == null) return '';
    return '${friend.birthday!.day} ${monthNames[friend.birthday!.month - 1]}';
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _BirthdayAvatar extends StatelessWidget {
  const _BirthdayAvatar({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    const size = 48.0;

    if (friend.avatarPath != null) {
      return ClipOval(
        child: Image.file(
          File(friend.avatarPath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _InitialsCircle(name: friend.name),
        ),
      );
    }

    if (friend.planetIndex != null) {
      return ClipOval(
        child: Image.asset(
          'assets/images/planets/planet_${friend.planetIndex! + 1}.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _InitialsCircle(name: friend.name),
        ),
      );
    }

    return _InitialsCircle(name: friend.name);
  }
}

class _InitialsCircle extends StatelessWidget {
  const _InitialsCircle({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    const size = 48.0;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1E3A6E),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: AppTextStyles.avatarInitials12.copyWith(fontSize: 16),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0].toUpperCase()}${parts.last[0].toUpperCase()}';
  }
}

// ─── Dashed divider (matches FriendCard separator) ────────────────────────────

class _BirthdayDivider extends StatelessWidget {
  const _BirthdayDivider();

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
    const dashWidth = 5.0;
    const dashGap = 5.0;

    final paint =
        Paint()
          ..color = AppColors.divider
          ..strokeWidth = 1.0
          ..strokeCap = StrokeCap.round;

    var x = 0.0;
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
  bool shouldRepaint(_DashPainter _) => false;
}
