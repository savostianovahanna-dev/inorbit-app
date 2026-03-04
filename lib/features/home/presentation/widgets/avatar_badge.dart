import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AvatarBadge extends StatelessWidget {
  const AvatarBadge({
    super.key,
    required this.initials,
    this.size = 40.0,
    this.strokeWidth = 3.0,
    this.fontSize,
  });

  final String initials;
  final double size;
  final double strokeWidth;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final style = fontSize != null
        ? AppTextStyles.avatarInitials12.copyWith(fontSize: fontSize)
        : AppTextStyles.avatarInitials12;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.avatarFill,
        border: Border.all(
          color: AppColors.white,
          width: strokeWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(initials, style: style),
    );
  }
}
