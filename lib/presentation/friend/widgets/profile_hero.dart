import 'dart:io';

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

  Widget _buildBackground() {
    if (friend.avatarPath != null && friend.avatarPath!.isNotEmpty) {
      return Image.file(
        File(friend.avatarPath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (friend.avatarUrl != null && friend.avatarUrl!.isNotEmpty) {
      return Image.network(
        friend.avatarUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (friend.planetIndex != null) {
      return Image.asset(
        'assets/images/planets/planet_${friend.planetIndex! + 1}.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return Image.asset(
      'assets/onboarding1.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
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
            // Layer 1: friend photo / planet / default onboarding image
            Positioned.fill(child: _buildBackground()),

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

            // Layer 3: text content — name, birthday, last contact
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name + orbit badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          friend.name,
                          style: AppTextStyles.friendName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_badge.isNotEmpty) ...[
                        const SizedBox(width: 8),
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
                    ],
                  ),
                  // Birthday (only when set)
                  if (birthday.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      birthday,
                      style: AppTextStyles.bodyRegular14.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                  // Last contact — always shown
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isOverdue) ...[
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _overdueText,
                        style: AppTextStyles.bodyRegular14.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
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
