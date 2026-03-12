import '../entities/friend.dart';

abstract class FriendRepository {
  Stream<List<Friend>> watchAllFriends();
  Stream<Friend?> watchFriendById(String id);
  Stream<List<Friend>> watchFriendsOrderedByOverdue();
  Future<void> addFriend(Friend friend);
  Future<void> updateFriend(Friend friend);
  Future<void> deleteFriend(String id);
}
