import 'package:flutter/foundation.dart';

import '../../domain/entities/moment.dart';
import '../../domain/repositories/moment_repository.dart';
import '../remote/firebase_moment_repository.dart';
import 'local_moment_repository.dart';

class SyncedMomentRepository implements MomentRepository {
  SyncedMomentRepository(this.local, this.remote);

  final LocalMomentRepository local;
  final FirebaseMomentRepository remote;

  // ── Reads — always from local (offline-first) ─────────────────────────────

  @override
  Stream<List<Moment>> watchMomentsForFriend(String friendId) =>
      local.watchMomentsForFriend(friendId);

  @override
  Future<Moment?> getMostRecentForFriend(String friendId) =>
      local.getMostRecentForFriend(friendId);

  // ── Writes — to both; remote failure must not crash the app ──────────────

  @override
  Future<void> addMoment(Moment moment) async {
    await local.addMoment(moment);
    try {
      await remote.addMoment(moment);
    } catch (e) {
      debugPrint('Remote sync failed: $e');
    }
  }

  @override
  Future<void> updateMoment(Moment moment) async {
    await local.updateMoment(moment);
    try {
      await remote.updateMoment(moment);
    } catch (e) {
      debugPrint('Remote sync failed: $e');
    }
  }

  @override
  Future<void> deleteMoment(String id) async {
    await local.deleteMoment(id);
    try {
      await remote.deleteMoment(id);
    } catch (e) {
      debugPrint('Remote sync failed: $e');
    }
  }

  // ── Pull sync — Firestore → local ─────────────────────────────────────────

  /// Full replace sync: upserts all remote moments, then deletes any local
  /// moments that no longer exist in Firebase (e.g. deleted from console).
  Future<void> syncFromRemote() async {
    final moments = await remote.getAllMomentsOnce();
    for (final moment in moments) {
      await local.addOrUpdateMoment(moment);
    }
    await local.deleteNotInIds(moments.map((m) => m.id).toList());
  }
}
