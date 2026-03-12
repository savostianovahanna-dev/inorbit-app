import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/friend.dart';
import '../../../domain/entities/moment.dart';
import '../../../domain/repositories/moment_repository.dart';
import '../widgets/friend_header.dart';
import '../widgets/history_section.dart';
import '../widgets/profile_hero.dart';
import '../widgets/topics_section.dart';
import 'log_moment_screen.dart';

/// Friend profile screen (Figma node 56-6064 "Friend").
///
/// Shows: nav header, hero card, topics, history moments, sticky CTA.
/// Accepts a [friend] entity and streams real moments from the DB.
class FriendScreen extends StatelessWidget {
  const FriendScreen({super.key, required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<Moment>>(
          stream: getIt<MomentRepository>().watchMomentsForFriend(friend.id),
          builder: (context, snapshot) {
            final moments = snapshot.data ?? [];

            return Stack(
              children: [
                // Scrollable content with bottom padding for sticky button
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 80 + bottomPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FriendHeader(name: friend.name),
                      const SizedBox(height: 8),
                      ProfileHero(friend: friend),
                      const SizedBox(height: 20),
                      const TopicsSection(),
                      const SizedBox(height: 20),
                      HistorySection(moments: moments),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Sticky "Log moment" button pinned above safe area bottom
                Positioned(
                  bottom: bottomPad + 16,
                  left: 16,
                  right: 16,
                  child: _LogMomentButton(
                    friendName: friend.name,
                    friendId: friend.id,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LogMomentButton extends StatelessWidget {
  const _LogMomentButton({
    required this.friendName,
    required this.friendId,
  });

  final String friendName;
  final String friendId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LogMomentScreen(
            friendName: friendName,
            friendId: friendId,
          ),
        ),
      ),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.buttonDark,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 30,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CustomPaint(painter: _PlusIconPainter()),
            ),
            const SizedBox(width: 12),
            Text('Log moment', style: AppTextStyles.logButtonLabel),
          ],
        ),
      ),
    );
  }
}

class _PlusIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const arm = 5.83; // half of 11.67px from Figma

    canvas.drawLine(Offset(cx - arm, cy), Offset(cx + arm, cy), paint);
    canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy + arm), paint);
  }

  @override
  bool shouldRepaint(_PlusIconPainter old) => false;
}
