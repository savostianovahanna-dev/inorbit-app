import 'friend.dart';
import 'moment.dart';

/// Aggregated statistics passed to the Stats screen.
class StatsData {
  const StatsData({
    required this.totalFriends,
    this.mostConnectedFriend,
    required this.mostConnectedCount,
    this.needsAttentionFriend,
    required this.friendsOrderedByOverdue,
    required this.activityByDay,
    required this.momentsByDay,
  });

  /// Total number of friends in the user's orbit.
  final int totalFriends;

  /// Friend with the most moments logged this calendar month, or null when
  /// no moments have been recorded yet this month.
  final Friend? mostConnectedFriend;

  /// Number of moments logged by [mostConnectedFriend] this calendar month.
  final int mostConnectedCount;

  /// Friend who is most overdue for contact (highest overdue score).
  /// Null when the orbit is empty.
  final Friend? needsAttentionFriend;

  /// All friends sorted by overdue score descending (most overdue first).
  final List<Friend> friendsOrderedByOverdue;

  /// Total moments per calendar day.
  /// Keys are midnight-local DateTimes: DateTime(year, month, day).
  final Map<DateTime, int> activityByDay;

  /// All moments grouped by calendar day.
  /// Keys are midnight-local DateTimes: DateTime(year, month, day).
  final Map<DateTime, List<Moment>> momentsByDay;
}
