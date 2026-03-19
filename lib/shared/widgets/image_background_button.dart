import 'package:flutter/material.dart';
import 'package:inorbit/core/theme/app_text_styles.dart';

class ImageBackgroundButton extends StatelessWidget {
  const ImageBackgroundButton({
    super.key,
    required this.label,
    required this.onTap,
    this.assetPath = 'assets/button_background.png',
    this.height = 68,
  });

  final String label;
  final VoidCallback onTap;
  final String assetPath;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 30,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(assetPath, fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0xFF111111).withValues(alpha: 0.75),
                ),
              ),
              Center(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium16.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
