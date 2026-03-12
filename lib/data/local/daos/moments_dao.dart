import 'package:drift/drift.dart';
import '../app_database.dart';

part 'moments_dao.g.dart';

@DriftAccessor(tables: [MomentsTable])
class MomentsDao extends DatabaseAccessor<AppDatabase> with _$MomentsDaoMixin {
  MomentsDao(super.db);

  Stream<List<MomentsTableData>> watchMomentsForFriend(String friendId) =>
      (select(momentsTable)
            ..where((t) => t.friendId.equals(friendId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          .watch();

  Future<MomentsTableData?> getMostRecentForFriend(String friendId) =>
      (select(momentsTable)
            ..where((t) => t.friendId.equals(friendId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<void> insertMoment(MomentsTableCompanion c) =>
      into(momentsTable).insert(c);

  Future<void> updateMomentById(MomentsTableCompanion c) =>
      (update(momentsTable)..where((t) => t.id.equals(c.id.value))).write(c);

  Future<void> deleteMomentById(String id) =>
      (delete(momentsTable)..where((t) => t.id.equals(id))).go();
}
