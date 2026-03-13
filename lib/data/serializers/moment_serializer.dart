import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/entities/moment.dart';
import '../local/app_database.dart';

class MomentSerializer {
  const MomentSerializer();

  Moment fromDrift(MomentsTableData data) => Moment(
    id: data.id,
    friendId: data.friendId,
    type: data.type,
    customType: data.momentCustomType,
    date: data.date,
    note: data.note,
    photoPaths:
        data.photoPaths == null
            ? const []
            : List<String>.from(jsonDecode(data.photoPaths!) as List),
    createdAt: data.createdAt,
  );

  MomentsTableCompanion toDrift(Moment entity) => MomentsTableCompanion(
    id: Value(entity.id),
    friendId: Value(entity.friendId),
    type: Value(entity.type),
    momentCustomType: Value(entity.customType),
    date: Value(entity.date),
    note: Value(entity.note),
    photoPaths: Value(
      entity.photoPaths.isEmpty ? null : jsonEncode(entity.photoPaths),
    ),
    createdAt: Value(entity.createdAt),
  );
}
