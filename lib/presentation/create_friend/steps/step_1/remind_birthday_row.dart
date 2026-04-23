import 'package:flutter/cupertino.dart';
import 'package:inorbit/core/theme/app_colors.dart';
import 'package:inorbit/core/theme/app_text_styles.dart';

class RemindBirthdayRow extends StatefulWidget {
  const RemindBirthdayRow({
    super.key,
    this.onChanged,
    this.initialValue = true,
  });
  final ValueChanged<bool>? onChanged;
  final bool initialValue;

  @override
  State<RemindBirthdayRow> createState() => _RemindBirthdayRowState();
}

class _RemindBirthdayRowState extends State<RemindBirthdayRow> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remind me about birthdays',
                  style: AppTextStyles.settingsRowTitle,
                ),
                const SizedBox(height: 2),
                Text(
                  '7 days before their birthday',
                  style: AppTextStyles.settingsRowSubtitle,
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: _value,
            activeTrackColor: AppColors.textSecondary,
            onChanged: (v) {
              setState(() => _value = v);
              widget.onChanged?.call(v);
            },
          ),
        ],
      ),
    );
  }
}
