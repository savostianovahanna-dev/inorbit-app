import 'package:flutter/material.dart';
import 'package:inorbit/presentation/create_friend/steps/step_1/avatar_picker.dart';
import 'package:inorbit/presentation/create_friend/steps/step_1/labeled_birthday_input.dart';
import 'package:inorbit/presentation/create_friend/steps/step_1/notes_input.dart';
import 'package:inorbit/presentation/create_friend/steps/step_1/remind_birthday_row.dart';
import 'package:inorbit/presentation/create_friend/widgets/labeled_input.dart';

class AddFriendStep1 extends StatelessWidget {
  const AddFriendStep1({
    super.key,
    required this.nameCtrl,
    required this.birthdayCtrl,
    required this.notesCtrl,
    this.onPlanetIndexChanged,
    this.onAvatarPathChanged,
    this.onRemindBirthdayChanged,
    this.onBirthdayChanged,
  });

  final TextEditingController nameCtrl;
  final TextEditingController birthdayCtrl;
  final TextEditingController notesCtrl;
  final ValueChanged<int?>? onPlanetIndexChanged;
  final ValueChanged<String?>? onAvatarPathChanged;
  final ValueChanged<bool>? onRemindBirthdayChanged;
  final ValueChanged<DateTime?>? onBirthdayChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvatarPicker(
          onPlanetIndexChanged: onPlanetIndexChanged,
          onAvatarPathChanged: onAvatarPathChanged,
        ),
        const SizedBox(height: 24),
        LabeledInput(label: 'Name', controller: nameCtrl, hint: 'Anna'),
        const SizedBox(height: 20),
        LabeledBirthdayInput(
          controller: birthdayCtrl,
          onDateChanged: onBirthdayChanged,
        ),
        const SizedBox(height: 8),
        RemindBirthdayRow(onChanged: onRemindBirthdayChanged),
        const SizedBox(height: 20),
        NotesInput(controller: notesCtrl),
      ],
    );
  }
}
