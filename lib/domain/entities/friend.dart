class Friend {
  final String id;
  final String name;
  final String? avatarPath;
  final String? avatarUrl;
  final int? planetIndex;
  final DateTime? birthday;
  final String orbitTier;
  final int frequencyDays;
  final DateTime? lastConnectedAt;
  final DateTime createdAt;

  const Friend({
    required this.id,
    required this.name,
    this.avatarPath,
    this.planetIndex,
    this.birthday,
    this.avatarUrl,
    required this.orbitTier,
    required this.frequencyDays,
    this.lastConnectedAt,
    required this.createdAt,
  });

  /// Days elapsed since last contact. Returns 9999 when never contacted.
  int get daysSinceContact {
    if (lastConnectedAt == null) return 9999;
    return DateTime.now().difference(lastConnectedAt!).inDays;
  }

  /// True when the contact cadence has been exceeded.
  bool get isOverdue => daysSinceContact > frequencyDays;
}
