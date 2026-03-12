// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friends_dao.dart';

// ignore_for_file: type=lint
mixin _$FriendsDaoMixin on DatabaseAccessor<AppDatabase> {
  $FriendsTableTable get friendsTable => attachedDatabase.friendsTable;
  FriendsDaoManager get managers => FriendsDaoManager(this);
}

class FriendsDaoManager {
  final _$FriendsDaoMixin _db;
  FriendsDaoManager(this._db);
  $$FriendsTableTableTableManager get friendsTable =>
      $$FriendsTableTableTableManager(_db.attachedDatabase, _db.friendsTable);
}
