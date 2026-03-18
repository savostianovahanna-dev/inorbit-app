import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/friend.dart';

class FriendFirestoreSerializer {
  Friend fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Friend(
      id: doc.id,
      name: data['name'] as String,
      avatarPath: data['avatarPath'] as String?,
      planetIndex: data['planetIndex'] as int?,
      birthday:
          data['birthday'] == null
              ? null
              : (data['birthday'] as Timestamp).toDate(),
      orbitTier: data['orbitTier'] as String,
      frequencyDays: data['frequencyDays'] as int,
      lastConnectedAt:
          data['lastConnectedAt'] == null
              ? null
              : (data['lastConnectedAt'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      avatarUrl: data['avatarUrl'] as String?,
      remindBirthday: (data['remindBirthday'] as bool?) ?? true,
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore(Friend friend) {
    final map = <String, dynamic>{
      'name': friend.name,
      'orbitTier': friend.orbitTier,
      'frequencyDays': friend.frequencyDays,
      'createdAt': Timestamp.fromDate(friend.createdAt),
    };
    if (friend.avatarPath != null) map['avatarPath'] = friend.avatarPath;
    if (friend.planetIndex != null) map['planetIndex'] = friend.planetIndex;
    if (friend.birthday != null) {
      map['birthday'] = Timestamp.fromDate(friend.birthday!);
    }
    if (friend.lastConnectedAt != null) {
      map['lastConnectedAt'] = Timestamp.fromDate(friend.lastConnectedAt!);
    }
    if (friend.avatarUrl != null) map['avatarUrl'] = friend.avatarUrl;
    if (!friend.remindBirthday) map['remindBirthday'] = false;
    if (friend.notes != null) map['notes'] = friend.notes;
    return map;
  }
}
