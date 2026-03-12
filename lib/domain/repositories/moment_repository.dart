import '../entities/moment.dart';

abstract class MomentRepository {
  Stream<List<Moment>> watchMomentsForFriend(String friendId);
  Future<Moment?> getMostRecentForFriend(String friendId);
  Future<void> addMoment(Moment moment);
  Future<void> updateMoment(Moment moment);
  Future<void> deleteMoment(String id);
}
