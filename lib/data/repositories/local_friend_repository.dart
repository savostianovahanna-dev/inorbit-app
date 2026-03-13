import 'package:firebase_auth/firebase_auth.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/friend.dart';
import '../../domain/repositories/friend_repository.dart';
import '../local/daos/friends_dao.dart';
import '../serializers/friend_serializer.dart';

class LocalFriendRepository implements FriendRepository {
  LocalFriendRepository(this._dao, this._serializer);

  final FriendsDao _dao;
  final FriendSerializer _serializer;

  /// Returns the current user's UID, or empty string if not signed in.
  /// Read lazily on every call so it always reflects the current auth state.
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  // ── Streams ──────────────────────────────────────────────────────────────

  @override
  Stream<List<Friend>> watchAllFriends() => _dao
      .watchAllFriends(_uid)
      .map((rows) => rows.map(_serializer.fromDrift).toList())
      .handleError(_rethrowAsDatabaseFailure);

  @override
  Stream<Friend?> watchFriendById(String id) => _dao
      .watchFriendById(id, _uid)
      .map((row) => row == null ? null : _serializer.fromDrift(row))
      .handleError(_rethrowAsDatabaseFailure);

  @override
  Stream<List<Friend>> watchFriendsOrderedByOverdue() => _dao
      .watchOrderedByOverdue(_uid)
      .map((rows) => rows.map(_serializer.fromDrift).toList())
      .handleError(_rethrowAsDatabaseFailure);

  // ── Futures ───────────────────────────────────────────────────────────────

  @override
  Future<void> addFriend(Friend friend) async {
    try {
      await _dao.insertFriend(_serializer.toDrift(friend, userId: _uid));
    } catch (e) {
      throw DatabaseFailure(e.toString());
    }
  }

  @override
  Future<void> updateFriend(Friend friend) async {
    try {
      await _dao.updateFriendById(_serializer.toDrift(friend, userId: _uid));
    } catch (e) {
      throw DatabaseFailure(e.toString());
    }
  }

  @override
  Future<void> deleteFriend(String id) async {
    try {
      await _dao.deleteFriendById(id);
    } catch (e) {
      throw DatabaseFailure(e.toString());
    }
  }

  Future<void> addOrUpdateFriend(Friend friend) async {
    try {
      final companion = _serializer.toDrift(friend, userId: _uid);
      await _dao.insertOrUpdateFriend(companion); // ← через DAO, не через db
    } catch (e) {
      throw DatabaseFailure(e.toString());
    }
  }

  // ── Error helper ─────────────────────────────────────────────────────────

  static void _rethrowAsDatabaseFailure(Object error, StackTrace _) =>
      throw DatabaseFailure(error.toString());
}
