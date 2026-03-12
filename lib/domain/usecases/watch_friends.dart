import '../entities/friend.dart';
import '../repositories/friend_repository.dart';

class WatchFriends {
  const WatchFriends(this._repository);

  final FriendRepository _repository;

  Stream<List<Friend>> call() => _repository.watchFriendsOrderedByOverdue();
}
