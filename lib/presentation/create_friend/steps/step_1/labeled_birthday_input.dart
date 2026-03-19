import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inorbit/core/theme/app_colors.dart';
import 'package:inorbit/core/theme/app_text_styles.dart';
import 'package:inorbit/presentation/create_friend/widgets/input_box.dart';

class LabeledBirthdayInput extends StatefulWidget {
  const LabeledBirthdayInput({
    super.key,
    required this.controller,
    this.initialDate,
  });
  final TextEditingController controller;
  final DateTime? initialDate;

  @override
  State<LabeledBirthdayInput> createState() => _LabeledBirthdayInputState();
}

class _LabeledBirthdayInputState extends State<LabeledBirthdayInput> {
  DateTime? _picked;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _picked = widget.initialDate;
      widget.controller.text =
          '${_months[_picked!.month - 1]} ${_picked!.day}';
    }
  }

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  void _showPicker() {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    var tempDate = _picked ?? DateTime(now.year - 25, now.month, now.day);

    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (ctx) => Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.divider, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.bodyRegular14.copyWith(
                            color: AppColors.cardBorder,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text('Birthday', style: AppTextStyles.headerTitle),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _picked = tempDate;
                            widget.controller.text =
                                '${_months[tempDate.month - 1]} ${tempDate.day}';
                          });
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          'Done',
                          style: AppTextStyles.headerTitle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 216,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: tempDate,
                    maximumDate: now,
                    minimumYear: 1900,
                    onDateTimeChanged: (d) => tempDate = d,
                  ),
                ),
                SizedBox(height: MediaQuery.of(ctx).padding.bottom),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDate = _picked != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Birthday (optional)', style: AppTextStyles.tagLabel),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showPicker,
          child: InputBox(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Text(
                      hasDate ? widget.controller.text : 'DD / MM',
                      style: AppTextStyles.bodyRegular14.copyWith(
                        fontSize: 14,
                        color:
                            hasDate
                                ? AppColors.textPrimary
                                : AppColors.textPrimary.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Image.asset(
                    'assets/images/calendar.png',
                    width: 19,
                    height: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
