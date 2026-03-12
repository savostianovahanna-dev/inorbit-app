import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/friend.dart';
import '../../domain/repositories/friend_repository.dart';
import '../models/friend_firestore_mapper.dart';

class FirebaseFriendRepository implements FriendRepository {
  FirebaseFriendRepository(this.userId, this.mapper);

  final String userId;
  final FriendFirestoreMapper mapper;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('users/$userId/friends');

  // ── Streams ──────────────────────────────────────────────────────────────

  @override
  Stream<List<Friend>> watchAllFriends() => _collection
      .snapshots()
      .map((snap) => snap.docs.map(mapper.fromFirestore).toList());

  @override
  Stream<Friend?> watchFriendById(String id) => _collection
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? mapper.fromFirestore(doc) : null);

  @override
  Stream<List<Friend>> watchFriendsOrderedByOverdue() => _collection
      .orderBy('lastConnectedAt', descending: false)
      .snapshots()
      .map((snap) => snap.docs.map(mapper.fromFirestore).toList());

  // ── Futures ───────────────────────────────────────────────────────────────

  @override
  Future<void> addFriend(Friend friend) =>
      _collection.doc(friend.id).set(mapper.toFirestore(friend));

  @override
  Future<void> updateFriend(Friend friend) =>
      _collection.doc(friend.id).update(mapper.toFirestore(friend));

  @override
  Future<void> deleteFriend(String id) => _collection.doc(id).delete();

  Future<List<Friend>> getAllFriendsOnce() async {
    final snap = await _collection.get();
    return snap.docs.map(mapper.fromFirestore).toList();
  }
}
