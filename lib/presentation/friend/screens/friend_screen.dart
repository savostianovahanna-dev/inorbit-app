import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/friend.dart';
import '../../../domain/entities/moment.dart';
import '../../../domain/repositories/friend_repository.dart';
import '../../../domain/repositories/moment_repository.dart';
import '../widgets/friend_header.dart';
import '../widgets/history_section.dart';
import '../widgets/profile_hero.dart';
import '../widgets/topics_section.dart';
import 'edit_friend_screen.dart';
import 'log_moment_screen_v2.dart';

/// Friend profile screen (Figma node 56-6064 "Friend").
///
/// Shows: nav header, hero card, topics, history moments, sticky CTA.
/// Accepts a [friend] entity and streams real moments from the DB.
class FriendScreen extends StatelessWidget {
  const FriendScreen({super.key, required this.friend});

  final Friend friend;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppColors.white,
            title: Text('Remove ${friend.name.split(' ').first}?'),
            content: Text(
              'This will permanently delete them and all their moments.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.bodyRegular14.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Delete',
                  style: AppTextStyles.bodyRegular14.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      await getIt<FriendRepository>().deleteFriend(friend.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<Friend?>(
          stream: getIt<FriendRepository>().watchFriendById(friend.id),
          builder: (context, friendSnap) {
            // Use the initial friend as seed so there's no blank flash on entry
            final liveFriend = friendSnap.data ?? friend;

            // Auto-pop if the friend was deleted externally
            if (friendSnap.hasData && friendSnap.data == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) Navigator.pop(context);
              });
            }

            return StreamBuilder<List<Moment>>(
              stream: getIt<MomentRepository>().watchMomentsForFriend(
                friend.id,
              ),
              builder: (context, momentSnap) {
                final moments = momentSnap.data ?? [];

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPad + 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FriendHeader(
                        name: liveFriend.name,
                        onDelete: () => _confirmDelete(context),
                        onEdit:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => EditFriendScreen(
                                      friend: liveFriend,
                                    ),
                              ),
                            ),
                      ),
                      const SizedBox(height: 8),
                      ProfileHero(friend: liveFriend),
                      if (liveFriend.notes != null &&
                          liveFriend.notes!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          liveFriend.notes!,
                          style: AppTextStyles.bodyRegular14,
                        ),
                      ],
                      const SizedBox(height: 20),
                      TopicsSection(friend: liveFriend),
                      const SizedBox(height: 20),
                      HistorySection(
                        moments: moments,
                        onAdd: () {
                          final variant = moments.length % 2 == 0 ? 1 : 2;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LogMomentScreenV2(
                                friend: liveFriend,
                                variant: variant,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
