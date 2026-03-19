import 'package:flutter/material.dart';
import 'package:inorbit/core/theme/app_colors.dart';
import 'package:inorbit/core/theme/app_text_styles.dart';

class DarkButton extends StatelessWidget {
  const DarkButton({
    super.key,
    required this.label,
    required this.onTap,
    this.saving = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onTap;
  final bool saving;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: saving
              ? AppColors.textPrimary.withValues(alpha: 0.6)
              : AppColors.textPrimary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 30,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: saving
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingIcon != null) ...[
                    leadingIcon!,
                    const SizedBox(width: 12),
                  ],
                  Text(label, style: AppTextStyles.logButtonLabel),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 10),
                    trailingIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}
