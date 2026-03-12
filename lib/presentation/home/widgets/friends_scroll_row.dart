import 'package:flutter/material.dart';

import '../../../domain/entities/friend.dart';
import 'friend_card.dart';

/// Horizontally scrollable row of [FriendCard]s.
///
/// [lastMeetingType] is not available from the [Friend] entity alone — it
/// requires a separate Moments query. Pass that map from the calling widget
/// once you wire up the BLoC. Until then the cards show "No log yet".
class FriendsScrollRow extends StatelessWidget {
  const FriendsScrollRow({
    super.key,
    required this.friends,
    required this.onFriendTap,
  });

  final List<Friend> friends;
  final void Function(Friend) onFriendTap;

  // Height is driven by FriendCard content — keep in sync if card changes.
  static const _kRowHeight = 177.0;

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: _kRowHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index < friends.length - 1 ? 12 : 0,
            ),
            child: FriendCard(
              friend: friend,
              lastMeetingType: null, // wire via HomeBloc when available
              daysSinceContact: friend.lastConnectedAt != null
                  ? friend.daysSinceContact
                  : null,
              onTap: () => onFriendTap(friend),
            ),
          );
        },
      ),
    );
  }
}
