import 'package:drift/drift.dart';

import '../../domain/entities/friend.dart';
import '../local/app_database.dart';

class FriendMapper {
  const FriendMapper();

  Friend fromDrift(FriendsTableData data) => Friend(
        id: data.id,
        name: data.name,
        avatarPath: data.avatarPath,
        planetIndex: data.planetIndex,
        birthday: data.birthday,
        orbitTier: data.orbitTier,
        frequencyDays: data.frequencyDays,
        lastConnectedAt: data.lastConnectedAt,
        createdAt: data.createdAt,
      );

  FriendsTableCompanion toDrift(Friend entity, {String? userId}) =>
      FriendsTableCompanion(
        id: Value(entity.id),
        name: Value(entity.name),
        avatarPath: Value(entity.avatarPath),
        planetIndex: Value(entity.planetIndex),
        birthday: Value(entity.birthday),
        orbitTier: Value(entity.orbitTier),
        frequencyDays: Value(entity.frequencyDays),
        lastConnectedAt: Value(entity.lastConnectedAt),
        createdAt: Value(entity.createdAt),
        userId: Value(userId),
      );
}
