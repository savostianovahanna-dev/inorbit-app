import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Hero card showing friend's photo (placeholder), name, relationship badge,
/// birthday, and overdue connection status.
///
/// Design ref: Figma "Container" 248.94px tall, border-radius 24px,
/// gradient overlay linear(transparent 30% → #111111 68%).
class ProfileHero extends StatelessWidget {
  const ProfileHero({
    super.key,
    required this.name,
    this.badge = 'Inner Circle',
    this.birthday = '🎂 March 15',
    this.overdueText = 'Overdue · 47 days ago',
    this.isOverdue = false,
  });

  final String name;
  final String badge;
  final String birthday;
  final String overdueText;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
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
            // Name row at y≈149, birthday at y≈186, overdue at y≈211
            Positioned(
              top: 149,
              left: 20,
              right: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(name, style: AppTextStyles.friendName),
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
                      badge,
                      style: AppTextStyles.tagLabel.copyWith(
                        fontSize: 12,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Birthday text
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
                top: 211,
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
                      overdueText,
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
