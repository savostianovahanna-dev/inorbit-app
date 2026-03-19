import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/image_background_button.dart';

/// Shown after the user completes all 3 steps of the "Add Friend" flow.
/// Figma: node 58-6490 "Create friend / successfully create"
class AddFriendSuccessScreen extends StatelessWidget {
  const AddFriendSuccessScreen({super.key, required this.friendName});

  final String friendName;

  /// Extract the first word of the name ("Anna Kallin" → "Anna").
  String get _firstName {
    final parts = friendName.trim().split(' ');
    return parts.isNotEmpty ? parts.first : friendName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 73),

            // ── Onboarding image card (above text) ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset(
                  'assets/onboarding1.png',
                  width: double.infinity,
                  height: 282,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 36),

            // ── Text + button container ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Title: "Anna is in your orbit"
                  Text(
                    '$_firstName is in your orbit',
                    style: AppTextStyles.successTitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    "We'll remind you to connect in 2 weeks",
                    style: AppTextStyles.bodyRegular16.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.50),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // "Go to the orbit" button
                  ImageBackgroundButton(
                    label: 'Go to the orbit',
                    onTap: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    height: 56,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

