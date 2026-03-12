import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/moment.dart';

class MomentFirestoreMapper {
  Moment fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Moment(
      id: doc.id,
      friendId: data['friendId'] as String,
      type: data['type'] as String,
      customType: data['customType'] as String?,
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] as String?,
      photoPaths: List<String>.from(data['photoPaths'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore(Moment moment) {
    final map = <String, dynamic>{
      'friendId': moment.friendId,
      'type': moment.type,
      'date': Timestamp.fromDate(moment.date),
      'photoPaths': moment.photoPaths,
      'createdAt': Timestamp.fromDate(moment.createdAt),
    };
    if (moment.customType != null) map['customType'] = moment.customType;
    if (moment.note != null) map['note'] = moment.note;
    return map;
  }
}
