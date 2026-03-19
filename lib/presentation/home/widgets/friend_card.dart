import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/friend.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _kCardWidth = 160.0;

const _kTypeEmoji = {
  'coffee': '☕',
  'call': '📞',
  'text': '💬',
  'dinner': '🍽️',
  'movie': '🎬',
  'shopping': '🛍️',
  'other': '✨',
};

const _kTypeLabel = {
  'coffee': 'Coffee',
  'call': 'Call',
  'text': 'Text',
  'dinner': 'Dinner',
  'movie': 'Movie',
  'shopping': 'Shopping',
  'other': 'Other',
};

const _kAmber = Color(0xFFC4985A);
const _kMuted = Color(0xFFAEAEB2);

// ─── Widget ───────────────────────────────────────────────────────────────────

class FriendCard extends StatelessWidget {
  const FriendCard({
    super.key,
    required this.friend,
    this.lastMeetingType,
    this.daysSinceContact,
    required this.onTap,
  });

  final Friend friend;

  /// Type string of the most recent moment ('coffee', 'call', etc.).
  /// Null when no moments have been logged yet.
  final String? lastMeetingType;

  /// Computed days since last contact. Null means never contacted.
  final int? daysSinceContact;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _kCardWidth,
        padding: const EdgeInsets.all(12),
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
            _Avatar(friend: friend),
            const SizedBox(height: 8),
            // Name
            Text(
              friend.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyRegular14.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            // Orbit tier label
            Text(
              _tierLabel(friend.orbitTier),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyRegular14.copyWith(
                fontSize: 12,
                color: _kMuted,
              ),
            ),
            const SizedBox(height: 10),
            const _DashedDivider(),
            const SizedBox(height: 6),
            // Last meeting
            _MeetingRow(type: lastMeetingType),
            const SizedBox(height: 3),
            // Days ago
            _DaysText(days: daysSinceContact, isOverdue: friend.isOverdue),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    // Custom photo (local file) takes top priority.
    if (friend.avatarPath != null) {
      return ClipOval(
        child: Image.file(
          File(friend.avatarPath!),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _InitialsCircle(name: friend.name),
        ),
      );
    }

    // Planet image — index is 0-based, filenames are 1-based (planet_1…planet_8).
    if (friend.planetIndex != null) {
      return ClipOval(
        child: Image.asset(
          'assets/images/planets/planet_${friend.planetIndex! + 1}.png',
          width: 48,
          height: 48,
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
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1E3A6E),
      ),
      alignment: Alignment.center,
      child: Text(_initials(name), style: AppTextStyles.avatarInitials12),
    );
  }
}

class _MeetingRow extends StatelessWidget {
  const _MeetingRow({this.type});

  final String? type;

  @override
  Widget build(BuildContext context) {
    if (type == null) {
      return Text(
        'No log yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyRegular14.copyWith(
          fontSize: 13,
          color: _kMuted,
        ),
      );
    }

    final emoji = _kTypeEmoji[type] ?? '✨';
    final label = _kTypeLabel[type] ?? type!;

    return Text(
      '$emoji $label',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.bodyRegular14.copyWith(
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _DaysText extends StatelessWidget {
  const _DaysText({this.days, required this.isOverdue});

  final int? days;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    return Text(
      _label(days),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.bodyRegular14.copyWith(
        fontSize: 12,
        color: isOverdue ? _kAmber : _kMuted,
        fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  static String _label(int? days) {
    if (days == null) return 'Never';
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }
}

// ─── Dashed divider ───────────────────────────────────────────────────────────

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

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

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Returns up to two-letter initials from a display name.
/// Uses [String.runes] to safely handle multi-byte characters (emoji, etc.)
/// and avoid producing invalid UTF-16 surrogate pairs.
String _initials(String name) {
  String _firstChar(String s) =>
      s.isEmpty ? '' : String.fromCharCode(s.runes.first).toUpperCase();

  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return _firstChar(parts[0]);
  return '${_firstChar(parts[0])}${_firstChar(parts.last)}';
}

String _tierLabel(String tier) => switch (tier) {
  'inner_circle' => 'Inner circle',
  'regulars' => 'Regulars',
  'casuals' => 'Casuals',
  _ => tier,
};
