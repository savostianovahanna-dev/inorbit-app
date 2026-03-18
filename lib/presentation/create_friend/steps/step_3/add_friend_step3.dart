import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inorbit/core/theme/app_colors.dart';
import 'package:inorbit/core/theme/app_text_styles.dart';

class AddFriendStep3 extends StatefulWidget {
  const AddFriendStep3({super.key, this.onDateChanged});
  final ValueChanged<DateTime?>? onDateChanged;

  @override
  State<AddFriendStep3> createState() => _AddFriendStep3State();
}

class _AddFriendStep3State extends State<AddFriendStep3> {
  int? _selected = 0;
  DateTime? _exactDate;

  @override
  void initState() {
    super.initState();
    // Notify parent of the default "Today" selection immediately after mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDateChanged?.call(DateTime.now());
    });
  }

  static const _options = ['Today', 'This week', 'This month', 'Longer ago'];
  static const _optionDays = [0, 3, 15, 60];

  static const _planetAssets = [
    'assets/images/planets/planet_1.png',
    'assets/images/planets/planet_3.png',
    'assets/images/planets/planet_5.png',
    'assets/images/planets/planet_7.png',
  ];

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  void _showExactDatePicker() {
    final now = DateTime.now();
    var temp = _exactDate ?? now;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                  Text('Last connected', style: AppTextStyles.headerTitle),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _exactDate = temp;
                        _selected = null;
                      });
                      Navigator.pop(ctx);
                      widget.onDateChanged?.call(temp);
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
                initialDateTime: temp,
                maximumDate: now,
                minimumYear: 1900,
                onDateTimeChanged: (d) => temp = d,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('When did you last connect?', style: AppTextStyles.headerTitle),
        const SizedBox(height: 4),
        Text(
          "We'll use this to set your first reminder",
          style: AppTextStyles.bodyRegular14.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_options.length, (i) {
          final sel = _selected == i;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selected = i;
                _exactDate = null;
              });
              widget.onDateChanged?.call(
                DateTime.now().subtract(Duration(days: _optionDays[i])),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              height: 60,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel ? AppColors.orange : const Color(0xFFE2E8F0),
                  width: sel ? 2.0 : 1.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(sel ? 12 : 13),
                child: sel
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(_planetAssets[i], fit: BoxFit.cover),
                          ColoredBox(color: const Color(0xBF000000)),
                          ColoredBox(
                            color: const Color(0xFFDEA754)
                                .withValues(alpha: 0.08),
                          ),
                          Center(
                            child: Text(
                              _options[i],
                              style: AppTextStyles.bodyMedium16.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          _options[i],
                          style: AppTextStyles.bodyMedium16.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
              ),
            ),
          );
        }),
        // Pick exact date — transparent, no shadow, border only
        GestureDetector(
          onTap: _showExactDatePicker,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _exactDate != null
                      ? '${_months[_exactDate!.month - 1]} ${_exactDate!.day}, ${_exactDate!.year}'
                      : 'Pick exact date',
                  style: AppTextStyles.bodyRegular14.copyWith(
                    fontSize: 14,
                    color: _exactDate != null
                        ? AppColors.textPrimary
                        : const Color(0xFF334155).withValues(alpha: 0.75),
                  ),
                ),
                Image.asset(
                  'assets/images/calendar.png',
                  width: 19,
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
