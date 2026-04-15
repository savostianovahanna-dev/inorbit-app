import 'dart:async';

import '../entities/friend.dart';
import '../entities/moment.dart';
import '../entities/stats_data.dart';
import '../repositories/friend_repository.dart';
import '../repositories/moment_repository.dart';

/// Combines the friends stream with per-friend moment streams and emits a
/// fresh [StatsData] whenever anything changes.
///
/// Since [MomentRepository] only exposes per-friend streams there is no
/// single "all moments" stream.  This use-case subscribes to every friend's
/// moment stream individually and re-computes stats on every emission from
/// any of them.
class GetStatsUseCase {
  const GetStatsUseCase(this._friendRepo, this._momentRepo);

  final FriendRepository _friendRepo;
  final MomentRepository _momentRepo;

  Stream<StatsData> call() {
    // Single-subscription controller — the BLoC consumes it once via
    // emit.forEach and cancels when the bloc is closed.
    final controller = StreamController<StatsData>();

    final momentsByFriend = <String, List<Moment>>{};
    var currentFriends = <Friend>[];
    StreamSubscription<List<Friend>>? friendsSub;
    final momentSubs = <String, StreamSubscription<List<Moment>>>{};

    void recompute() {
      if (controller.isClosed) return;
      final allMoments = momentsByFriend.values.expand((m) => m).toList();
      controller.add(_compute(currentFriends, allMoments));
    }

    void subscribeFriend(Friend friend) {
      momentSubs[friend.id] = _momentRepo
          .watchMomentsForFriend(friend.id)
          .listen((moments) {
            momentsByFriend[friend.id] = moments;
            recompute();
          });
    }

    controller.onListen = () {
      friendsSub = _friendRepo.watchFriendsOrderedByOverdue().listen((friends) {
        currentFriends = friends;
        final currentIds = friends.map((f) => f.id).toSet();

        // Cancel subscriptions for friends that were removed.
        for (final id in momentSubs.keys.toList()) {
          if (!currentIds.contains(id)) {
            momentSubs.remove(id)?.cancel();
            momentsByFriend.remove(id);
          }
        }

        // Subscribe to newly added friends.
        for (final f in friends) {
          if (!momentSubs.containsKey(f.id)) {
            subscribeFriend(f);
          }
        }

        // Emit immediately with data we already have for unchanged friends.
        recompute();
      }, onError: controller.addError);
    };

    controller.onCancel = () {
      friendsSub?.cancel();
      for (final sub in momentSubs.values) {
        sub.cancel();
      }
      momentSubs.clear();
      momentsByFriend.clear();
    };

    return controller.stream;
  }

  // ── Private computation ─────────────────────────────────────────────────────

  StatsData _compute(List<Friend> friends, List<Moment> allMoments) {
    final now = DateTime.now();

    // ── Most connected: friend with the most moments this calendar month ──
    final countThisMonth = <String, int>{};
    for (final m in allMoments) {
      if (m.date.year == now.year && m.date.month == now.month) {
        countThisMonth[m.friendId] = (countThisMonth[m.friendId] ?? 0) + 1;
      }
    }

    Friend? mostConnectedFriend;
    var mostConnectedCount = 0;
    for (final entry in countThisMonth.entries) {
      if (entry.value > mostConnectedCount) {
        mostConnectedCount = entry.value;
        try {
          mostConnectedFriend = friends.firstWhere((f) => f.id == entry.key);
        } catch (_) {
          // friend was deleted but moment still present — skip
        }
      }
    }

    // ── Needs attention: first friend in the pre-sorted overdue list ─────
    final needsAttentionFriend = friends.isEmpty ? null : friends.first;

    // ── Activity grid: all moments grouped by calendar day ───────────────
    final activityByDay = <DateTime, int>{};
    final momentsByDay = <DateTime, List<Moment>>{};
    for (final m in allMoments) {
      final key = DateTime(m.date.year, m.date.month, m.date.day);
      activityByDay[key] = (activityByDay[key] ?? 0) + 1;
      (momentsByDay[key] ??= []).add(m);
    }

    return StatsData(
      totalFriends: friends.length,
      mostConnectedFriend: mostConnectedFriend,
      mostConnectedCount: mostConnectedCount,
      needsAttentionFriend: needsAttentionFriend,
      friendsOrderedByOverdue: List.unmodifiable(friends),
      activityByDay: Map.unmodifiable(activityByDay),
      momentsByDay: Map.unmodifiable(momentsByDay),
    );
  }
}
