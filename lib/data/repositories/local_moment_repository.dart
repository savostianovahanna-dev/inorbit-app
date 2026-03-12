import '../../core/error/failures.dart';
import '../../domain/entities/moment.dart';
import '../../domain/repositories/moment_repository.dart';
import '../local/daos/moments_dao.dart';
import '../models/moment_mapper.dart';

class LocalMomentRepository implements MomentRepository {
  LocalMomentRepository(this._dao, this._mapper);

  final MomentsDao _dao;
  final MomentMapper _mapper;

  // ── Streams ──────────────────────────────────────────────────────────────

  @override
  Stream<List<Moment>> watchMomentsForFriend(String friendId) => _dao
      .watchMomentsForFriend(friendId)
      .map((rows) => rows.map(_mapper.fromDrift).toList())
      .handleError(_rethrowAsDatabaseFailure);

  // ── Futures ───────────────────────────────────────────────────────────────

  @override
  Future<Moment?> getMostRecentForFriend(String friendId) async {
    try {
      final row = await _dao.getMostRecentForFriend(friendId);
      return row == null ? null : _mapper.fromDrift(row);
    } catch (e) {
      throw DatabaseFailure(e.toString());
    }
  }

  @override
  Future<void> addMoment(Moment moment) async {
    try {
      await _dao.insertMoment(_mapper.toDrift(moment));
    } catch (e) {
      throw DatabaseFailure(e.toString());
    }
  }

  @override
  Future<void> updateMoment(Moment moment) async {
    try {
      await _dao.updateMomentById(_mapper.toDrift(moment));
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
      final companion = _mapper.toDrift(moment);
      await _dao.insertOrUpdateMoment(companion);
    } catch (e) {
      throw DatabaseFailure(e.toString());
    }
  }

  // ── Error helper ─────────────────────────────────────────────────────────

  static void _rethrowAsDatabaseFailure(Object error, StackTrace _) =>
      throw DatabaseFailure(error.toString());
}
