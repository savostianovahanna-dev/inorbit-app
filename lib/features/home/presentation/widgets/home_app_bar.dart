import 'package:flutter/material.dart';
import 'avatar_badge.dart';
import '../../../../core/theme/app_text_styles.dart';

/// App bar row: "InOrbit" title on the left, overlapping avatars on the right.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  static const _badgeSize = 36.0;
  static const _overlap = 10.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('InOrbit', style: AppTextStyles.titleBold24),
        const Spacer(),
        // Overlapping avatar badges (HM behind, AK in front)
        SizedBox(
          width: _badgeSize * 2 - _overlap,
          height: _badgeSize,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                child: const AvatarBadge(
                  initials: 'HM',
                  size: _badgeSize,
                  strokeWidth: 2.0,
                ),
              ),
              Positioned(
                left: _badgeSize - _overlap,
                child: const AvatarBadge(
                  initials: 'AK',
                  size: _badgeSize,
                  strokeWidth: 2.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
