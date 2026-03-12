class Moment {
  final String id;
  final String friendId;
  final String type;
  final String? customType;
  final DateTime date;
  final String? note;
  final List<String> photoPaths;
  final DateTime createdAt;

  const Moment({
    required this.id,
    required this.friendId,
    required this.type,
    this.customType,
    required this.date,
    this.note,
    this.photoPaths = const [],
    required this.createdAt,
  });
}
