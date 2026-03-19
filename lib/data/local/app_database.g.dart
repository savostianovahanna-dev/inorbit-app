// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FriendsTableTable extends FriendsTable
    with TableInfo<$FriendsTableTable, FriendsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FriendsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planetIndexMeta = const VerificationMeta(
    'planetIndex',
  );
  @override
  late final GeneratedColumn<int> planetIndex = GeneratedColumn<int>(
    'planet_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthdayMeta = const VerificationMeta(
    'birthday',
  );
  @override
  late final GeneratedColumn<DateTime> birthday = GeneratedColumn<DateTime>(
    'birthday',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orbitTierMeta = const VerificationMeta(
    'orbitTier',
  );
  @override
  late final GeneratedColumn<String> orbitTier = GeneratedColumn<String>(
    'orbit_tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyDaysMeta = const VerificationMeta(
    'frequencyDays',
  );
  @override
  late final GeneratedColumn<int> frequencyDays = GeneratedColumn<int>(
    'frequency_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastConnectedAtMeta = const VerificationMeta(
    'lastConnectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastConnectedAt =
      GeneratedColumn<DateTime>(
        'last_connected_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindBirthdayMeta = const VerificationMeta(
    'remindBirthday',
  );
  @override
  late final GeneratedColumn<bool> remindBirthday = GeneratedColumn<bool>(
    'remind_birthday',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("remind_birthday" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _topicsMeta = const VerificationMeta('topics');
  @override
  late final GeneratedColumn<String> topics = GeneratedColumn<String>(
    'topics',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    avatarPath,
    avatarUrl,
    planetIndex,
    birthday,
    orbitTier,
    frequencyDays,
    lastConnectedAt,
    createdAt,
    userId,
    remindBirthday,
    notes,
    topics,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'friends_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<FriendsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('planet_index')) {
      context.handle(
        _planetIndexMeta,
        planetIndex.isAcceptableOrUnknown(
          data['planet_index']!,
          _planetIndexMeta,
        ),
      );
    }
    if (data.containsKey('birthday')) {
      context.handle(
        _birthdayMeta,
        birthday.isAcceptableOrUnknown(data['birthday']!, _birthdayMeta),
      );
    }
    if (data.containsKey('orbit_tier')) {
      context.handle(
        _orbitTierMeta,
        orbitTier.isAcceptableOrUnknown(data['orbit_tier']!, _orbitTierMeta),
      );
    } else if (isInserting) {
      context.missing(_orbitTierMeta);
    }
    if (data.containsKey('frequency_days')) {
      context.handle(
        _frequencyDaysMeta,
        frequencyDays.isAcceptableOrUnknown(
          data['frequency_days']!,
          _frequencyDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_frequencyDaysMeta);
    }
    if (data.containsKey('last_connected_at')) {
      context.handle(
        _lastConnectedAtMeta,
        lastConnectedAt.isAcceptableOrUnknown(
          data['last_connected_at']!,
          _lastConnectedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('remind_birthday')) {
      context.handle(
        _remindBirthdayMeta,
        remindBirthday.isAcceptableOrUnknown(
          data['remind_birthday']!,
          _remindBirthdayMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('topics')) {
      context.handle(
        _topicsMeta,
        topics.isAcceptableOrUnknown(data['topics']!, _topicsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FriendsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FriendsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      planetIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planet_index'],
      ),
      birthday: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birthday'],
      ),
      orbitTier:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}orbit_tier'],
          )!,
      frequencyDays:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}frequency_days'],
          )!,
      lastConnectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_connected_at'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      remindBirthday:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}remind_birthday'],
          )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      topics: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topics'],
      ),
    );
  }

  @override
  $FriendsTableTable createAlias(String alias) {
    return $FriendsTableTable(attachedDatabase, alias);
  }
}

class FriendsTableData extends DataClass
    implements Insertable<FriendsTableData> {
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
  final String? userId;
  final bool remindBirthday;
  final String? notes;
  final String? topics;
  const FriendsTableData({
    required this.id,
    required this.name,
    this.avatarPath,
    this.avatarUrl,
    this.planetIndex,
    this.birthday,
    required this.orbitTier,
    required this.frequencyDays,
    this.lastConnectedAt,
    required this.createdAt,
    this.userId,
    required this.remindBirthday,
    this.notes,
    this.topics,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || planetIndex != null) {
      map['planet_index'] = Variable<int>(planetIndex);
    }
    if (!nullToAbsent || birthday != null) {
      map['birthday'] = Variable<DateTime>(birthday);
    }
    map['orbit_tier'] = Variable<String>(orbitTier);
    map['frequency_days'] = Variable<int>(frequencyDays);
    if (!nullToAbsent || lastConnectedAt != null) {
      map['last_connected_at'] = Variable<DateTime>(lastConnectedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['remind_birthday'] = Variable<bool>(remindBirthday);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || topics != null) {
      map['topics'] = Variable<String>(topics);
    }
    return map;
  }

  FriendsTableCompanion toCompanion(bool nullToAbsent) {
    return FriendsTableCompanion(
      id: Value(id),
      name: Value(name),
      avatarPath:
          avatarPath == null && nullToAbsent
              ? const Value.absent()
              : Value(avatarPath),
      avatarUrl:
          avatarUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(avatarUrl),
      planetIndex:
          planetIndex == null && nullToAbsent
              ? const Value.absent()
              : Value(planetIndex),
      birthday:
          birthday == null && nullToAbsent
              ? const Value.absent()
              : Value(birthday),
      orbitTier: Value(orbitTier),
      frequencyDays: Value(frequencyDays),
      lastConnectedAt:
          lastConnectedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(lastConnectedAt),
      createdAt: Value(createdAt),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      remindBirthday: Value(remindBirthday),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      topics:
          topics == null && nullToAbsent ? const Value.absent() : Value(topics),
    );
  }

  factory FriendsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FriendsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      planetIndex: serializer.fromJson<int?>(json['planetIndex']),
      birthday: serializer.fromJson<DateTime?>(json['birthday']),
      orbitTier: serializer.fromJson<String>(json['orbitTier']),
      frequencyDays: serializer.fromJson<int>(json['frequencyDays']),
      lastConnectedAt: serializer.fromJson<DateTime?>(json['lastConnectedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      userId: serializer.fromJson<String?>(json['userId']),
      remindBirthday: serializer.fromJson<bool>(json['remindBirthday']),
      notes: serializer.fromJson<String?>(json['notes']),
      topics: serializer.fromJson<String?>(json['topics']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'planetIndex': serializer.toJson<int?>(planetIndex),
      'birthday': serializer.toJson<DateTime?>(birthday),
      'orbitTier': serializer.toJson<String>(orbitTier),
      'frequencyDays': serializer.toJson<int>(frequencyDays),
      'lastConnectedAt': serializer.toJson<DateTime?>(lastConnectedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'userId': serializer.toJson<String?>(userId),
      'remindBirthday': serializer.toJson<bool>(remindBirthday),
      'notes': serializer.toJson<String?>(notes),
      'topics': serializer.toJson<String?>(topics),
    };
  }

  FriendsTableData copyWith({
    String? id,
    String? name,
    Value<String?> avatarPath = const Value.absent(),
    Value<String?> avatarUrl = const Value.absent(),
    Value<int?> planetIndex = const Value.absent(),
    Value<DateTime?> birthday = const Value.absent(),
    String? orbitTier,
    int? frequencyDays,
    Value<DateTime?> lastConnectedAt = const Value.absent(),
    DateTime? createdAt,
    Value<String?> userId = const Value.absent(),
    bool? remindBirthday,
    Value<String?> notes = const Value.absent(),
    Value<String?> topics = const Value.absent(),
  }) => FriendsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    planetIndex: planetIndex.present ? planetIndex.value : this.planetIndex,
    birthday: birthday.present ? birthday.value : this.birthday,
    orbitTier: orbitTier ?? this.orbitTier,
    frequencyDays: frequencyDays ?? this.frequencyDays,
    lastConnectedAt:
        lastConnectedAt.present ? lastConnectedAt.value : this.lastConnectedAt,
    createdAt: createdAt ?? this.createdAt,
    userId: userId.present ? userId.value : this.userId,
    remindBirthday: remindBirthday ?? this.remindBirthday,
    notes: notes.present ? notes.value : this.notes,
    topics: topics.present ? topics.value : this.topics,
  );
  FriendsTableData copyWithCompanion(FriendsTableCompanion data) {
    return FriendsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      avatarPath:
          data.avatarPath.present ? data.avatarPath.value : this.avatarPath,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      planetIndex:
          data.planetIndex.present ? data.planetIndex.value : this.planetIndex,
      birthday: data.birthday.present ? data.birthday.value : this.birthday,
      orbitTier: data.orbitTier.present ? data.orbitTier.value : this.orbitTier,
      frequencyDays:
          data.frequencyDays.present
              ? data.frequencyDays.value
              : this.frequencyDays,
      lastConnectedAt:
          data.lastConnectedAt.present
              ? data.lastConnectedAt.value
              : this.lastConnectedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      remindBirthday:
          data.remindBirthday.present
              ? data.remindBirthday.value
              : this.remindBirthday,
      notes: data.notes.present ? data.notes.value : this.notes,
      topics: data.topics.present ? data.topics.value : this.topics,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FriendsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('planetIndex: $planetIndex, ')
          ..write('birthday: $birthday, ')
          ..write('orbitTier: $orbitTier, ')
          ..write('frequencyDays: $frequencyDays, ')
          ..write('lastConnectedAt: $lastConnectedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('userId: $userId, ')
          ..write('remindBirthday: $remindBirthday, ')
          ..write('notes: $notes, ')
          ..write('topics: $topics')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    avatarPath,
    avatarUrl,
    planetIndex,
    birthday,
    orbitTier,
    frequencyDays,
    lastConnectedAt,
    createdAt,
    userId,
    remindBirthday,
    notes,
    topics,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FriendsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.avatarPath == this.avatarPath &&
          other.avatarUrl == this.avatarUrl &&
          other.planetIndex == this.planetIndex &&
          other.birthday == this.birthday &&
          other.orbitTier == this.orbitTier &&
          other.frequencyDays == this.frequencyDays &&
          other.lastConnectedAt == this.lastConnectedAt &&
          other.createdAt == this.createdAt &&
          other.userId == this.userId &&
          other.remindBirthday == this.remindBirthday &&
          other.notes == this.notes &&
          other.topics == this.topics);
}

class FriendsTableCompanion extends UpdateCompanion<FriendsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> avatarPath;
  final Value<String?> avatarUrl;
  final Value<int?> planetIndex;
  final Value<DateTime?> birthday;
  final Value<String> orbitTier;
  final Value<int> frequencyDays;
  final Value<DateTime?> lastConnectedAt;
  final Value<DateTime> createdAt;
  final Value<String?> userId;
  final Value<bool> remindBirthday;
  final Value<String?> notes;
  final Value<String?> topics;
  final Value<int> rowid;
  const FriendsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.planetIndex = const Value.absent(),
    this.birthday = const Value.absent(),
    this.orbitTier = const Value.absent(),
    this.frequencyDays = const Value.absent(),
    this.lastConnectedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.remindBirthday = const Value.absent(),
    this.notes = const Value.absent(),
    this.topics = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FriendsTableCompanion.insert({
    required String id,
    required String name,
    this.avatarPath = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.planetIndex = const Value.absent(),
    this.birthday = const Value.absent(),
    required String orbitTier,
    required int frequencyDays,
    this.lastConnectedAt = const Value.absent(),
    required DateTime createdAt,
    this.userId = const Value.absent(),
    this.remindBirthday = const Value.absent(),
    this.notes = const Value.absent(),
    this.topics = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       orbitTier = Value(orbitTier),
       frequencyDays = Value(frequencyDays),
       createdAt = Value(createdAt);
  static Insertable<FriendsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? avatarPath,
    Expression<String>? avatarUrl,
    Expression<int>? planetIndex,
    Expression<DateTime>? birthday,
    Expression<String>? orbitTier,
    Expression<int>? frequencyDays,
    Expression<DateTime>? lastConnectedAt,
    Expression<DateTime>? createdAt,
    Expression<String>? userId,
    Expression<bool>? remindBirthday,
    Expression<String>? notes,
    Expression<String>? topics,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (planetIndex != null) 'planet_index': planetIndex,
      if (birthday != null) 'birthday': birthday,
      if (orbitTier != null) 'orbit_tier': orbitTier,
      if (frequencyDays != null) 'frequency_days': frequencyDays,
      if (lastConnectedAt != null) 'last_connected_at': lastConnectedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (userId != null) 'user_id': userId,
      if (remindBirthday != null) 'remind_birthday': remindBirthday,
      if (notes != null) 'notes': notes,
      if (topics != null) 'topics': topics,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FriendsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? avatarPath,
    Value<String?>? avatarUrl,
    Value<int?>? planetIndex,
    Value<DateTime?>? birthday,
    Value<String>? orbitTier,
    Value<int>? frequencyDays,
    Value<DateTime?>? lastConnectedAt,
    Value<DateTime>? createdAt,
    Value<String?>? userId,
    Value<bool>? remindBirthday,
    Value<String?>? notes,
    Value<String?>? topics,
    Value<int>? rowid,
  }) {
    return FriendsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      planetIndex: planetIndex ?? this.planetIndex,
      birthday: birthday ?? this.birthday,
      orbitTier: orbitTier ?? this.orbitTier,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      remindBirthday: remindBirthday ?? this.remindBirthday,
      notes: notes ?? this.notes,
      topics: topics ?? this.topics,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (planetIndex.present) {
      map['planet_index'] = Variable<int>(planetIndex.value);
    }
    if (birthday.present) {
      map['birthday'] = Variable<DateTime>(birthday.value);
    }
    if (orbitTier.present) {
      map['orbit_tier'] = Variable<String>(orbitTier.value);
    }
    if (frequencyDays.present) {
      map['frequency_days'] = Variable<int>(frequencyDays.value);
    }
    if (lastConnectedAt.present) {
      map['last_connected_at'] = Variable<DateTime>(lastConnectedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (remindBirthday.present) {
      map['remind_birthday'] = Variable<bool>(remindBirthday.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (topics.present) {
      map['topics'] = Variable<String>(topics.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FriendsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('planetIndex: $planetIndex, ')
          ..write('birthday: $birthday, ')
          ..write('orbitTier: $orbitTier, ')
          ..write('frequencyDays: $frequencyDays, ')
          ..write('lastConnectedAt: $lastConnectedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('userId: $userId, ')
          ..write('remindBirthday: $remindBirthday, ')
          ..write('notes: $notes, ')
          ..write('topics: $topics, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MomentsTableTable extends MomentsTable
    with TableInfo<$MomentsTableTable, MomentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MomentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _friendIdMeta = const VerificationMeta(
    'friendId',
  );
  @override
  late final GeneratedColumn<String> friendId = GeneratedColumn<String>(
    'friend_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES friends_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _momentCustomTypeMeta = const VerificationMeta(
    'momentCustomType',
  );
  @override
  late final GeneratedColumn<String> momentCustomType = GeneratedColumn<String>(
    'custom_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathsMeta = const VerificationMeta(
    'photoPaths',
  );
  @override
  late final GeneratedColumn<String> photoPaths = GeneratedColumn<String>(
    'photo_paths',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    friendId,
    type,
    momentCustomType,
    date,
    note,
    photoPaths,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'moments_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MomentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('friend_id')) {
      context.handle(
        _friendIdMeta,
        friendId.isAcceptableOrUnknown(data['friend_id']!, _friendIdMeta),
      );
    } else if (isInserting) {
      context.missing(_friendIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('custom_type')) {
      context.handle(
        _momentCustomTypeMeta,
        momentCustomType.isAcceptableOrUnknown(
          data['custom_type']!,
          _momentCustomTypeMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('photo_paths')) {
      context.handle(
        _photoPathsMeta,
        photoPaths.isAcceptableOrUnknown(data['photo_paths']!, _photoPathsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MomentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MomentsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      friendId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}friend_id'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      momentCustomType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_type'],
      ),
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      photoPaths: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_paths'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $MomentsTableTable createAlias(String alias) {
    return $MomentsTableTable(attachedDatabase, alias);
  }
}

class MomentsTableData extends DataClass
    implements Insertable<MomentsTableData> {
  final String id;
  final String friendId;
  final String type;
  final String? momentCustomType;
  final DateTime date;
  final String? note;

  /// JSON-encoded List<String> of local file paths.
  final String? photoPaths;
  final DateTime createdAt;
  const MomentsTableData({
    required this.id,
    required this.friendId,
    required this.type,
    this.momentCustomType,
    required this.date,
    this.note,
    this.photoPaths,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['friend_id'] = Variable<String>(friendId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || momentCustomType != null) {
      map['custom_type'] = Variable<String>(momentCustomType);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || photoPaths != null) {
      map['photo_paths'] = Variable<String>(photoPaths);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MomentsTableCompanion toCompanion(bool nullToAbsent) {
    return MomentsTableCompanion(
      id: Value(id),
      friendId: Value(friendId),
      type: Value(type),
      momentCustomType:
          momentCustomType == null && nullToAbsent
              ? const Value.absent()
              : Value(momentCustomType),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      photoPaths:
          photoPaths == null && nullToAbsent
              ? const Value.absent()
              : Value(photoPaths),
      createdAt: Value(createdAt),
    );
  }

  factory MomentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MomentsTableData(
      id: serializer.fromJson<String>(json['id']),
      friendId: serializer.fromJson<String>(json['friendId']),
      type: serializer.fromJson<String>(json['type']),
      momentCustomType: serializer.fromJson<String?>(json['momentCustomType']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      photoPaths: serializer.fromJson<String?>(json['photoPaths']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'friendId': serializer.toJson<String>(friendId),
      'type': serializer.toJson<String>(type),
      'momentCustomType': serializer.toJson<String?>(momentCustomType),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String?>(note),
      'photoPaths': serializer.toJson<String?>(photoPaths),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MomentsTableData copyWith({
    String? id,
    String? friendId,
    String? type,
    Value<String?> momentCustomType = const Value.absent(),
    DateTime? date,
    Value<String?> note = const Value.absent(),
    Value<String?> photoPaths = const Value.absent(),
    DateTime? createdAt,
  }) => MomentsTableData(
    id: id ?? this.id,
    friendId: friendId ?? this.friendId,
    type: type ?? this.type,
    momentCustomType:
        momentCustomType.present
            ? momentCustomType.value
            : this.momentCustomType,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    photoPaths: photoPaths.present ? photoPaths.value : this.photoPaths,
    createdAt: createdAt ?? this.createdAt,
  );
  MomentsTableData copyWithCompanion(MomentsTableCompanion data) {
    return MomentsTableData(
      id: data.id.present ? data.id.value : this.id,
      friendId: data.friendId.present ? data.friendId.value : this.friendId,
      type: data.type.present ? data.type.value : this.type,
      momentCustomType:
          data.momentCustomType.present
              ? data.momentCustomType.value
              : this.momentCustomType,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      photoPaths:
          data.photoPaths.present ? data.photoPaths.value : this.photoPaths,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MomentsTableData(')
          ..write('id: $id, ')
          ..write('friendId: $friendId, ')
          ..write('type: $type, ')
          ..write('momentCustomType: $momentCustomType, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('photoPaths: $photoPaths, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    friendId,
    type,
    momentCustomType,
    date,
    note,
    photoPaths,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MomentsTableData &&
          other.id == this.id &&
          other.friendId == this.friendId &&
          other.type == this.type &&
          other.momentCustomType == this.momentCustomType &&
          other.date == this.date &&
          other.note == this.note &&
          other.photoPaths == this.photoPaths &&
          other.createdAt == this.createdAt);
}

class MomentsTableCompanion extends UpdateCompanion<MomentsTableData> {
  final Value<String> id;
  final Value<String> friendId;
  final Value<String> type;
  final Value<String?> momentCustomType;
  final Value<DateTime> date;
  final Value<String?> note;
  final Value<String?> photoPaths;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MomentsTableCompanion({
    this.id = const Value.absent(),
    this.friendId = const Value.absent(),
    this.type = const Value.absent(),
    this.momentCustomType = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.photoPaths = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MomentsTableCompanion.insert({
    required String id,
    required String friendId,
    required String type,
    this.momentCustomType = const Value.absent(),
    required DateTime date,
    this.note = const Value.absent(),
    this.photoPaths = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       friendId = Value(friendId),
       type = Value(type),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<MomentsTableData> custom({
    Expression<String>? id,
    Expression<String>? friendId,
    Expression<String>? type,
    Expression<String>? momentCustomType,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<String>? photoPaths,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (friendId != null) 'friend_id': friendId,
      if (type != null) 'type': type,
      if (momentCustomType != null) 'custom_type': momentCustomType,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (photoPaths != null) 'photo_paths': photoPaths,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MomentsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? friendId,
    Value<String>? type,
    Value<String?>? momentCustomType,
    Value<DateTime>? date,
    Value<String?>? note,
    Value<String?>? photoPaths,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MomentsTableCompanion(
      id: id ?? this.id,
      friendId: friendId ?? this.friendId,
      type: type ?? this.type,
      momentCustomType: momentCustomType ?? this.momentCustomType,
      date: date ?? this.date,
      note: note ?? this.note,
      photoPaths: photoPaths ?? this.photoPaths,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (friendId.present) {
      map['friend_id'] = Variable<String>(friendId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (momentCustomType.present) {
      map['custom_type'] = Variable<String>(momentCustomType.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (photoPaths.present) {
      map['photo_paths'] = Variable<String>(photoPaths.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MomentsTableCompanion(')
          ..write('id: $id, ')
          ..write('friendId: $friendId, ')
          ..write('type: $type, ')
          ..write('momentCustomType: $momentCustomType, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('photoPaths: $photoPaths, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FriendsTableTable friendsTable = $FriendsTableTable(this);
  late final $MomentsTableTable momentsTable = $MomentsTableTable(this);
  late final FriendsDao friendsDao = FriendsDao(this as AppDatabase);
  late final MomentsDao momentsDao = MomentsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    friendsTable,
    momentsTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'friends_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('moments_table', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$FriendsTableTableCreateCompanionBuilder =
    FriendsTableCompanion Function({
      required String id,
      required String name,
      Value<String?> avatarPath,
      Value<String?> avatarUrl,
      Value<int?> planetIndex,
      Value<DateTime?> birthday,
      required String orbitTier,
      required int frequencyDays,
      Value<DateTime?> lastConnectedAt,
      required DateTime createdAt,
      Value<String?> userId,
      Value<bool> remindBirthday,
      Value<String?> notes,
      Value<String?> topics,
      Value<int> rowid,
    });
typedef $$FriendsTableTableUpdateCompanionBuilder =
    FriendsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> avatarPath,
      Value<String?> avatarUrl,
      Value<int?> planetIndex,
      Value<DateTime?> birthday,
      Value<String> orbitTier,
      Value<int> frequencyDays,
      Value<DateTime?> lastConnectedAt,
      Value<DateTime> createdAt,
      Value<String?> userId,
      Value<bool> remindBirthday,
      Value<String?> notes,
      Value<String?> topics,
      Value<int> rowid,
    });

final class $$FriendsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $FriendsTableTable, FriendsTableData> {
  $$FriendsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MomentsTableTable, List<MomentsTableData>>
  _momentsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.momentsTable,
    aliasName: $_aliasNameGenerator(
      db.friendsTable.id,
      db.momentsTable.friendId,
    ),
  );

  $$MomentsTableTableProcessedTableManager get momentsTableRefs {
    final manager = $$MomentsTableTableTableManager(
      $_db,
      $_db.momentsTable,
    ).filter((f) => f.friendId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_momentsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FriendsTableTableFilterComposer
    extends Composer<_$AppDatabase, $FriendsTableTable> {
  $$FriendsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get planetIndex => $composableBuilder(
    column: $table.planetIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthday => $composableBuilder(
    column: $table.birthday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orbitTier => $composableBuilder(
    column: $table.orbitTier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frequencyDays => $composableBuilder(
    column: $table.frequencyDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remindBirthday => $composableBuilder(
    column: $table.remindBirthday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topics => $composableBuilder(
    column: $table.topics,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> momentsTableRefs(
    Expression<bool> Function($$MomentsTableTableFilterComposer f) f,
  ) {
    final $$MomentsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.momentsTable,
      getReferencedColumn: (t) => t.friendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MomentsTableTableFilterComposer(
            $db: $db,
            $table: $db.momentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FriendsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FriendsTableTable> {
  $$FriendsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get planetIndex => $composableBuilder(
    column: $table.planetIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthday => $composableBuilder(
    column: $table.birthday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orbitTier => $composableBuilder(
    column: $table.orbitTier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frequencyDays => $composableBuilder(
    column: $table.frequencyDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindBirthday => $composableBuilder(
    column: $table.remindBirthday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topics => $composableBuilder(
    column: $table.topics,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FriendsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FriendsTableTable> {
  $$FriendsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<int> get planetIndex => $composableBuilder(
    column: $table.planetIndex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get birthday =>
      $composableBuilder(column: $table.birthday, builder: (column) => column);

  GeneratedColumn<String> get orbitTier =>
      $composableBuilder(column: $table.orbitTier, builder: (column) => column);

  GeneratedColumn<int> get frequencyDays => $composableBuilder(
    column: $table.frequencyDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get remindBirthday => $composableBuilder(
    column: $table.remindBirthday,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get topics =>
      $composableBuilder(column: $table.topics, builder: (column) => column);

  Expression<T> momentsTableRefs<T extends Object>(
    Expression<T> Function($$MomentsTableTableAnnotationComposer a) f,
  ) {
    final $$MomentsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.momentsTable,
      getReferencedColumn: (t) => t.friendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MomentsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.momentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FriendsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FriendsTableTable,
          FriendsTableData,
          $$FriendsTableTableFilterComposer,
          $$FriendsTableTableOrderingComposer,
          $$FriendsTableTableAnnotationComposer,
          $$FriendsTableTableCreateCompanionBuilder,
          $$FriendsTableTableUpdateCompanionBuilder,
          (FriendsTableData, $$FriendsTableTableReferences),
          FriendsTableData,
          PrefetchHooks Function({bool momentsTableRefs})
        > {
  $$FriendsTableTableTableManager(_$AppDatabase db, $FriendsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$FriendsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$FriendsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$FriendsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<int?> planetIndex = const Value.absent(),
                Value<DateTime?> birthday = const Value.absent(),
                Value<String> orbitTier = const Value.absent(),
                Value<int> frequencyDays = const Value.absent(),
                Value<DateTime?> lastConnectedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<bool> remindBirthday = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> topics = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FriendsTableCompanion(
                id: id,
                name: name,
                avatarPath: avatarPath,
                avatarUrl: avatarUrl,
                planetIndex: planetIndex,
                birthday: birthday,
                orbitTier: orbitTier,
                frequencyDays: frequencyDays,
                lastConnectedAt: lastConnectedAt,
                createdAt: createdAt,
                userId: userId,
                remindBirthday: remindBirthday,
                notes: notes,
                topics: topics,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<int?> planetIndex = const Value.absent(),
                Value<DateTime?> birthday = const Value.absent(),
                required String orbitTier,
                required int frequencyDays,
                Value<DateTime?> lastConnectedAt = const Value.absent(),
                required DateTime createdAt,
                Value<String?> userId = const Value.absent(),
                Value<bool> remindBirthday = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> topics = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FriendsTableCompanion.insert(
                id: id,
                name: name,
                avatarPath: avatarPath,
                avatarUrl: avatarUrl,
                planetIndex: planetIndex,
                birthday: birthday,
                orbitTier: orbitTier,
                frequencyDays: frequencyDays,
                lastConnectedAt: lastConnectedAt,
                createdAt: createdAt,
                userId: userId,
                remindBirthday: remindBirthday,
                notes: notes,
                topics: topics,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$FriendsTableTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({momentsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (momentsTableRefs) db.momentsTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (momentsTableRefs)
                    await $_getPrefetchedData<
                      FriendsTableData,
                      $FriendsTableTable,
                      MomentsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$FriendsTableTableReferences
                          ._momentsTableRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$FriendsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).momentsTableRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.friendId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FriendsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FriendsTableTable,
      FriendsTableData,
      $$FriendsTableTableFilterComposer,
      $$FriendsTableTableOrderingComposer,
      $$FriendsTableTableAnnotationComposer,
      $$FriendsTableTableCreateCompanionBuilder,
      $$FriendsTableTableUpdateCompanionBuilder,
      (FriendsTableData, $$FriendsTableTableReferences),
      FriendsTableData,
      PrefetchHooks Function({bool momentsTableRefs})
    >;
typedef $$MomentsTableTableCreateCompanionBuilder =
    MomentsTableCompanion Function({
      required String id,
      required String friendId,
      required String type,
      Value<String?> momentCustomType,
      required DateTime date,
      Value<String?> note,
      Value<String?> photoPaths,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MomentsTableTableUpdateCompanionBuilder =
    MomentsTableCompanion Function({
      Value<String> id,
      Value<String> friendId,
      Value<String> type,
      Value<String?> momentCustomType,
      Value<DateTime> date,
      Value<String?> note,
      Value<String?> photoPaths,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MomentsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $MomentsTableTable, MomentsTableData> {
  $$MomentsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FriendsTableTable _friendIdTable(_$AppDatabase db) =>
      db.friendsTable.createAlias(
        $_aliasNameGenerator(db.momentsTable.friendId, db.friendsTable.id),
      );

  $$FriendsTableTableProcessedTableManager get friendId {
    final $_column = $_itemColumn<String>('friend_id')!;

    final manager = $$FriendsTableTableTableManager(
      $_db,
      $_db.friendsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_friendIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MomentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $MomentsTableTable> {
  $$MomentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get momentCustomType => $composableBuilder(
    column: $table.momentCustomType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPaths => $composableBuilder(
    column: $table.photoPaths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FriendsTableTableFilterComposer get friendId {
    final $$FriendsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friendsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableTableFilterComposer(
            $db: $db,
            $table: $db.friendsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MomentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MomentsTableTable> {
  $$MomentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get momentCustomType => $composableBuilder(
    column: $table.momentCustomType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPaths => $composableBuilder(
    column: $table.photoPaths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FriendsTableTableOrderingComposer get friendId {
    final $$FriendsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friendsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableTableOrderingComposer(
            $db: $db,
            $table: $db.friendsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MomentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MomentsTableTable> {
  $$MomentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get momentCustomType => $composableBuilder(
    column: $table.momentCustomType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get photoPaths => $composableBuilder(
    column: $table.photoPaths,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FriendsTableTableAnnotationComposer get friendId {
    final $$FriendsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friendsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.friendsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MomentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MomentsTableTable,
          MomentsTableData,
          $$MomentsTableTableFilterComposer,
          $$MomentsTableTableOrderingComposer,
          $$MomentsTableTableAnnotationComposer,
          $$MomentsTableTableCreateCompanionBuilder,
          $$MomentsTableTableUpdateCompanionBuilder,
          (MomentsTableData, $$MomentsTableTableReferences),
          MomentsTableData,
          PrefetchHooks Function({bool friendId})
        > {
  $$MomentsTableTableTableManager(_$AppDatabase db, $MomentsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MomentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MomentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$MomentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> friendId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> momentCustomType = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> photoPaths = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MomentsTableCompanion(
                id: id,
                friendId: friendId,
                type: type,
                momentCustomType: momentCustomType,
                date: date,
                note: note,
                photoPaths: photoPaths,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String friendId,
                required String type,
                Value<String?> momentCustomType = const Value.absent(),
                required DateTime date,
                Value<String?> note = const Value.absent(),
                Value<String?> photoPaths = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MomentsTableCompanion.insert(
                id: id,
                friendId: friendId,
                type: type,
                momentCustomType: momentCustomType,
                date: date,
                note: note,
                photoPaths: photoPaths,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$MomentsTableTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({friendId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (friendId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.friendId,
                            referencedTable: $$MomentsTableTableReferences
                                ._friendIdTable(db),
                            referencedColumn:
                                $$MomentsTableTableReferences
                                    ._friendIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MomentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MomentsTableTable,
      MomentsTableData,
      $$MomentsTableTableFilterComposer,
      $$MomentsTableTableOrderingComposer,
      $$MomentsTableTableAnnotationComposer,
      $$MomentsTableTableCreateCompanionBuilder,
      $$MomentsTableTableUpdateCompanionBuilder,
      (MomentsTableData, $$MomentsTableTableReferences),
      MomentsTableData,
      PrefetchHooks Function({bool friendId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FriendsTableTableTableManager get friendsTable =>
      $$FriendsTableTableTableManager(_db, _db.friendsTable);
  $$MomentsTableTableTableManager get momentsTable =>
      $$MomentsTableTableTableManager(_db, _db.momentsTable);
}
