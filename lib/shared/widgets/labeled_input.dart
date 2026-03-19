import 'package:flutter/material.dart';
import 'package:inorbit/core/theme/app_colors.dart';
import 'package:inorbit/core/theme/app_text_styles.dart';

class LabeledInput extends StatelessWidget {
  const LabeledInput({
    super.key,
    required this.label,
    required this.controller,
    this.hint = '',
  });

  final String label;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.tagLabel),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider, width: 0.63),
          ),
          child: TextField(
            controller: controller,
            style: AppTextStyles.bodyRegular14.copyWith(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyRegular14.copyWith(
                fontSize: 14,
                color: AppColors.textPrimary.withValues(alpha: 0.35),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
