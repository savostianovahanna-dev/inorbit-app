import 'package:inorbit/data/serializers/moment_serializer.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/moment.dart';
import '../../domain/repositories/moment_repository.dart';
import '../local/daos/moments_dao.dart';

class LocalMomentRepository implements MomentRepository {
  LocalMomentRepository(this._dao, this._serializer);

  final MomentsDao _dao;
  final MomentSerializer _serializer;

  // ── Streams ──────────────────────────────────────────────────────────────

  @override
  Stream<List<Moment>> watchMomentsForFriend(String friendId) => _dao
      .watchMomentsForFriend(friendId)
      .map((rows) => rows.map(_serializer.fromDrift).toList())
      .handleError(_rethrowAsDatabaseFailure);

  // ── Futures ───────────────────────────────────────────────────────────────

  @override
  Future<Moment?> getMostRecentForFriend(String friendId) async {
    try {
      final row = await _dao.getMostRecentForFriend(friendId);
      return row == null ? null : _serializer.fromDrift(row);
    } catch (e) {
      throw DatabaseFailure(e.toString());
    }
  }

  @override
  Future<void> addMoment(Moment moment) async {
    try {
      await _dao.insertMoment(_serializer.toDrift(moment));
    } catch (e) {
      throw DatabaseFailure(e.toString());
    }
  }

  @override
  Future<void> updateMoment(Moment moment) async {
    try {
      await _dao.updateMomentById(_serializer.toDrift(moment));
    } catch (e) {
      throw DatabaseFailure(e.toString());
    }
  }

  @override
  Future<void> deleteMoment(String id) async {
    try {
      await _dao.deleteMomentById(id);
    } catch (e) {
      throw DatabaseFailure(e.toString());
    }
  }

  Future<void> addOrUpdateMoment(Moment moment) async {
    try {
      final companion = _serializer.toDrift(moment);
      await _dao.insertOrUpdateMoment(companion);
    } catch (e) {
      throw DatabaseFailure(e.toString());
    }
  }

  /// Deletes all local moments whose ID is NOT in [keepIds].
  Future<void> deleteNotInIds(List<String> keepIds) async {
    try {
      await _dao.deleteNotInIds(keepIds);
    } catch (e) {
      throw DatabaseFailure(e.toString());
    }
  }

  // ── Error helper ─────────────────────────────────────────────────────────

  static void _rethrowAsDatabaseFailure(Object error, StackTrace _) =>
      throw DatabaseFailure(error.toString());
}
