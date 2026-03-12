import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/friend.dart';

/// Hero card showing friend's photo (placeholder), name, relationship badge,
/// birthday, and overdue connection status.
///
/// Design ref: Figma "Container" 248.94px tall, border-radius 24px,
/// gradient overlay linear(transparent 30% → #111111 68%).
class ProfileHero extends StatelessWidget {
  const ProfileHero({super.key, required this.friend});

  final Friend friend;

  String get _badge => switch (friend.orbitTier) {
    'inner_circle' => 'Inner Circle',
    'regulars' => 'Regulars',
    'casuals' => 'Casuals',
    _ => '',
  };

  String get _birthday {
    if (friend.birthday == null) return '';
    final d = friend.birthday!;
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '🎂 ${m[d.month - 1]} ${d.day}';
  }

  String get _overdueText {
    final days = friend.daysSinceContact;
    if (days == 9999) return 'Never connected';
    return '$days days ago';
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = friend.isOverdue;
    final birthday = _birthday;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: double.infinity,
        height: 249,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: background placeholder (simulates friend's photo)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A6275), Color(0xFF1E2D3D)],
                ),
              ),
            ),

            // Layer 2: dark gradient overlay (matches Figma 30%–68% stop)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.30, 0.68],
                  colors: [Colors.transparent, Color(0xFF111111)],
                ),
              ),
            ),

            // Layer 3: text content positioned over gradient
            Positioned(
              top: 149,
              left: 20,
              right: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(friend.name, style: AppTextStyles.friendName),
                  const SizedBox(width: 8),
                  if (_badge.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tagBg.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        _badge,
                        style: AppTextStyles.tagLabel.copyWith(
                          fontSize: 12,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Birthday text (only shown when set)
            if (birthday.isNotEmpty)
              Positioned(
                top: 186,
                left: 19,
                child: Text(
                  birthday,
                  style: AppTextStyles.bodyRegular14.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),

            // Overdue indicator row
            if (isOverdue)
              Positioned(
                top: birthday.isNotEmpty ? 211 : 186,
                left: 20,
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _overdueText,
                      style: AppTextStyles.bodyRegular14.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
