import '../../data/repositories/synced_friend_repository.dart';
import '../../data/repositories/synced_moment_repository.dart';

class SyncData {
  SyncData(this.friendRepo, this.momentRepo);

  final SyncedFriendRepository friendRepo;
  final SyncedMomentRepository momentRepo;

  Future<void> call() async {
    await Future.wait([
      friendRepo.syncFromRemote(),
      momentRepo.syncFromRemote(),
    ]);
  }
}
