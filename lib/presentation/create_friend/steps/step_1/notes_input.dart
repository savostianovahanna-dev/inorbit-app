import 'package:flutter/material.dart';
import 'package:inorbit/core/theme/app_colors.dart';
import 'package:inorbit/core/theme/app_text_styles.dart';
import 'package:inorbit/presentation/create_friend/widgets/input_box.dart';

class NotesInput extends StatelessWidget {
  const NotesInput({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notes', style: AppTextStyles.tagLabel),
        const SizedBox(height: 8),
        InputBox(
          borderRadius: 16,
          child: TextField(
            controller: controller,
            maxLines: null,
            minLines: 4,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            scrollPadding: const EdgeInsets.only(bottom: 300),
            style: AppTextStyles.bodyRegular14.copyWith(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: "Something you don't want to forget about",
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
