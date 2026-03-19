import 'package:flutter/material.dart';
import 'package:inorbit/core/theme/app_colors.dart';
import 'package:inorbit/core/theme/app_text_styles.dart';

class MultilineTextField extends StatelessWidget {
  const MultilineTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText = '',
    this.minLines = 4,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.63),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: null,
        minLines: minLines,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        scrollPadding: const EdgeInsets.only(bottom: 300),
        style: AppTextStyles.bodyRegular14.copyWith(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyRegular14.copyWith(
            fontSize: 14,
            color: AppColors.textPrimary.withValues(alpha: 0.35),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
