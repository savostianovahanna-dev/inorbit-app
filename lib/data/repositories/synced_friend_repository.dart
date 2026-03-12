import 'package:flutter/foundation.dart';

import '../../domain/entities/friend.dart';
import '../../domain/repositories/friend_repository.dart';
import '../remote/firebase_friend_repository.dart';
import 'local_friend_repository.dart';

class SyncedFriendRepository implements FriendRepository {
  SyncedFriendRepository(this.local, this.remote);

  final LocalFriendRepository local;
  final FirebaseFriendRepository remote;

  // ── Reads — always from local (offline-first) ─────────────────────────────

  @override
  Stream<List<Friend>> watchAllFriends() => local.watchAllFriends();

  @override
  Stream<Friend?> watchFriendById(String id) => local.watchFriendById(id);

  @override
  Stream<List<Friend>> watchFriendsOrderedByOverdue() =>
      local.watchFriendsOrderedByOverdue();

  // ── Writes — to both; remote failure must not crash the app ──────────────

  @override
  Future<void> addFriend(Friend friend) async {
    await local.addFriend(friend);
    try {
      await remote.addFriend(friend);
    } catch (e) {
      debugPrint('Remote sync failed: $e');
    }
  }

  @override
  Future<void> updateFriend(Friend friend) async {
    await local.updateFriend(friend);
    try {
      await remote.updateFriend(friend);
    } catch (e) {
      debugPrint('Remote sync failed: $e');
    }
  }

  @override
  Future<void> deleteFriend(String id) async {
    await local.deleteFriend(id);
    try {
      await remote.deleteFriend(id);
    } catch (e) {
      debugPrint('Remote sync failed: $e');
    }
  }

  // ── Pull sync — Firestore → local ─────────────────────────────────────────

  Future<void> syncFromRemote() async {
    final friends = await remote.getAllFriendsOnce();
    for (final friend in friends) {
      await local.addOrUpdateFriend(friend);
    }
  }
}
