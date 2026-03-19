import '../../data/repositories/synced_friend_repository.dart';
import '../../data/repositories/synced_moment_repository.dart';

class SyncData {
  SyncData(this.friendRepo, this.momentRepo);

  final SyncedFriendRepository friendRepo;
  final SyncedMomentRepository momentRepo;

  Future<void> call() async {
    // Friends first: cascade delete removes orphaned moments automatically,
    // so moment sync starts with a clean slate for deleted friends.
    await friendRepo.syncFromRemote();
    await momentRepo.syncFromRemote();
  }
}
