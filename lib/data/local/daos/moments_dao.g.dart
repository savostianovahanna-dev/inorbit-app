// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_dao.dart';

// ignore_for_file: type=lint
mixin _$MomentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $FriendsTableTable get friendsTable => attachedDatabase.friendsTable;
  $MomentsTableTable get momentsTable => attachedDatabase.momentsTable;
  MomentsDaoManager get managers => MomentsDaoManager(this);
}

class MomentsDaoManager {
  final _$MomentsDaoMixin _db;
  MomentsDaoManager(this._db);
  $$FriendsTableTableTableManager get friendsTable =>
      $$FriendsTableTableTableManager(_db.attachedDatabase, _db.friendsTable);
  $$MomentsTableTableTableManager get momentsTable =>
      $$MomentsTableTableTableManager(_db.attachedDatabase, _db.momentsTable);
}
