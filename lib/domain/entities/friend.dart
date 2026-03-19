class Friend {
  final String id;
  final String name;
  final String? avatarPath;
  final String? avatarUrl;
  final int? planetIndex;
  final DateTime? birthday;
  final bool remindBirthday;
  final String? notes;
  final String orbitTier;
  final int frequencyDays;
  final DateTime? lastConnectedAt;
  final DateTime createdAt;
  final List<String> topics;

  const Friend({
    required this.id,
    required this.name,
    this.avatarPath,
    this.planetIndex,
    this.birthday,
    this.remindBirthday = true,
    this.notes,
    this.avatarUrl,
    required this.orbitTier,
    required this.frequencyDays,
    this.lastConnectedAt,
    required this.createdAt,
    this.topics = const [],
  });

  /// Days elapsed since last contact. Returns 9999 when never contacted.
  int get daysSinceContact {
    if (lastConnectedAt == null) return 9999;
    return DateTime.now().difference(lastConnectedAt!).inDays;
  }

  /// True when the contact cadence has been exceeded.
  bool get isOverdue => daysSinceContact > frequencyDays;

  Friend copyWith({
    String? id,
    String? name,
    Object? avatarPath = _sentinel,
    Object? avatarUrl = _sentinel,
    Object? planetIndex = _sentinel,
    Object? birthday = _sentinel,
    bool? remindBirthday,
    Object? notes = _sentinel,
    String? orbitTier,
    int? frequencyDays,
    Object? lastConnectedAt = _sentinel,
    DateTime? createdAt,
    List<String>? topics,
  }) =>
      Friend(
        id: id ?? this.id,
        name: name ?? this.name,
        avatarPath: avatarPath == _sentinel
            ? this.avatarPath
            : avatarPath as String?,
        avatarUrl: avatarUrl == _sentinel
            ? this.avatarUrl
            : avatarUrl as String?,
        planetIndex: planetIndex == _sentinel
            ? this.planetIndex
            : planetIndex as int?,
        birthday:
            birthday == _sentinel ? this.birthday : birthday as DateTime?,
        remindBirthday: remindBirthday ?? this.remindBirthday,
        notes: notes == _sentinel ? this.notes : notes as String?,
        orbitTier: orbitTier ?? this.orbitTier,
        frequencyDays: frequencyDays ?? this.frequencyDays,
        lastConnectedAt: lastConnectedAt == _sentinel
            ? this.lastConnectedAt
            : lastConnectedAt as DateTime?,
        createdAt: createdAt ?? this.createdAt,
        topics: topics ?? this.topics,
      );
}

// Sentinel value used by copyWith to distinguish "not provided" from null.
const Object _sentinel = Object();
