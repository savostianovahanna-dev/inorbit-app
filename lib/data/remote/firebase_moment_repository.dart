import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/moment.dart';
import '../../domain/repositories/moment_repository.dart';
import '../serializers/moment_firestore_serializer.dart';

class FirebaseMomentRepository implements MomentRepository {
  FirebaseMomentRepository(this.userId, this.serializer);

  final String userId;
  final MomentFirestoreSerializer serializer;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('users/$userId/moments');

  // ── Streams ──────────────────────────────────────────────────────────────

  @override
  Stream<List<Moment>> watchMomentsForFriend(String friendId) => _collection
      .where('friendId', isEqualTo: friendId)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(serializer.fromFirestore).toList());

  // ── Futures ───────────────────────────────────────────────────────────────

  @override
  Future<Moment?> getMostRecentForFriend(String friendId) async {
    final snap =
        await _collection
            .where('friendId', isEqualTo: friendId)
            .orderBy('date', descending: true)
            .limit(1)
            .get();
    if (snap.docs.isEmpty) return null;
    return serializer.fromFirestore(snap.docs.first);
  }

  @override
  Future<void> addMoment(Moment moment) =>
      _collection.doc(moment.id).set(serializer.toFirestore(moment));

  @override
  Future<void> updateMoment(Moment moment) =>
      _collection.doc(moment.id).update(serializer.toFirestore(moment));

  @override
  Future<void> deleteMoment(String id) => _collection.doc(id).delete();

  Future<List<Moment>> getAllMomentsOnce() async {
    final snap = await _collection.get();
    return snap.docs.map(serializer.fromFirestore).toList();
  }
}
