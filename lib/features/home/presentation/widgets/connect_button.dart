import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Full-width outlined "Time to connect" button.
class ConnectButton extends StatelessWidget {
  const ConnectButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed ?? () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
        ),
        child: Text('Time to connect', style: AppTextStyles.connectButtonLabel),
      ),
    );
  }
}
