import 'package:drift/drift.dart';
import '../app_database.dart';

part 'friends_dao.g.dart';

/// Drift NativeDatabase stores DateTime as unix microseconds (INTEGER).
/// Overdue score = days_elapsed - frequency_days.
/// SQL: (strftime('%s','now') × 1_000_000 − last_connected_at) ÷ 86_400_000_000
/// NULL last_connected_at → sentinel 9 999 999 (sorts to top = most overdue).
const _overdueExpr = CustomExpression<int>(
  "CASE WHEN last_connected_at IS NULL THEN 9999999 "
  "ELSE CAST((strftime('%s','now') * 1000000 - last_connected_at) "
  "/ 86400000000.0 AS INTEGER) - frequency_days END",
);

@DriftAccessor(tables: [FriendsTable])
class FriendsDao extends DatabaseAccessor<AppDatabase> with _$FriendsDaoMixin {
  FriendsDao(super.db);

  Stream<List<FriendsTableData>> watchAllFriends(String userId) =>
      (select(friendsTable)..where((t) => t.userId.equals(userId))).watch();

  Stream<FriendsTableData?> watchFriendById(String id, String userId) =>
      (select(friendsTable)
            ..where((t) => t.id.equals(id) & t.userId.equals(userId)))
          .watchSingleOrNull();

  Future<void> insertFriend(FriendsTableCompanion c) =>
      into(friendsTable).insert(c);

  Future<void> updateFriendById(FriendsTableCompanion c) =>
      (update(friendsTable)..where((t) => t.id.equals(c.id.value))).write(c);

  Future<void> deleteFriendById(String id) =>
      (delete(friendsTable)..where((t) => t.id.equals(id))).go();

  Stream<List<FriendsTableData>> watchOrderedByOverdue(String userId) =>
      (select(friendsTable)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([
              (_) => OrderingTerm(
                    expression: _overdueExpr,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .watch();
}
