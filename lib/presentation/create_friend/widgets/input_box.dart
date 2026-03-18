import 'package:flutter/material.dart';
import 'package:inorbit/core/theme/app_colors.dart';

class InputBox extends StatelessWidget {
  const InputBox({super.key, required this.child, this.borderRadius = 12});
  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.divider, width: 0.63),
      ),
      child: child,
    );
  }
}
