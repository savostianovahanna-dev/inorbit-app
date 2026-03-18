import 'package:flutter/material.dart';
import 'package:inorbit/core/theme/app_colors.dart';

class AddFriendProgressBar extends StatelessWidget {
  const AddFriendProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color:
                  i < currentStep ? AppColors.textPrimary : AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
