import 'package:flutter/material.dart';
import 'package:inorbit/core/theme/app_text_styles.dart';
import 'package:inorbit/shared/widgets/multiline_text_field.dart';

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
        MultilineTextField(
          controller: controller,
          hintText: "Something you don't want to forget about",
        ),
      ],
    );
  }
}
