import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'daos/friends_dao.dart';
import 'daos/moments_dao.dart';

part 'app_database.g.dart';

// ─── Tables ───────────────────────────────────────────────────────────────────

@DataClassName('FriendsTableData')
class FriendsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get avatarPath => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  IntColumn get planetIndex => integer().nullable()();
  DateTimeColumn get birthday => dateTime().nullable()();
  TextColumn get orbitTier => text()();
  IntColumn get frequencyDays => integer()();
  DateTimeColumn get lastConnectedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  // Added in schema v2 — nullable so existing rows migrate gracefully.
  TextColumn get userId => text().nullable()();
  // Added in schema v4
  BoolColumn get remindBirthday =>
      boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MomentsTableData')
class MomentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get friendId =>
      text().references(FriendsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  // 'customType' clashes with Table.customType<T>() — use a distinct Dart name
  // while preserving the SQLite column name 'custom_type'.
  TextColumn get momentCustomType => text().nullable().named('custom_type')();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();

  /// JSON-encoded List<String> of local file paths.
  TextColumn get photoPaths => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [FriendsTable, MomentsTable],
  daos: [FriendsDao, MomentsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(friendsTable, friendsTable.userId);
      }
      if (from < 3) {
        await m.addColumn(
          friendsTable,
          friendsTable.avatarUrl as GeneratedColumn,
        );
      }
      if (from < 4) {
        await m.addColumn(friendsTable, friendsTable.remindBirthday);
        await m.addColumn(friendsTable, friendsTable.notes);
      }
    },
  );

  static QueryExecutor _openConnection() => driftDatabase(name: 'inorbit');
}
