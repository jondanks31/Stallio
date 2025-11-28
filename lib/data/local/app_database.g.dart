// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $YardsTable extends Yards with TableInfo<$YardsTable, Yard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $YardsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inviteCodeMeta = const VerificationMeta(
    'inviteCode',
  );
  @override
  late final GeneratedColumn<String> inviteCode = GeneratedColumn<String>(
    'invite_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inviteCodeExpiresAtMeta =
      const VerificationMeta('inviteCodeExpiresAt');
  @override
  late final GeneratedColumn<DateTime> inviteCodeExpiresAt =
      GeneratedColumn<DateTime>(
        'invite_code_expires_at',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    address,
    createdBy,
    inviteCode,
    inviteCodeExpiresAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'yards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Yard> instance, {
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
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('invite_code')) {
      context.handle(
        _inviteCodeMeta,
        inviteCode.isAcceptableOrUnknown(data['invite_code']!, _inviteCodeMeta),
      );
    }
    if (data.containsKey('invite_code_expires_at')) {
      context.handle(
        _inviteCodeExpiresAtMeta,
        inviteCodeExpiresAt.isAcceptableOrUnknown(
          data['invite_code_expires_at']!,
          _inviteCodeExpiresAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Yard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Yard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      inviteCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invite_code'],
      ),
      inviteCodeExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}invite_code_expires_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $YardsTable createAlias(String alias) {
    return $YardsTable(attachedDatabase, alias);
  }
}

class Yard extends DataClass implements Insertable<Yard> {
  final String id;
  final String name;
  final String? address;
  final String createdBy;
  final String? inviteCode;
  final DateTime? inviteCodeExpiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Yard({
    required this.id,
    required this.name,
    this.address,
    required this.createdBy,
    this.inviteCode,
    this.inviteCodeExpiresAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['created_by'] = Variable<String>(createdBy);
    if (!nullToAbsent || inviteCode != null) {
      map['invite_code'] = Variable<String>(inviteCode);
    }
    if (!nullToAbsent || inviteCodeExpiresAt != null) {
      map['invite_code_expires_at'] = Variable<DateTime>(inviteCodeExpiresAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  YardsCompanion toCompanion(bool nullToAbsent) {
    return YardsCompanion(
      id: Value(id),
      name: Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      createdBy: Value(createdBy),
      inviteCode: inviteCode == null && nullToAbsent
          ? const Value.absent()
          : Value(inviteCode),
      inviteCodeExpiresAt: inviteCodeExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(inviteCodeExpiresAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Yard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Yard(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      inviteCode: serializer.fromJson<String?>(json['inviteCode']),
      inviteCodeExpiresAt: serializer.fromJson<DateTime?>(
        json['inviteCodeExpiresAt'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String?>(address),
      'createdBy': serializer.toJson<String>(createdBy),
      'inviteCode': serializer.toJson<String?>(inviteCode),
      'inviteCodeExpiresAt': serializer.toJson<DateTime?>(inviteCodeExpiresAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Yard copyWith({
    String? id,
    String? name,
    Value<String?> address = const Value.absent(),
    String? createdBy,
    Value<String?> inviteCode = const Value.absent(),
    Value<DateTime?> inviteCodeExpiresAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Yard(
    id: id ?? this.id,
    name: name ?? this.name,
    address: address.present ? address.value : this.address,
    createdBy: createdBy ?? this.createdBy,
    inviteCode: inviteCode.present ? inviteCode.value : this.inviteCode,
    inviteCodeExpiresAt: inviteCodeExpiresAt.present
        ? inviteCodeExpiresAt.value
        : this.inviteCodeExpiresAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Yard copyWithCompanion(YardsCompanion data) {
    return Yard(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      inviteCode: data.inviteCode.present
          ? data.inviteCode.value
          : this.inviteCode,
      inviteCodeExpiresAt: data.inviteCodeExpiresAt.present
          ? data.inviteCodeExpiresAt.value
          : this.inviteCodeExpiresAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Yard(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('createdBy: $createdBy, ')
          ..write('inviteCode: $inviteCode, ')
          ..write('inviteCodeExpiresAt: $inviteCodeExpiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    address,
    createdBy,
    inviteCode,
    inviteCodeExpiresAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Yard &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.createdBy == this.createdBy &&
          other.inviteCode == this.inviteCode &&
          other.inviteCodeExpiresAt == this.inviteCodeExpiresAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class YardsCompanion extends UpdateCompanion<Yard> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> address;
  final Value<String> createdBy;
  final Value<String?> inviteCode;
  final Value<DateTime?> inviteCodeExpiresAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const YardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.inviteCode = const Value.absent(),
    this.inviteCodeExpiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  YardsCompanion.insert({
    required String id,
    required String name,
    this.address = const Value.absent(),
    required String createdBy,
    this.inviteCode = const Value.absent(),
    this.inviteCodeExpiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdBy = Value(createdBy);
  static Insertable<Yard> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? createdBy,
    Expression<String>? inviteCode,
    Expression<DateTime>? inviteCodeExpiresAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (createdBy != null) 'created_by': createdBy,
      if (inviteCode != null) 'invite_code': inviteCode,
      if (inviteCodeExpiresAt != null)
        'invite_code_expires_at': inviteCodeExpiresAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  YardsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? address,
    Value<String>? createdBy,
    Value<String?>? inviteCode,
    Value<DateTime?>? inviteCodeExpiresAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return YardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      createdBy: createdBy ?? this.createdBy,
      inviteCode: inviteCode ?? this.inviteCode,
      inviteCodeExpiresAt: inviteCodeExpiresAt ?? this.inviteCodeExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (inviteCode.present) {
      map['invite_code'] = Variable<String>(inviteCode.value);
    }
    if (inviteCodeExpiresAt.present) {
      map['invite_code_expires_at'] = Variable<DateTime>(
        inviteCodeExpiresAt.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('YardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('createdBy: $createdBy, ')
          ..write('inviteCode: $inviteCode, ')
          ..write('inviteCodeExpiresAt: $inviteCodeExpiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yardIdMeta = const VerificationMeta('yardId');
  @override
  late final GeneratedColumn<String> yardId = GeneratedColumn<String>(
    'yard_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    yardId,
    role,
    fullName,
    onboardingCompleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('yard_id')) {
      context.handle(
        _yardIdMeta,
        yardId.isAcceptableOrUnknown(data['yard_id']!, _yardIdMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      yardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}yard_id'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      ),
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final String userId;
  final String? yardId;
  final String role;
  final String? fullName;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Profile({
    required this.userId,
    this.yardId,
    required this.role,
    this.fullName,
    required this.onboardingCompleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || yardId != null) {
      map['yard_id'] = Variable<String>(yardId);
    }
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      userId: Value(userId),
      yardId: yardId == null && nullToAbsent
          ? const Value.absent()
          : Value(yardId),
      role: Value(role),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      onboardingCompleted: Value(onboardingCompleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      userId: serializer.fromJson<String>(json['userId']),
      yardId: serializer.fromJson<String?>(json['yardId']),
      role: serializer.fromJson<String>(json['role']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'yardId': serializer.toJson<String?>(yardId),
      'role': serializer.toJson<String>(role),
      'fullName': serializer.toJson<String?>(fullName),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Profile copyWith({
    String? userId,
    Value<String?> yardId = const Value.absent(),
    String? role,
    Value<String?> fullName = const Value.absent(),
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Profile(
    userId: userId ?? this.userId,
    yardId: yardId.present ? yardId.value : this.yardId,
    role: role ?? this.role,
    fullName: fullName.present ? fullName.value : this.fullName,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      userId: data.userId.present ? data.userId.value : this.userId,
      yardId: data.yardId.present ? data.yardId.value : this.yardId,
      role: data.role.present ? data.role.value : this.role,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('userId: $userId, ')
          ..write('yardId: $yardId, ')
          ..write('role: $role, ')
          ..write('fullName: $fullName, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    yardId,
    role,
    fullName,
    onboardingCompleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.userId == this.userId &&
          other.yardId == this.yardId &&
          other.role == this.role &&
          other.fullName == this.fullName &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> userId;
  final Value<String?> yardId;
  final Value<String> role;
  final Value<String?> fullName;
  final Value<bool> onboardingCompleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.userId = const Value.absent(),
    this.yardId = const Value.absent(),
    this.role = const Value.absent(),
    this.fullName = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String userId,
    this.yardId = const Value.absent(),
    required String role,
    this.fullName = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       role = Value(role);
  static Insertable<Profile> custom({
    Expression<String>? userId,
    Expression<String>? yardId,
    Expression<String>? role,
    Expression<String>? fullName,
    Expression<bool>? onboardingCompleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (yardId != null) 'yard_id': yardId,
      if (role != null) 'role': role,
      if (fullName != null) 'full_name': fullName,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? userId,
    Value<String?>? yardId,
    Value<String>? role,
    Value<String?>? fullName,
    Value<bool>? onboardingCompleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      userId: userId ?? this.userId,
      yardId: yardId ?? this.yardId,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (yardId.present) {
      map['yard_id'] = Variable<String>(yardId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('yardId: $yardId, ')
          ..write('role: $role, ')
          ..write('fullName: $fullName, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConsumableTypesTable extends ConsumableTypes
    with TableInfo<$ConsumableTypesTable, ConsumableType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConsumableTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yardIdMeta = const VerificationMeta('yardId');
  @override
  late final GeneratedColumn<String> yardId = GeneratedColumn<String>(
    'yard_id',
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
  static const VerificationMeta _stockUnitMeta = const VerificationMeta(
    'stockUnit',
  );
  @override
  late final GeneratedColumn<String> stockUnit = GeneratedColumn<String>(
    'stock_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usageUnitMeta = const VerificationMeta(
    'usageUnit',
  );
  @override
  late final GeneratedColumn<String> usageUnit = GeneratedColumn<String>(
    'usage_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratioMeta = const VerificationMeta('ratio');
  @override
  late final GeneratedColumn<int> ratio = GeneratedColumn<int>(
    'ratio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerUsageUnitMeta = const VerificationMeta(
    'pricePerUsageUnit',
  );
  @override
  late final GeneratedColumn<double> pricePerUsageUnit =
      GeneratedColumn<double>(
        'price_per_usage_unit',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    yardId,
    name,
    stockUnit,
    usageUnit,
    ratio,
    pricePerUsageUnit,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'consumable_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConsumableType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('yard_id')) {
      context.handle(
        _yardIdMeta,
        yardId.isAcceptableOrUnknown(data['yard_id']!, _yardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_yardIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('stock_unit')) {
      context.handle(
        _stockUnitMeta,
        stockUnit.isAcceptableOrUnknown(data['stock_unit']!, _stockUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_stockUnitMeta);
    }
    if (data.containsKey('usage_unit')) {
      context.handle(
        _usageUnitMeta,
        usageUnit.isAcceptableOrUnknown(data['usage_unit']!, _usageUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_usageUnitMeta);
    }
    if (data.containsKey('ratio')) {
      context.handle(
        _ratioMeta,
        ratio.isAcceptableOrUnknown(data['ratio']!, _ratioMeta),
      );
    } else if (isInserting) {
      context.missing(_ratioMeta);
    }
    if (data.containsKey('price_per_usage_unit')) {
      context.handle(
        _pricePerUsageUnitMeta,
        pricePerUsageUnit.isAcceptableOrUnknown(
          data['price_per_usage_unit']!,
          _pricePerUsageUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerUsageUnitMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConsumableType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConsumableType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      yardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}yard_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      stockUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_unit'],
      )!,
      usageUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usage_unit'],
      )!,
      ratio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ratio'],
      )!,
      pricePerUsageUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_per_usage_unit'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ConsumableTypesTable createAlias(String alias) {
    return $ConsumableTypesTable(attachedDatabase, alias);
  }
}

class ConsumableType extends DataClass implements Insertable<ConsumableType> {
  final String id;
  final String yardId;
  final String name;
  final String stockUnit;
  final String usageUnit;
  final int ratio;
  final double pricePerUsageUnit;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ConsumableType({
    required this.id,
    required this.yardId,
    required this.name,
    required this.stockUnit,
    required this.usageUnit,
    required this.ratio,
    required this.pricePerUsageUnit,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['yard_id'] = Variable<String>(yardId);
    map['name'] = Variable<String>(name);
    map['stock_unit'] = Variable<String>(stockUnit);
    map['usage_unit'] = Variable<String>(usageUnit);
    map['ratio'] = Variable<int>(ratio);
    map['price_per_usage_unit'] = Variable<double>(pricePerUsageUnit);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ConsumableTypesCompanion toCompanion(bool nullToAbsent) {
    return ConsumableTypesCompanion(
      id: Value(id),
      yardId: Value(yardId),
      name: Value(name),
      stockUnit: Value(stockUnit),
      usageUnit: Value(usageUnit),
      ratio: Value(ratio),
      pricePerUsageUnit: Value(pricePerUsageUnit),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ConsumableType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConsumableType(
      id: serializer.fromJson<String>(json['id']),
      yardId: serializer.fromJson<String>(json['yardId']),
      name: serializer.fromJson<String>(json['name']),
      stockUnit: serializer.fromJson<String>(json['stockUnit']),
      usageUnit: serializer.fromJson<String>(json['usageUnit']),
      ratio: serializer.fromJson<int>(json['ratio']),
      pricePerUsageUnit: serializer.fromJson<double>(json['pricePerUsageUnit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'yardId': serializer.toJson<String>(yardId),
      'name': serializer.toJson<String>(name),
      'stockUnit': serializer.toJson<String>(stockUnit),
      'usageUnit': serializer.toJson<String>(usageUnit),
      'ratio': serializer.toJson<int>(ratio),
      'pricePerUsageUnit': serializer.toJson<double>(pricePerUsageUnit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ConsumableType copyWith({
    String? id,
    String? yardId,
    String? name,
    String? stockUnit,
    String? usageUnit,
    int? ratio,
    double? pricePerUsageUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ConsumableType(
    id: id ?? this.id,
    yardId: yardId ?? this.yardId,
    name: name ?? this.name,
    stockUnit: stockUnit ?? this.stockUnit,
    usageUnit: usageUnit ?? this.usageUnit,
    ratio: ratio ?? this.ratio,
    pricePerUsageUnit: pricePerUsageUnit ?? this.pricePerUsageUnit,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ConsumableType copyWithCompanion(ConsumableTypesCompanion data) {
    return ConsumableType(
      id: data.id.present ? data.id.value : this.id,
      yardId: data.yardId.present ? data.yardId.value : this.yardId,
      name: data.name.present ? data.name.value : this.name,
      stockUnit: data.stockUnit.present ? data.stockUnit.value : this.stockUnit,
      usageUnit: data.usageUnit.present ? data.usageUnit.value : this.usageUnit,
      ratio: data.ratio.present ? data.ratio.value : this.ratio,
      pricePerUsageUnit: data.pricePerUsageUnit.present
          ? data.pricePerUsageUnit.value
          : this.pricePerUsageUnit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConsumableType(')
          ..write('id: $id, ')
          ..write('yardId: $yardId, ')
          ..write('name: $name, ')
          ..write('stockUnit: $stockUnit, ')
          ..write('usageUnit: $usageUnit, ')
          ..write('ratio: $ratio, ')
          ..write('pricePerUsageUnit: $pricePerUsageUnit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    yardId,
    name,
    stockUnit,
    usageUnit,
    ratio,
    pricePerUsageUnit,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConsumableType &&
          other.id == this.id &&
          other.yardId == this.yardId &&
          other.name == this.name &&
          other.stockUnit == this.stockUnit &&
          other.usageUnit == this.usageUnit &&
          other.ratio == this.ratio &&
          other.pricePerUsageUnit == this.pricePerUsageUnit &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ConsumableTypesCompanion extends UpdateCompanion<ConsumableType> {
  final Value<String> id;
  final Value<String> yardId;
  final Value<String> name;
  final Value<String> stockUnit;
  final Value<String> usageUnit;
  final Value<int> ratio;
  final Value<double> pricePerUsageUnit;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ConsumableTypesCompanion({
    this.id = const Value.absent(),
    this.yardId = const Value.absent(),
    this.name = const Value.absent(),
    this.stockUnit = const Value.absent(),
    this.usageUnit = const Value.absent(),
    this.ratio = const Value.absent(),
    this.pricePerUsageUnit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConsumableTypesCompanion.insert({
    required String id,
    required String yardId,
    required String name,
    required String stockUnit,
    required String usageUnit,
    required int ratio,
    required double pricePerUsageUnit,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       yardId = Value(yardId),
       name = Value(name),
       stockUnit = Value(stockUnit),
       usageUnit = Value(usageUnit),
       ratio = Value(ratio),
       pricePerUsageUnit = Value(pricePerUsageUnit);
  static Insertable<ConsumableType> custom({
    Expression<String>? id,
    Expression<String>? yardId,
    Expression<String>? name,
    Expression<String>? stockUnit,
    Expression<String>? usageUnit,
    Expression<int>? ratio,
    Expression<double>? pricePerUsageUnit,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (yardId != null) 'yard_id': yardId,
      if (name != null) 'name': name,
      if (stockUnit != null) 'stock_unit': stockUnit,
      if (usageUnit != null) 'usage_unit': usageUnit,
      if (ratio != null) 'ratio': ratio,
      if (pricePerUsageUnit != null) 'price_per_usage_unit': pricePerUsageUnit,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConsumableTypesCompanion copyWith({
    Value<String>? id,
    Value<String>? yardId,
    Value<String>? name,
    Value<String>? stockUnit,
    Value<String>? usageUnit,
    Value<int>? ratio,
    Value<double>? pricePerUsageUnit,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ConsumableTypesCompanion(
      id: id ?? this.id,
      yardId: yardId ?? this.yardId,
      name: name ?? this.name,
      stockUnit: stockUnit ?? this.stockUnit,
      usageUnit: usageUnit ?? this.usageUnit,
      ratio: ratio ?? this.ratio,
      pricePerUsageUnit: pricePerUsageUnit ?? this.pricePerUsageUnit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (yardId.present) {
      map['yard_id'] = Variable<String>(yardId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (stockUnit.present) {
      map['stock_unit'] = Variable<String>(stockUnit.value);
    }
    if (usageUnit.present) {
      map['usage_unit'] = Variable<String>(usageUnit.value);
    }
    if (ratio.present) {
      map['ratio'] = Variable<int>(ratio.value);
    }
    if (pricePerUsageUnit.present) {
      map['price_per_usage_unit'] = Variable<double>(pricePerUsageUnit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConsumableTypesCompanion(')
          ..write('id: $id, ')
          ..write('yardId: $yardId, ')
          ..write('name: $name, ')
          ..write('stockUnit: $stockUnit, ')
          ..write('usageUnit: $usageUnit, ')
          ..write('ratio: $ratio, ')
          ..write('pricePerUsageUnit: $pricePerUsageUnit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LiveryPackagesTable extends LiveryPackages
    with TableInfo<$LiveryPackagesTable, LiveryPackage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LiveryPackagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yardIdMeta = const VerificationMeta('yardId');
  @override
  late final GeneratedColumn<String> yardId = GeneratedColumn<String>(
    'yard_id',
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
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _basePriceMeta = const VerificationMeta(
    'basePrice',
  );
  @override
  late final GeneratedColumn<double> basePrice = GeneratedColumn<double>(
    'base_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _includedItemsJsonMeta = const VerificationMeta(
    'includedItemsJson',
  );
  @override
  late final GeneratedColumn<String> includedItemsJson =
      GeneratedColumn<String>(
        'included_items_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    yardId,
    name,
    version,
    basePrice,
    includedItemsJson,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'livery_packages';
  @override
  VerificationContext validateIntegrity(
    Insertable<LiveryPackage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('yard_id')) {
      context.handle(
        _yardIdMeta,
        yardId.isAcceptableOrUnknown(data['yard_id']!, _yardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_yardIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('base_price')) {
      context.handle(
        _basePriceMeta,
        basePrice.isAcceptableOrUnknown(data['base_price']!, _basePriceMeta),
      );
    } else if (isInserting) {
      context.missing(_basePriceMeta);
    }
    if (data.containsKey('included_items_json')) {
      context.handle(
        _includedItemsJsonMeta,
        includedItemsJson.isAcceptableOrUnknown(
          data['included_items_json']!,
          _includedItemsJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LiveryPackage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LiveryPackage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      yardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}yard_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      basePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}base_price'],
      )!,
      includedItemsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}included_items_json'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LiveryPackagesTable createAlias(String alias) {
    return $LiveryPackagesTable(attachedDatabase, alias);
  }
}

class LiveryPackage extends DataClass implements Insertable<LiveryPackage> {
  final String id;
  final String yardId;
  final String name;
  final int version;
  final double basePrice;
  final String includedItemsJson;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LiveryPackage({
    required this.id,
    required this.yardId,
    required this.name,
    required this.version,
    required this.basePrice,
    required this.includedItemsJson,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['yard_id'] = Variable<String>(yardId);
    map['name'] = Variable<String>(name);
    map['version'] = Variable<int>(version);
    map['base_price'] = Variable<double>(basePrice);
    map['included_items_json'] = Variable<String>(includedItemsJson);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LiveryPackagesCompanion toCompanion(bool nullToAbsent) {
    return LiveryPackagesCompanion(
      id: Value(id),
      yardId: Value(yardId),
      name: Value(name),
      version: Value(version),
      basePrice: Value(basePrice),
      includedItemsJson: Value(includedItemsJson),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LiveryPackage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LiveryPackage(
      id: serializer.fromJson<String>(json['id']),
      yardId: serializer.fromJson<String>(json['yardId']),
      name: serializer.fromJson<String>(json['name']),
      version: serializer.fromJson<int>(json['version']),
      basePrice: serializer.fromJson<double>(json['basePrice']),
      includedItemsJson: serializer.fromJson<String>(json['includedItemsJson']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'yardId': serializer.toJson<String>(yardId),
      'name': serializer.toJson<String>(name),
      'version': serializer.toJson<int>(version),
      'basePrice': serializer.toJson<double>(basePrice),
      'includedItemsJson': serializer.toJson<String>(includedItemsJson),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LiveryPackage copyWith({
    String? id,
    String? yardId,
    String? name,
    int? version,
    double? basePrice,
    String? includedItemsJson,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LiveryPackage(
    id: id ?? this.id,
    yardId: yardId ?? this.yardId,
    name: name ?? this.name,
    version: version ?? this.version,
    basePrice: basePrice ?? this.basePrice,
    includedItemsJson: includedItemsJson ?? this.includedItemsJson,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LiveryPackage copyWithCompanion(LiveryPackagesCompanion data) {
    return LiveryPackage(
      id: data.id.present ? data.id.value : this.id,
      yardId: data.yardId.present ? data.yardId.value : this.yardId,
      name: data.name.present ? data.name.value : this.name,
      version: data.version.present ? data.version.value : this.version,
      basePrice: data.basePrice.present ? data.basePrice.value : this.basePrice,
      includedItemsJson: data.includedItemsJson.present
          ? data.includedItemsJson.value
          : this.includedItemsJson,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LiveryPackage(')
          ..write('id: $id, ')
          ..write('yardId: $yardId, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('basePrice: $basePrice, ')
          ..write('includedItemsJson: $includedItemsJson, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    yardId,
    name,
    version,
    basePrice,
    includedItemsJson,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LiveryPackage &&
          other.id == this.id &&
          other.yardId == this.yardId &&
          other.name == this.name &&
          other.version == this.version &&
          other.basePrice == this.basePrice &&
          other.includedItemsJson == this.includedItemsJson &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LiveryPackagesCompanion extends UpdateCompanion<LiveryPackage> {
  final Value<String> id;
  final Value<String> yardId;
  final Value<String> name;
  final Value<int> version;
  final Value<double> basePrice;
  final Value<String> includedItemsJson;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LiveryPackagesCompanion({
    this.id = const Value.absent(),
    this.yardId = const Value.absent(),
    this.name = const Value.absent(),
    this.version = const Value.absent(),
    this.basePrice = const Value.absent(),
    this.includedItemsJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LiveryPackagesCompanion.insert({
    required String id,
    required String yardId,
    required String name,
    this.version = const Value.absent(),
    required double basePrice,
    this.includedItemsJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       yardId = Value(yardId),
       name = Value(name),
       basePrice = Value(basePrice);
  static Insertable<LiveryPackage> custom({
    Expression<String>? id,
    Expression<String>? yardId,
    Expression<String>? name,
    Expression<int>? version,
    Expression<double>? basePrice,
    Expression<String>? includedItemsJson,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (yardId != null) 'yard_id': yardId,
      if (name != null) 'name': name,
      if (version != null) 'version': version,
      if (basePrice != null) 'base_price': basePrice,
      if (includedItemsJson != null) 'included_items_json': includedItemsJson,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LiveryPackagesCompanion copyWith({
    Value<String>? id,
    Value<String>? yardId,
    Value<String>? name,
    Value<int>? version,
    Value<double>? basePrice,
    Value<String>? includedItemsJson,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LiveryPackagesCompanion(
      id: id ?? this.id,
      yardId: yardId ?? this.yardId,
      name: name ?? this.name,
      version: version ?? this.version,
      basePrice: basePrice ?? this.basePrice,
      includedItemsJson: includedItemsJson ?? this.includedItemsJson,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (yardId.present) {
      map['yard_id'] = Variable<String>(yardId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (basePrice.present) {
      map['base_price'] = Variable<double>(basePrice.value);
    }
    if (includedItemsJson.present) {
      map['included_items_json'] = Variable<String>(includedItemsJson.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LiveryPackagesCompanion(')
          ..write('id: $id, ')
          ..write('yardId: $yardId, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('basePrice: $basePrice, ')
          ..write('includedItemsJson: $includedItemsJson, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceSettingsTable extends InvoiceSettings
    with TableInfo<$InvoiceSettingsTable, InvoiceSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _yardIdMeta = const VerificationMeta('yardId');
  @override
  late final GeneratedColumn<String> yardId = GeneratedColumn<String>(
    'yard_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankDetailsMeta = const VerificationMeta(
    'bankDetails',
  );
  @override
  late final GeneratedColumn<String> bankDetails = GeneratedColumn<String>(
    'bank_details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentTermsMeta = const VerificationMeta(
    'paymentTerms',
  );
  @override
  late final GeneratedColumn<String> paymentTerms = GeneratedColumn<String>(
    'payment_terms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _billingDayMeta = const VerificationMeta(
    'billingDay',
  );
  @override
  late final GeneratedColumn<int> billingDay = GeneratedColumn<int>(
    'billing_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cutoffBufferMeta = const VerificationMeta(
    'cutoffBuffer',
  );
  @override
  late final GeneratedColumn<int> cutoffBuffer = GeneratedColumn<int>(
    'cutoff_buffer',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _primaryColorMeta = const VerificationMeta(
    'primaryColor',
  );
  @override
  late final GeneratedColumn<String> primaryColor = GeneratedColumn<String>(
    'primary_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondaryColorMeta = const VerificationMeta(
    'secondaryColor',
  );
  @override
  late final GeneratedColumn<String> secondaryColor = GeneratedColumn<String>(
    'secondary_color',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    yardId,
    logoUrl,
    bankDetails,
    paymentTerms,
    billingDay,
    cutoffBuffer,
    primaryColor,
    secondaryColor,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoiceSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('yard_id')) {
      context.handle(
        _yardIdMeta,
        yardId.isAcceptableOrUnknown(data['yard_id']!, _yardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_yardIdMeta);
    }
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    if (data.containsKey('bank_details')) {
      context.handle(
        _bankDetailsMeta,
        bankDetails.isAcceptableOrUnknown(
          data['bank_details']!,
          _bankDetailsMeta,
        ),
      );
    }
    if (data.containsKey('payment_terms')) {
      context.handle(
        _paymentTermsMeta,
        paymentTerms.isAcceptableOrUnknown(
          data['payment_terms']!,
          _paymentTermsMeta,
        ),
      );
    }
    if (data.containsKey('billing_day')) {
      context.handle(
        _billingDayMeta,
        billingDay.isAcceptableOrUnknown(data['billing_day']!, _billingDayMeta),
      );
    }
    if (data.containsKey('cutoff_buffer')) {
      context.handle(
        _cutoffBufferMeta,
        cutoffBuffer.isAcceptableOrUnknown(
          data['cutoff_buffer']!,
          _cutoffBufferMeta,
        ),
      );
    }
    if (data.containsKey('primary_color')) {
      context.handle(
        _primaryColorMeta,
        primaryColor.isAcceptableOrUnknown(
          data['primary_color']!,
          _primaryColorMeta,
        ),
      );
    }
    if (data.containsKey('secondary_color')) {
      context.handle(
        _secondaryColorMeta,
        secondaryColor.isAcceptableOrUnknown(
          data['secondary_color']!,
          _secondaryColorMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      yardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}yard_id'],
      )!,
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
      bankDetails: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_details'],
      ),
      paymentTerms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_terms'],
      ),
      billingDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}billing_day'],
      ),
      cutoffBuffer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cutoff_buffer'],
      )!,
      primaryColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_color'],
      ),
      secondaryColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secondary_color'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $InvoiceSettingsTable createAlias(String alias) {
    return $InvoiceSettingsTable(attachedDatabase, alias);
  }
}

class InvoiceSetting extends DataClass implements Insertable<InvoiceSetting> {
  final int id;
  final String yardId;
  final String? logoUrl;
  final String? bankDetails;
  final String? paymentTerms;
  final int? billingDay;
  final int cutoffBuffer;
  final String? primaryColor;
  final String? secondaryColor;
  final DateTime createdAt;
  final DateTime updatedAt;
  const InvoiceSetting({
    required this.id,
    required this.yardId,
    this.logoUrl,
    this.bankDetails,
    this.paymentTerms,
    this.billingDay,
    required this.cutoffBuffer,
    this.primaryColor,
    this.secondaryColor,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['yard_id'] = Variable<String>(yardId);
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    if (!nullToAbsent || bankDetails != null) {
      map['bank_details'] = Variable<String>(bankDetails);
    }
    if (!nullToAbsent || paymentTerms != null) {
      map['payment_terms'] = Variable<String>(paymentTerms);
    }
    if (!nullToAbsent || billingDay != null) {
      map['billing_day'] = Variable<int>(billingDay);
    }
    map['cutoff_buffer'] = Variable<int>(cutoffBuffer);
    if (!nullToAbsent || primaryColor != null) {
      map['primary_color'] = Variable<String>(primaryColor);
    }
    if (!nullToAbsent || secondaryColor != null) {
      map['secondary_color'] = Variable<String>(secondaryColor);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InvoiceSettingsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceSettingsCompanion(
      id: Value(id),
      yardId: Value(yardId),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      bankDetails: bankDetails == null && nullToAbsent
          ? const Value.absent()
          : Value(bankDetails),
      paymentTerms: paymentTerms == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentTerms),
      billingDay: billingDay == null && nullToAbsent
          ? const Value.absent()
          : Value(billingDay),
      cutoffBuffer: Value(cutoffBuffer),
      primaryColor: primaryColor == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryColor),
      secondaryColor: secondaryColor == null && nullToAbsent
          ? const Value.absent()
          : Value(secondaryColor),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory InvoiceSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceSetting(
      id: serializer.fromJson<int>(json['id']),
      yardId: serializer.fromJson<String>(json['yardId']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      bankDetails: serializer.fromJson<String?>(json['bankDetails']),
      paymentTerms: serializer.fromJson<String?>(json['paymentTerms']),
      billingDay: serializer.fromJson<int?>(json['billingDay']),
      cutoffBuffer: serializer.fromJson<int>(json['cutoffBuffer']),
      primaryColor: serializer.fromJson<String?>(json['primaryColor']),
      secondaryColor: serializer.fromJson<String?>(json['secondaryColor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'yardId': serializer.toJson<String>(yardId),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'bankDetails': serializer.toJson<String?>(bankDetails),
      'paymentTerms': serializer.toJson<String?>(paymentTerms),
      'billingDay': serializer.toJson<int?>(billingDay),
      'cutoffBuffer': serializer.toJson<int>(cutoffBuffer),
      'primaryColor': serializer.toJson<String?>(primaryColor),
      'secondaryColor': serializer.toJson<String?>(secondaryColor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  InvoiceSetting copyWith({
    int? id,
    String? yardId,
    Value<String?> logoUrl = const Value.absent(),
    Value<String?> bankDetails = const Value.absent(),
    Value<String?> paymentTerms = const Value.absent(),
    Value<int?> billingDay = const Value.absent(),
    int? cutoffBuffer,
    Value<String?> primaryColor = const Value.absent(),
    Value<String?> secondaryColor = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => InvoiceSetting(
    id: id ?? this.id,
    yardId: yardId ?? this.yardId,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
    bankDetails: bankDetails.present ? bankDetails.value : this.bankDetails,
    paymentTerms: paymentTerms.present ? paymentTerms.value : this.paymentTerms,
    billingDay: billingDay.present ? billingDay.value : this.billingDay,
    cutoffBuffer: cutoffBuffer ?? this.cutoffBuffer,
    primaryColor: primaryColor.present ? primaryColor.value : this.primaryColor,
    secondaryColor: secondaryColor.present
        ? secondaryColor.value
        : this.secondaryColor,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  InvoiceSetting copyWithCompanion(InvoiceSettingsCompanion data) {
    return InvoiceSetting(
      id: data.id.present ? data.id.value : this.id,
      yardId: data.yardId.present ? data.yardId.value : this.yardId,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      bankDetails: data.bankDetails.present
          ? data.bankDetails.value
          : this.bankDetails,
      paymentTerms: data.paymentTerms.present
          ? data.paymentTerms.value
          : this.paymentTerms,
      billingDay: data.billingDay.present
          ? data.billingDay.value
          : this.billingDay,
      cutoffBuffer: data.cutoffBuffer.present
          ? data.cutoffBuffer.value
          : this.cutoffBuffer,
      primaryColor: data.primaryColor.present
          ? data.primaryColor.value
          : this.primaryColor,
      secondaryColor: data.secondaryColor.present
          ? data.secondaryColor.value
          : this.secondaryColor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceSetting(')
          ..write('id: $id, ')
          ..write('yardId: $yardId, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('bankDetails: $bankDetails, ')
          ..write('paymentTerms: $paymentTerms, ')
          ..write('billingDay: $billingDay, ')
          ..write('cutoffBuffer: $cutoffBuffer, ')
          ..write('primaryColor: $primaryColor, ')
          ..write('secondaryColor: $secondaryColor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    yardId,
    logoUrl,
    bankDetails,
    paymentTerms,
    billingDay,
    cutoffBuffer,
    primaryColor,
    secondaryColor,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceSetting &&
          other.id == this.id &&
          other.yardId == this.yardId &&
          other.logoUrl == this.logoUrl &&
          other.bankDetails == this.bankDetails &&
          other.paymentTerms == this.paymentTerms &&
          other.billingDay == this.billingDay &&
          other.cutoffBuffer == this.cutoffBuffer &&
          other.primaryColor == this.primaryColor &&
          other.secondaryColor == this.secondaryColor &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InvoiceSettingsCompanion extends UpdateCompanion<InvoiceSetting> {
  final Value<int> id;
  final Value<String> yardId;
  final Value<String?> logoUrl;
  final Value<String?> bankDetails;
  final Value<String?> paymentTerms;
  final Value<int?> billingDay;
  final Value<int> cutoffBuffer;
  final Value<String?> primaryColor;
  final Value<String?> secondaryColor;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const InvoiceSettingsCompanion({
    this.id = const Value.absent(),
    this.yardId = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.bankDetails = const Value.absent(),
    this.paymentTerms = const Value.absent(),
    this.billingDay = const Value.absent(),
    this.cutoffBuffer = const Value.absent(),
    this.primaryColor = const Value.absent(),
    this.secondaryColor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  InvoiceSettingsCompanion.insert({
    this.id = const Value.absent(),
    required String yardId,
    this.logoUrl = const Value.absent(),
    this.bankDetails = const Value.absent(),
    this.paymentTerms = const Value.absent(),
    this.billingDay = const Value.absent(),
    this.cutoffBuffer = const Value.absent(),
    this.primaryColor = const Value.absent(),
    this.secondaryColor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : yardId = Value(yardId);
  static Insertable<InvoiceSetting> custom({
    Expression<int>? id,
    Expression<String>? yardId,
    Expression<String>? logoUrl,
    Expression<String>? bankDetails,
    Expression<String>? paymentTerms,
    Expression<int>? billingDay,
    Expression<int>? cutoffBuffer,
    Expression<String>? primaryColor,
    Expression<String>? secondaryColor,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (yardId != null) 'yard_id': yardId,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (bankDetails != null) 'bank_details': bankDetails,
      if (paymentTerms != null) 'payment_terms': paymentTerms,
      if (billingDay != null) 'billing_day': billingDay,
      if (cutoffBuffer != null) 'cutoff_buffer': cutoffBuffer,
      if (primaryColor != null) 'primary_color': primaryColor,
      if (secondaryColor != null) 'secondary_color': secondaryColor,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  InvoiceSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? yardId,
    Value<String?>? logoUrl,
    Value<String?>? bankDetails,
    Value<String?>? paymentTerms,
    Value<int?>? billingDay,
    Value<int>? cutoffBuffer,
    Value<String?>? primaryColor,
    Value<String?>? secondaryColor,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return InvoiceSettingsCompanion(
      id: id ?? this.id,
      yardId: yardId ?? this.yardId,
      logoUrl: logoUrl ?? this.logoUrl,
      bankDetails: bankDetails ?? this.bankDetails,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      billingDay: billingDay ?? this.billingDay,
      cutoffBuffer: cutoffBuffer ?? this.cutoffBuffer,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (yardId.present) {
      map['yard_id'] = Variable<String>(yardId.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (bankDetails.present) {
      map['bank_details'] = Variable<String>(bankDetails.value);
    }
    if (paymentTerms.present) {
      map['payment_terms'] = Variable<String>(paymentTerms.value);
    }
    if (billingDay.present) {
      map['billing_day'] = Variable<int>(billingDay.value);
    }
    if (cutoffBuffer.present) {
      map['cutoff_buffer'] = Variable<int>(cutoffBuffer.value);
    }
    if (primaryColor.present) {
      map['primary_color'] = Variable<String>(primaryColor.value);
    }
    if (secondaryColor.present) {
      map['secondary_color'] = Variable<String>(secondaryColor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceSettingsCompanion(')
          ..write('id: $id, ')
          ..write('yardId: $yardId, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('bankDetails: $bankDetails, ')
          ..write('paymentTerms: $paymentTerms, ')
          ..write('billingDay: $billingDay, ')
          ..write('cutoffBuffer: $cutoffBuffer, ')
          ..write('primaryColor: $primaryColor, ')
          ..write('secondaryColor: $secondaryColor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetTable,
    operation,
    recordId,
    payloadJson,
    createdAt,
    status,
    retryCount,
    lastError,
    groupId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      ),
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final String id;
  final String targetTable;
  final String operation;
  final String? recordId;
  final String payloadJson;
  final DateTime createdAt;
  final String status;
  final int retryCount;
  final String? lastError;
  final String? groupId;
  const SyncQueueData({
    required this.id,
    required this.targetTable,
    required this.operation,
    this.recordId,
    required this.payloadJson,
    required this.createdAt,
    required this.status,
    required this.retryCount,
    this.lastError,
    this.groupId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['target_table'] = Variable<String>(targetTable);
    map['operation'] = Variable<String>(operation);
    if (!nullToAbsent || recordId != null) {
      map['record_id'] = Variable<String>(recordId);
    }
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      targetTable: Value(targetTable),
      operation: Value(operation),
      recordId: recordId == null && nullToAbsent
          ? const Value.absent()
          : Value(recordId),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      status: Value(status),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<String>(json['id']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      operation: serializer.fromJson<String>(json['operation']),
      recordId: serializer.fromJson<String?>(json['recordId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      groupId: serializer.fromJson<String?>(json['groupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'targetTable': serializer.toJson<String>(targetTable),
      'operation': serializer.toJson<String>(operation),
      'recordId': serializer.toJson<String?>(recordId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'groupId': serializer.toJson<String?>(groupId),
    };
  }

  SyncQueueData copyWith({
    String? id,
    String? targetTable,
    String? operation,
    Value<String?> recordId = const Value.absent(),
    String? payloadJson,
    DateTime? createdAt,
    String? status,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    Value<String?> groupId = const Value.absent(),
  }) => SyncQueueData(
    id: id ?? this.id,
    targetTable: targetTable ?? this.targetTable,
    operation: operation ?? this.operation,
    recordId: recordId.present ? recordId.value : this.recordId,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    groupId: groupId.present ? groupId.value : this.groupId,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      operation: data.operation.present ? data.operation.value : this.operation,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('operation: $operation, ')
          ..write('recordId: $recordId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('groupId: $groupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetTable,
    operation,
    recordId,
    payloadJson,
    createdAt,
    status,
    retryCount,
    lastError,
    groupId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.targetTable == this.targetTable &&
          other.operation == this.operation &&
          other.recordId == this.recordId &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.groupId == this.groupId);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<String> id;
  final Value<String> targetTable;
  final Value<String> operation;
  final Value<String?> recordId;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<String?> groupId;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.operation = const Value.absent(),
    this.recordId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.groupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String id,
    required String targetTable,
    required String operation,
    this.recordId = const Value.absent(),
    required String payloadJson,
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.groupId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       targetTable = Value(targetTable),
       operation = Value(operation),
       payloadJson = Value(payloadJson);
  static Insertable<SyncQueueData> custom({
    Expression<String>? id,
    Expression<String>? targetTable,
    Expression<String>? operation,
    Expression<String>? recordId,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<String>? groupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetTable != null) 'target_table': targetTable,
      if (operation != null) 'operation': operation,
      if (recordId != null) 'record_id': recordId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (groupId != null) 'group_id': groupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith({
    Value<String>? id,
    Value<String>? targetTable,
    Value<String>? operation,
    Value<String?>? recordId,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<String>? status,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<String?>? groupId,
    Value<int>? rowid,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      targetTable: targetTable ?? this.targetTable,
      operation: operation ?? this.operation,
      recordId: recordId ?? this.recordId,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      groupId: groupId ?? this.groupId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('operation: $operation, ')
          ..write('recordId: $recordId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('groupId: $groupId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $YardAccessRequestsTable extends YardAccessRequests
    with TableInfo<$YardAccessRequestsTable, YardAccessRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $YardAccessRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yardIdMeta = const VerificationMeta('yardId');
  @override
  late final GeneratedColumn<String> yardId = GeneratedColumn<String>(
    'yard_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewedByMeta = const VerificationMeta(
    'reviewedBy',
  );
  @override
  late final GeneratedColumn<String> reviewedBy = GeneratedColumn<String>(
    'reviewed_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    yardId,
    userId,
    status,
    message,
    reviewedBy,
    reviewedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'yard_access_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<YardAccessRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('yard_id')) {
      context.handle(
        _yardIdMeta,
        yardId.isAcceptableOrUnknown(data['yard_id']!, _yardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_yardIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    if (data.containsKey('reviewed_by')) {
      context.handle(
        _reviewedByMeta,
        reviewedBy.isAcceptableOrUnknown(data['reviewed_by']!, _reviewedByMeta),
      );
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  YardAccessRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return YardAccessRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      yardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}yard_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      ),
      reviewedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reviewed_by'],
      ),
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $YardAccessRequestsTable createAlias(String alias) {
    return $YardAccessRequestsTable(attachedDatabase, alias);
  }
}

class YardAccessRequest extends DataClass
    implements Insertable<YardAccessRequest> {
  final String id;
  final String yardId;
  final String userId;
  final String status;
  final String? message;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  const YardAccessRequest({
    required this.id,
    required this.yardId,
    required this.userId,
    required this.status,
    this.message,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['yard_id'] = Variable<String>(yardId);
    map['user_id'] = Variable<String>(userId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    if (!nullToAbsent || reviewedBy != null) {
      map['reviewed_by'] = Variable<String>(reviewedBy);
    }
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  YardAccessRequestsCompanion toCompanion(bool nullToAbsent) {
    return YardAccessRequestsCompanion(
      id: Value(id),
      yardId: Value(yardId),
      userId: Value(userId),
      status: Value(status),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      reviewedBy: reviewedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedBy),
      reviewedAt: reviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedAt),
      createdAt: Value(createdAt),
    );
  }

  factory YardAccessRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return YardAccessRequest(
      id: serializer.fromJson<String>(json['id']),
      yardId: serializer.fromJson<String>(json['yardId']),
      userId: serializer.fromJson<String>(json['userId']),
      status: serializer.fromJson<String>(json['status']),
      message: serializer.fromJson<String?>(json['message']),
      reviewedBy: serializer.fromJson<String?>(json['reviewedBy']),
      reviewedAt: serializer.fromJson<DateTime?>(json['reviewedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'yardId': serializer.toJson<String>(yardId),
      'userId': serializer.toJson<String>(userId),
      'status': serializer.toJson<String>(status),
      'message': serializer.toJson<String?>(message),
      'reviewedBy': serializer.toJson<String?>(reviewedBy),
      'reviewedAt': serializer.toJson<DateTime?>(reviewedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  YardAccessRequest copyWith({
    String? id,
    String? yardId,
    String? userId,
    String? status,
    Value<String?> message = const Value.absent(),
    Value<String?> reviewedBy = const Value.absent(),
    Value<DateTime?> reviewedAt = const Value.absent(),
    DateTime? createdAt,
  }) => YardAccessRequest(
    id: id ?? this.id,
    yardId: yardId ?? this.yardId,
    userId: userId ?? this.userId,
    status: status ?? this.status,
    message: message.present ? message.value : this.message,
    reviewedBy: reviewedBy.present ? reviewedBy.value : this.reviewedBy,
    reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  YardAccessRequest copyWithCompanion(YardAccessRequestsCompanion data) {
    return YardAccessRequest(
      id: data.id.present ? data.id.value : this.id,
      yardId: data.yardId.present ? data.yardId.value : this.yardId,
      userId: data.userId.present ? data.userId.value : this.userId,
      status: data.status.present ? data.status.value : this.status,
      message: data.message.present ? data.message.value : this.message,
      reviewedBy: data.reviewedBy.present
          ? data.reviewedBy.value
          : this.reviewedBy,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('YardAccessRequest(')
          ..write('id: $id, ')
          ..write('yardId: $yardId, ')
          ..write('userId: $userId, ')
          ..write('status: $status, ')
          ..write('message: $message, ')
          ..write('reviewedBy: $reviewedBy, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    yardId,
    userId,
    status,
    message,
    reviewedBy,
    reviewedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is YardAccessRequest &&
          other.id == this.id &&
          other.yardId == this.yardId &&
          other.userId == this.userId &&
          other.status == this.status &&
          other.message == this.message &&
          other.reviewedBy == this.reviewedBy &&
          other.reviewedAt == this.reviewedAt &&
          other.createdAt == this.createdAt);
}

class YardAccessRequestsCompanion extends UpdateCompanion<YardAccessRequest> {
  final Value<String> id;
  final Value<String> yardId;
  final Value<String> userId;
  final Value<String> status;
  final Value<String?> message;
  final Value<String?> reviewedBy;
  final Value<DateTime?> reviewedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const YardAccessRequestsCompanion({
    this.id = const Value.absent(),
    this.yardId = const Value.absent(),
    this.userId = const Value.absent(),
    this.status = const Value.absent(),
    this.message = const Value.absent(),
    this.reviewedBy = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  YardAccessRequestsCompanion.insert({
    required String id,
    required String yardId,
    required String userId,
    this.status = const Value.absent(),
    this.message = const Value.absent(),
    this.reviewedBy = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       yardId = Value(yardId),
       userId = Value(userId);
  static Insertable<YardAccessRequest> custom({
    Expression<String>? id,
    Expression<String>? yardId,
    Expression<String>? userId,
    Expression<String>? status,
    Expression<String>? message,
    Expression<String>? reviewedBy,
    Expression<DateTime>? reviewedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (yardId != null) 'yard_id': yardId,
      if (userId != null) 'user_id': userId,
      if (status != null) 'status': status,
      if (message != null) 'message': message,
      if (reviewedBy != null) 'reviewed_by': reviewedBy,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  YardAccessRequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? yardId,
    Value<String>? userId,
    Value<String>? status,
    Value<String?>? message,
    Value<String?>? reviewedBy,
    Value<DateTime?>? reviewedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return YardAccessRequestsCompanion(
      id: id ?? this.id,
      yardId: yardId ?? this.yardId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      message: message ?? this.message,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
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
    if (yardId.present) {
      map['yard_id'] = Variable<String>(yardId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (reviewedBy.present) {
      map['reviewed_by'] = Variable<String>(reviewedBy.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
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
    return (StringBuffer('YardAccessRequestsCompanion(')
          ..write('id: $id, ')
          ..write('yardId: $yardId, ')
          ..write('userId: $userId, ')
          ..write('status: $status, ')
          ..write('message: $message, ')
          ..write('reviewedBy: $reviewedBy, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HorsesTable extends Horses with TableInfo<$HorsesTable, Horse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HorsesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
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
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
    'breed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stableNumberMeta = const VerificationMeta(
    'stableNumber',
  );
  @override
  late final GeneratedColumn<String> stableNumber = GeneratedColumn<String>(
    'stable_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dietNotesMeta = const VerificationMeta(
    'dietNotes',
  );
  @override
  late final GeneratedColumn<String> dietNotes = GeneratedColumn<String>(
    'diet_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _careInstructionsMeta = const VerificationMeta(
    'careInstructions',
  );
  @override
  late final GeneratedColumn<String> careInstructions = GeneratedColumn<String>(
    'care_instructions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feedInstructionsMeta = const VerificationMeta(
    'feedInstructions',
  );
  @override
  late final GeneratedColumn<String> feedInstructions = GeneratedColumn<String>(
    'feed_instructions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _medicalNotesMeta = const VerificationMeta(
    'medicalNotes',
  );
  @override
  late final GeneratedColumn<String> medicalNotes = GeneratedColumn<String>(
    'medical_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vetNameMeta = const VerificationMeta(
    'vetName',
  );
  @override
  late final GeneratedColumn<String> vetName = GeneratedColumn<String>(
    'vet_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vetPhoneMeta = const VerificationMeta(
    'vetPhone',
  );
  @override
  late final GeneratedColumn<String> vetPhone = GeneratedColumn<String>(
    'vet_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _farrierNameMeta = const VerificationMeta(
    'farrierName',
  );
  @override
  late final GeneratedColumn<String> farrierName = GeneratedColumn<String>(
    'farrier_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _farrierPhoneMeta = const VerificationMeta(
    'farrierPhone',
  );
  @override
  late final GeneratedColumn<String> farrierPhone = GeneratedColumn<String>(
    'farrier_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    name,
    breed,
    color,
    age,
    gender,
    stableNumber,
    photoUrl,
    dietNotes,
    careInstructions,
    feedInstructions,
    medicalNotes,
    vetName,
    vetPhone,
    farrierName,
    farrierPhone,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'horses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Horse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('breed')) {
      context.handle(
        _breedMeta,
        breed.isAcceptableOrUnknown(data['breed']!, _breedMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('stable_number')) {
      context.handle(
        _stableNumberMeta,
        stableNumber.isAcceptableOrUnknown(
          data['stable_number']!,
          _stableNumberMeta,
        ),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('diet_notes')) {
      context.handle(
        _dietNotesMeta,
        dietNotes.isAcceptableOrUnknown(data['diet_notes']!, _dietNotesMeta),
      );
    }
    if (data.containsKey('care_instructions')) {
      context.handle(
        _careInstructionsMeta,
        careInstructions.isAcceptableOrUnknown(
          data['care_instructions']!,
          _careInstructionsMeta,
        ),
      );
    }
    if (data.containsKey('feed_instructions')) {
      context.handle(
        _feedInstructionsMeta,
        feedInstructions.isAcceptableOrUnknown(
          data['feed_instructions']!,
          _feedInstructionsMeta,
        ),
      );
    }
    if (data.containsKey('medical_notes')) {
      context.handle(
        _medicalNotesMeta,
        medicalNotes.isAcceptableOrUnknown(
          data['medical_notes']!,
          _medicalNotesMeta,
        ),
      );
    }
    if (data.containsKey('vet_name')) {
      context.handle(
        _vetNameMeta,
        vetName.isAcceptableOrUnknown(data['vet_name']!, _vetNameMeta),
      );
    }
    if (data.containsKey('vet_phone')) {
      context.handle(
        _vetPhoneMeta,
        vetPhone.isAcceptableOrUnknown(data['vet_phone']!, _vetPhoneMeta),
      );
    }
    if (data.containsKey('farrier_name')) {
      context.handle(
        _farrierNameMeta,
        farrierName.isAcceptableOrUnknown(
          data['farrier_name']!,
          _farrierNameMeta,
        ),
      );
    }
    if (data.containsKey('farrier_phone')) {
      context.handle(
        _farrierPhoneMeta,
        farrierPhone.isAcceptableOrUnknown(
          data['farrier_phone']!,
          _farrierPhoneMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Horse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Horse(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      breed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breed'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      stableNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_number'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      dietNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diet_notes'],
      ),
      careInstructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}care_instructions'],
      ),
      feedInstructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_instructions'],
      ),
      medicalNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medical_notes'],
      ),
      vetName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vet_name'],
      ),
      vetPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vet_phone'],
      ),
      farrierName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farrier_name'],
      ),
      farrierPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farrier_phone'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HorsesTable createAlias(String alias) {
    return $HorsesTable(attachedDatabase, alias);
  }
}

class Horse extends DataClass implements Insertable<Horse> {
  final String id;
  final String ownerId;
  final String name;
  final String? breed;
  final String? color;
  final int? age;
  final String? gender;
  final String? stableNumber;
  final String? photoUrl;
  final String? dietNotes;
  final String? careInstructions;
  final String? feedInstructions;
  final String? medicalNotes;
  final String? vetName;
  final String? vetPhone;
  final String? farrierName;
  final String? farrierPhone;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Horse({
    required this.id,
    required this.ownerId,
    required this.name,
    this.breed,
    this.color,
    this.age,
    this.gender,
    this.stableNumber,
    this.photoUrl,
    this.dietNotes,
    this.careInstructions,
    this.feedInstructions,
    this.medicalNotes,
    this.vetName,
    this.vetPhone,
    this.farrierName,
    this.farrierPhone,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || breed != null) {
      map['breed'] = Variable<String>(breed);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || stableNumber != null) {
      map['stable_number'] = Variable<String>(stableNumber);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || dietNotes != null) {
      map['diet_notes'] = Variable<String>(dietNotes);
    }
    if (!nullToAbsent || careInstructions != null) {
      map['care_instructions'] = Variable<String>(careInstructions);
    }
    if (!nullToAbsent || feedInstructions != null) {
      map['feed_instructions'] = Variable<String>(feedInstructions);
    }
    if (!nullToAbsent || medicalNotes != null) {
      map['medical_notes'] = Variable<String>(medicalNotes);
    }
    if (!nullToAbsent || vetName != null) {
      map['vet_name'] = Variable<String>(vetName);
    }
    if (!nullToAbsent || vetPhone != null) {
      map['vet_phone'] = Variable<String>(vetPhone);
    }
    if (!nullToAbsent || farrierName != null) {
      map['farrier_name'] = Variable<String>(farrierName);
    }
    if (!nullToAbsent || farrierPhone != null) {
      map['farrier_phone'] = Variable<String>(farrierPhone);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HorsesCompanion toCompanion(bool nullToAbsent) {
    return HorsesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      name: Value(name),
      breed: breed == null && nullToAbsent
          ? const Value.absent()
          : Value(breed),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      stableNumber: stableNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(stableNumber),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      dietNotes: dietNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(dietNotes),
      careInstructions: careInstructions == null && nullToAbsent
          ? const Value.absent()
          : Value(careInstructions),
      feedInstructions: feedInstructions == null && nullToAbsent
          ? const Value.absent()
          : Value(feedInstructions),
      medicalNotes: medicalNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(medicalNotes),
      vetName: vetName == null && nullToAbsent
          ? const Value.absent()
          : Value(vetName),
      vetPhone: vetPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(vetPhone),
      farrierName: farrierName == null && nullToAbsent
          ? const Value.absent()
          : Value(farrierName),
      farrierPhone: farrierPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(farrierPhone),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Horse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Horse(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      breed: serializer.fromJson<String?>(json['breed']),
      color: serializer.fromJson<String?>(json['color']),
      age: serializer.fromJson<int?>(json['age']),
      gender: serializer.fromJson<String?>(json['gender']),
      stableNumber: serializer.fromJson<String?>(json['stableNumber']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      dietNotes: serializer.fromJson<String?>(json['dietNotes']),
      careInstructions: serializer.fromJson<String?>(json['careInstructions']),
      feedInstructions: serializer.fromJson<String?>(json['feedInstructions']),
      medicalNotes: serializer.fromJson<String?>(json['medicalNotes']),
      vetName: serializer.fromJson<String?>(json['vetName']),
      vetPhone: serializer.fromJson<String?>(json['vetPhone']),
      farrierName: serializer.fromJson<String?>(json['farrierName']),
      farrierPhone: serializer.fromJson<String?>(json['farrierPhone']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'name': serializer.toJson<String>(name),
      'breed': serializer.toJson<String?>(breed),
      'color': serializer.toJson<String?>(color),
      'age': serializer.toJson<int?>(age),
      'gender': serializer.toJson<String?>(gender),
      'stableNumber': serializer.toJson<String?>(stableNumber),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'dietNotes': serializer.toJson<String?>(dietNotes),
      'careInstructions': serializer.toJson<String?>(careInstructions),
      'feedInstructions': serializer.toJson<String?>(feedInstructions),
      'medicalNotes': serializer.toJson<String?>(medicalNotes),
      'vetName': serializer.toJson<String?>(vetName),
      'vetPhone': serializer.toJson<String?>(vetPhone),
      'farrierName': serializer.toJson<String?>(farrierName),
      'farrierPhone': serializer.toJson<String?>(farrierPhone),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Horse copyWith({
    String? id,
    String? ownerId,
    String? name,
    Value<String?> breed = const Value.absent(),
    Value<String?> color = const Value.absent(),
    Value<int?> age = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    Value<String?> stableNumber = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    Value<String?> dietNotes = const Value.absent(),
    Value<String?> careInstructions = const Value.absent(),
    Value<String?> feedInstructions = const Value.absent(),
    Value<String?> medicalNotes = const Value.absent(),
    Value<String?> vetName = const Value.absent(),
    Value<String?> vetPhone = const Value.absent(),
    Value<String?> farrierName = const Value.absent(),
    Value<String?> farrierPhone = const Value.absent(),
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Horse(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    name: name ?? this.name,
    breed: breed.present ? breed.value : this.breed,
    color: color.present ? color.value : this.color,
    age: age.present ? age.value : this.age,
    gender: gender.present ? gender.value : this.gender,
    stableNumber: stableNumber.present ? stableNumber.value : this.stableNumber,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    dietNotes: dietNotes.present ? dietNotes.value : this.dietNotes,
    careInstructions: careInstructions.present
        ? careInstructions.value
        : this.careInstructions,
    feedInstructions: feedInstructions.present
        ? feedInstructions.value
        : this.feedInstructions,
    medicalNotes: medicalNotes.present ? medicalNotes.value : this.medicalNotes,
    vetName: vetName.present ? vetName.value : this.vetName,
    vetPhone: vetPhone.present ? vetPhone.value : this.vetPhone,
    farrierName: farrierName.present ? farrierName.value : this.farrierName,
    farrierPhone: farrierPhone.present ? farrierPhone.value : this.farrierPhone,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Horse copyWithCompanion(HorsesCompanion data) {
    return Horse(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      breed: data.breed.present ? data.breed.value : this.breed,
      color: data.color.present ? data.color.value : this.color,
      age: data.age.present ? data.age.value : this.age,
      gender: data.gender.present ? data.gender.value : this.gender,
      stableNumber: data.stableNumber.present
          ? data.stableNumber.value
          : this.stableNumber,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      dietNotes: data.dietNotes.present ? data.dietNotes.value : this.dietNotes,
      careInstructions: data.careInstructions.present
          ? data.careInstructions.value
          : this.careInstructions,
      feedInstructions: data.feedInstructions.present
          ? data.feedInstructions.value
          : this.feedInstructions,
      medicalNotes: data.medicalNotes.present
          ? data.medicalNotes.value
          : this.medicalNotes,
      vetName: data.vetName.present ? data.vetName.value : this.vetName,
      vetPhone: data.vetPhone.present ? data.vetPhone.value : this.vetPhone,
      farrierName: data.farrierName.present
          ? data.farrierName.value
          : this.farrierName,
      farrierPhone: data.farrierPhone.present
          ? data.farrierPhone.value
          : this.farrierPhone,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Horse(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('breed: $breed, ')
          ..write('color: $color, ')
          ..write('age: $age, ')
          ..write('gender: $gender, ')
          ..write('stableNumber: $stableNumber, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('dietNotes: $dietNotes, ')
          ..write('careInstructions: $careInstructions, ')
          ..write('feedInstructions: $feedInstructions, ')
          ..write('medicalNotes: $medicalNotes, ')
          ..write('vetName: $vetName, ')
          ..write('vetPhone: $vetPhone, ')
          ..write('farrierName: $farrierName, ')
          ..write('farrierPhone: $farrierPhone, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    name,
    breed,
    color,
    age,
    gender,
    stableNumber,
    photoUrl,
    dietNotes,
    careInstructions,
    feedInstructions,
    medicalNotes,
    vetName,
    vetPhone,
    farrierName,
    farrierPhone,
    isDeleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Horse &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.breed == this.breed &&
          other.color == this.color &&
          other.age == this.age &&
          other.gender == this.gender &&
          other.stableNumber == this.stableNumber &&
          other.photoUrl == this.photoUrl &&
          other.dietNotes == this.dietNotes &&
          other.careInstructions == this.careInstructions &&
          other.feedInstructions == this.feedInstructions &&
          other.medicalNotes == this.medicalNotes &&
          other.vetName == this.vetName &&
          other.vetPhone == this.vetPhone &&
          other.farrierName == this.farrierName &&
          other.farrierPhone == this.farrierPhone &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class HorsesCompanion extends UpdateCompanion<Horse> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> name;
  final Value<String?> breed;
  final Value<String?> color;
  final Value<int?> age;
  final Value<String?> gender;
  final Value<String?> stableNumber;
  final Value<String?> photoUrl;
  final Value<String?> dietNotes;
  final Value<String?> careInstructions;
  final Value<String?> feedInstructions;
  final Value<String?> medicalNotes;
  final Value<String?> vetName;
  final Value<String?> vetPhone;
  final Value<String?> farrierName;
  final Value<String?> farrierPhone;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const HorsesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.breed = const Value.absent(),
    this.color = const Value.absent(),
    this.age = const Value.absent(),
    this.gender = const Value.absent(),
    this.stableNumber = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.dietNotes = const Value.absent(),
    this.careInstructions = const Value.absent(),
    this.feedInstructions = const Value.absent(),
    this.medicalNotes = const Value.absent(),
    this.vetName = const Value.absent(),
    this.vetPhone = const Value.absent(),
    this.farrierName = const Value.absent(),
    this.farrierPhone = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HorsesCompanion.insert({
    required String id,
    required String ownerId,
    required String name,
    this.breed = const Value.absent(),
    this.color = const Value.absent(),
    this.age = const Value.absent(),
    this.gender = const Value.absent(),
    this.stableNumber = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.dietNotes = const Value.absent(),
    this.careInstructions = const Value.absent(),
    this.feedInstructions = const Value.absent(),
    this.medicalNotes = const Value.absent(),
    this.vetName = const Value.absent(),
    this.vetPhone = const Value.absent(),
    this.farrierName = const Value.absent(),
    this.farrierPhone = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       name = Value(name);
  static Insertable<Horse> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<String>? breed,
    Expression<String>? color,
    Expression<int>? age,
    Expression<String>? gender,
    Expression<String>? stableNumber,
    Expression<String>? photoUrl,
    Expression<String>? dietNotes,
    Expression<String>? careInstructions,
    Expression<String>? feedInstructions,
    Expression<String>? medicalNotes,
    Expression<String>? vetName,
    Expression<String>? vetPhone,
    Expression<String>? farrierName,
    Expression<String>? farrierPhone,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (breed != null) 'breed': breed,
      if (color != null) 'color': color,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (stableNumber != null) 'stable_number': stableNumber,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (dietNotes != null) 'diet_notes': dietNotes,
      if (careInstructions != null) 'care_instructions': careInstructions,
      if (feedInstructions != null) 'feed_instructions': feedInstructions,
      if (medicalNotes != null) 'medical_notes': medicalNotes,
      if (vetName != null) 'vet_name': vetName,
      if (vetPhone != null) 'vet_phone': vetPhone,
      if (farrierName != null) 'farrier_name': farrierName,
      if (farrierPhone != null) 'farrier_phone': farrierPhone,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HorsesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? name,
    Value<String?>? breed,
    Value<String?>? color,
    Value<int?>? age,
    Value<String?>? gender,
    Value<String?>? stableNumber,
    Value<String?>? photoUrl,
    Value<String?>? dietNotes,
    Value<String?>? careInstructions,
    Value<String?>? feedInstructions,
    Value<String?>? medicalNotes,
    Value<String?>? vetName,
    Value<String?>? vetPhone,
    Value<String?>? farrierName,
    Value<String?>? farrierPhone,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return HorsesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      color: color ?? this.color,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      stableNumber: stableNumber ?? this.stableNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      dietNotes: dietNotes ?? this.dietNotes,
      careInstructions: careInstructions ?? this.careInstructions,
      feedInstructions: feedInstructions ?? this.feedInstructions,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      vetName: vetName ?? this.vetName,
      vetPhone: vetPhone ?? this.vetPhone,
      farrierName: farrierName ?? this.farrierName,
      farrierPhone: farrierPhone ?? this.farrierPhone,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (stableNumber.present) {
      map['stable_number'] = Variable<String>(stableNumber.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (dietNotes.present) {
      map['diet_notes'] = Variable<String>(dietNotes.value);
    }
    if (careInstructions.present) {
      map['care_instructions'] = Variable<String>(careInstructions.value);
    }
    if (feedInstructions.present) {
      map['feed_instructions'] = Variable<String>(feedInstructions.value);
    }
    if (medicalNotes.present) {
      map['medical_notes'] = Variable<String>(medicalNotes.value);
    }
    if (vetName.present) {
      map['vet_name'] = Variable<String>(vetName.value);
    }
    if (vetPhone.present) {
      map['vet_phone'] = Variable<String>(vetPhone.value);
    }
    if (farrierName.present) {
      map['farrier_name'] = Variable<String>(farrierName.value);
    }
    if (farrierPhone.present) {
      map['farrier_phone'] = Variable<String>(farrierPhone.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HorsesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('breed: $breed, ')
          ..write('color: $color, ')
          ..write('age: $age, ')
          ..write('gender: $gender, ')
          ..write('stableNumber: $stableNumber, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('dietNotes: $dietNotes, ')
          ..write('careInstructions: $careInstructions, ')
          ..write('feedInstructions: $feedInstructions, ')
          ..write('medicalNotes: $medicalNotes, ')
          ..write('vetName: $vetName, ')
          ..write('vetPhone: $vetPhone, ')
          ..write('farrierName: $farrierName, ')
          ..write('farrierPhone: $farrierPhone, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $YardsTable yards = $YardsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $ConsumableTypesTable consumableTypes = $ConsumableTypesTable(
    this,
  );
  late final $LiveryPackagesTable liveryPackages = $LiveryPackagesTable(this);
  late final $InvoiceSettingsTable invoiceSettings = $InvoiceSettingsTable(
    this,
  );
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $YardAccessRequestsTable yardAccessRequests =
      $YardAccessRequestsTable(this);
  late final $HorsesTable horses = $HorsesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    yards,
    profiles,
    consumableTypes,
    liveryPackages,
    invoiceSettings,
    syncQueue,
    yardAccessRequests,
    horses,
  ];
}

typedef $$YardsTableCreateCompanionBuilder =
    YardsCompanion Function({
      required String id,
      required String name,
      Value<String?> address,
      required String createdBy,
      Value<String?> inviteCode,
      Value<DateTime?> inviteCodeExpiresAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$YardsTableUpdateCompanionBuilder =
    YardsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> address,
      Value<String> createdBy,
      Value<String?> inviteCode,
      Value<DateTime?> inviteCodeExpiresAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$YardsTableFilterComposer extends Composer<_$AppDatabase, $YardsTable> {
  $$YardsTableFilterComposer({
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

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inviteCode => $composableBuilder(
    column: $table.inviteCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inviteCodeExpiresAt => $composableBuilder(
    column: $table.inviteCodeExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$YardsTableOrderingComposer
    extends Composer<_$AppDatabase, $YardsTable> {
  $$YardsTableOrderingComposer({
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

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inviteCode => $composableBuilder(
    column: $table.inviteCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inviteCodeExpiresAt => $composableBuilder(
    column: $table.inviteCodeExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$YardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $YardsTable> {
  $$YardsTableAnnotationComposer({
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

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get inviteCode => $composableBuilder(
    column: $table.inviteCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get inviteCodeExpiresAt => $composableBuilder(
    column: $table.inviteCodeExpiresAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$YardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $YardsTable,
          Yard,
          $$YardsTableFilterComposer,
          $$YardsTableOrderingComposer,
          $$YardsTableAnnotationComposer,
          $$YardsTableCreateCompanionBuilder,
          $$YardsTableUpdateCompanionBuilder,
          (Yard, BaseReferences<_$AppDatabase, $YardsTable, Yard>),
          Yard,
          PrefetchHooks Function()
        > {
  $$YardsTableTableManager(_$AppDatabase db, $YardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$YardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$YardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$YardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String?> inviteCode = const Value.absent(),
                Value<DateTime?> inviteCodeExpiresAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => YardsCompanion(
                id: id,
                name: name,
                address: address,
                createdBy: createdBy,
                inviteCode: inviteCode,
                inviteCodeExpiresAt: inviteCodeExpiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> address = const Value.absent(),
                required String createdBy,
                Value<String?> inviteCode = const Value.absent(),
                Value<DateTime?> inviteCodeExpiresAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => YardsCompanion.insert(
                id: id,
                name: name,
                address: address,
                createdBy: createdBy,
                inviteCode: inviteCode,
                inviteCodeExpiresAt: inviteCodeExpiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$YardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $YardsTable,
      Yard,
      $$YardsTableFilterComposer,
      $$YardsTableOrderingComposer,
      $$YardsTableAnnotationComposer,
      $$YardsTableCreateCompanionBuilder,
      $$YardsTableUpdateCompanionBuilder,
      (Yard, BaseReferences<_$AppDatabase, $YardsTable, Yard>),
      Yard,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String userId,
      Value<String?> yardId,
      required String role,
      Value<String?> fullName,
      Value<bool> onboardingCompleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> userId,
      Value<String?> yardId,
      Value<String> role,
      Value<String?> fullName,
      Value<bool> onboardingCompleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get yardId => $composableBuilder(
    column: $table.yardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get yardId => $composableBuilder(
    column: $table.yardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get yardId =>
      $composableBuilder(column: $table.yardId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String?> yardId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                userId: userId,
                yardId: yardId,
                role: role,
                fullName: fullName,
                onboardingCompleted: onboardingCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<String?> yardId = const Value.absent(),
                required String role,
                Value<String?> fullName = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                userId: userId,
                yardId: yardId,
                role: role,
                fullName: fullName,
                onboardingCompleted: onboardingCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$ConsumableTypesTableCreateCompanionBuilder =
    ConsumableTypesCompanion Function({
      required String id,
      required String yardId,
      required String name,
      required String stockUnit,
      required String usageUnit,
      required int ratio,
      required double pricePerUsageUnit,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ConsumableTypesTableUpdateCompanionBuilder =
    ConsumableTypesCompanion Function({
      Value<String> id,
      Value<String> yardId,
      Value<String> name,
      Value<String> stockUnit,
      Value<String> usageUnit,
      Value<int> ratio,
      Value<double> pricePerUsageUnit,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ConsumableTypesTableFilterComposer
    extends Composer<_$AppDatabase, $ConsumableTypesTable> {
  $$ConsumableTypesTableFilterComposer({
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

  ColumnFilters<String> get yardId => $composableBuilder(
    column: $table.yardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stockUnit => $composableBuilder(
    column: $table.stockUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usageUnit => $composableBuilder(
    column: $table.usageUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ratio => $composableBuilder(
    column: $table.ratio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePerUsageUnit => $composableBuilder(
    column: $table.pricePerUsageUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConsumableTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $ConsumableTypesTable> {
  $$ConsumableTypesTableOrderingComposer({
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

  ColumnOrderings<String> get yardId => $composableBuilder(
    column: $table.yardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stockUnit => $composableBuilder(
    column: $table.stockUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usageUnit => $composableBuilder(
    column: $table.usageUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ratio => $composableBuilder(
    column: $table.ratio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePerUsageUnit => $composableBuilder(
    column: $table.pricePerUsageUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConsumableTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConsumableTypesTable> {
  $$ConsumableTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get yardId =>
      $composableBuilder(column: $table.yardId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get stockUnit =>
      $composableBuilder(column: $table.stockUnit, builder: (column) => column);

  GeneratedColumn<String> get usageUnit =>
      $composableBuilder(column: $table.usageUnit, builder: (column) => column);

  GeneratedColumn<int> get ratio =>
      $composableBuilder(column: $table.ratio, builder: (column) => column);

  GeneratedColumn<double> get pricePerUsageUnit => $composableBuilder(
    column: $table.pricePerUsageUnit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ConsumableTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConsumableTypesTable,
          ConsumableType,
          $$ConsumableTypesTableFilterComposer,
          $$ConsumableTypesTableOrderingComposer,
          $$ConsumableTypesTableAnnotationComposer,
          $$ConsumableTypesTableCreateCompanionBuilder,
          $$ConsumableTypesTableUpdateCompanionBuilder,
          (
            ConsumableType,
            BaseReferences<
              _$AppDatabase,
              $ConsumableTypesTable,
              ConsumableType
            >,
          ),
          ConsumableType,
          PrefetchHooks Function()
        > {
  $$ConsumableTypesTableTableManager(
    _$AppDatabase db,
    $ConsumableTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConsumableTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConsumableTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConsumableTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> yardId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> stockUnit = const Value.absent(),
                Value<String> usageUnit = const Value.absent(),
                Value<int> ratio = const Value.absent(),
                Value<double> pricePerUsageUnit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsumableTypesCompanion(
                id: id,
                yardId: yardId,
                name: name,
                stockUnit: stockUnit,
                usageUnit: usageUnit,
                ratio: ratio,
                pricePerUsageUnit: pricePerUsageUnit,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String yardId,
                required String name,
                required String stockUnit,
                required String usageUnit,
                required int ratio,
                required double pricePerUsageUnit,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsumableTypesCompanion.insert(
                id: id,
                yardId: yardId,
                name: name,
                stockUnit: stockUnit,
                usageUnit: usageUnit,
                ratio: ratio,
                pricePerUsageUnit: pricePerUsageUnit,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConsumableTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConsumableTypesTable,
      ConsumableType,
      $$ConsumableTypesTableFilterComposer,
      $$ConsumableTypesTableOrderingComposer,
      $$ConsumableTypesTableAnnotationComposer,
      $$ConsumableTypesTableCreateCompanionBuilder,
      $$ConsumableTypesTableUpdateCompanionBuilder,
      (
        ConsumableType,
        BaseReferences<_$AppDatabase, $ConsumableTypesTable, ConsumableType>,
      ),
      ConsumableType,
      PrefetchHooks Function()
    >;
typedef $$LiveryPackagesTableCreateCompanionBuilder =
    LiveryPackagesCompanion Function({
      required String id,
      required String yardId,
      required String name,
      Value<int> version,
      required double basePrice,
      Value<String> includedItemsJson,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LiveryPackagesTableUpdateCompanionBuilder =
    LiveryPackagesCompanion Function({
      Value<String> id,
      Value<String> yardId,
      Value<String> name,
      Value<int> version,
      Value<double> basePrice,
      Value<String> includedItemsJson,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LiveryPackagesTableFilterComposer
    extends Composer<_$AppDatabase, $LiveryPackagesTable> {
  $$LiveryPackagesTableFilterComposer({
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

  ColumnFilters<String> get yardId => $composableBuilder(
    column: $table.yardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get basePrice => $composableBuilder(
    column: $table.basePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get includedItemsJson => $composableBuilder(
    column: $table.includedItemsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LiveryPackagesTableOrderingComposer
    extends Composer<_$AppDatabase, $LiveryPackagesTable> {
  $$LiveryPackagesTableOrderingComposer({
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

  ColumnOrderings<String> get yardId => $composableBuilder(
    column: $table.yardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get basePrice => $composableBuilder(
    column: $table.basePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get includedItemsJson => $composableBuilder(
    column: $table.includedItemsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LiveryPackagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LiveryPackagesTable> {
  $$LiveryPackagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get yardId =>
      $composableBuilder(column: $table.yardId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<double> get basePrice =>
      $composableBuilder(column: $table.basePrice, builder: (column) => column);

  GeneratedColumn<String> get includedItemsJson => $composableBuilder(
    column: $table.includedItemsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LiveryPackagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LiveryPackagesTable,
          LiveryPackage,
          $$LiveryPackagesTableFilterComposer,
          $$LiveryPackagesTableOrderingComposer,
          $$LiveryPackagesTableAnnotationComposer,
          $$LiveryPackagesTableCreateCompanionBuilder,
          $$LiveryPackagesTableUpdateCompanionBuilder,
          (
            LiveryPackage,
            BaseReferences<_$AppDatabase, $LiveryPackagesTable, LiveryPackage>,
          ),
          LiveryPackage,
          PrefetchHooks Function()
        > {
  $$LiveryPackagesTableTableManager(
    _$AppDatabase db,
    $LiveryPackagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LiveryPackagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LiveryPackagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LiveryPackagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> yardId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<double> basePrice = const Value.absent(),
                Value<String> includedItemsJson = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LiveryPackagesCompanion(
                id: id,
                yardId: yardId,
                name: name,
                version: version,
                basePrice: basePrice,
                includedItemsJson: includedItemsJson,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String yardId,
                required String name,
                Value<int> version = const Value.absent(),
                required double basePrice,
                Value<String> includedItemsJson = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LiveryPackagesCompanion.insert(
                id: id,
                yardId: yardId,
                name: name,
                version: version,
                basePrice: basePrice,
                includedItemsJson: includedItemsJson,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LiveryPackagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LiveryPackagesTable,
      LiveryPackage,
      $$LiveryPackagesTableFilterComposer,
      $$LiveryPackagesTableOrderingComposer,
      $$LiveryPackagesTableAnnotationComposer,
      $$LiveryPackagesTableCreateCompanionBuilder,
      $$LiveryPackagesTableUpdateCompanionBuilder,
      (
        LiveryPackage,
        BaseReferences<_$AppDatabase, $LiveryPackagesTable, LiveryPackage>,
      ),
      LiveryPackage,
      PrefetchHooks Function()
    >;
typedef $$InvoiceSettingsTableCreateCompanionBuilder =
    InvoiceSettingsCompanion Function({
      Value<int> id,
      required String yardId,
      Value<String?> logoUrl,
      Value<String?> bankDetails,
      Value<String?> paymentTerms,
      Value<int?> billingDay,
      Value<int> cutoffBuffer,
      Value<String?> primaryColor,
      Value<String?> secondaryColor,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$InvoiceSettingsTableUpdateCompanionBuilder =
    InvoiceSettingsCompanion Function({
      Value<int> id,
      Value<String> yardId,
      Value<String?> logoUrl,
      Value<String?> bankDetails,
      Value<String?> paymentTerms,
      Value<int?> billingDay,
      Value<int> cutoffBuffer,
      Value<String?> primaryColor,
      Value<String?> secondaryColor,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$InvoiceSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceSettingsTable> {
  $$InvoiceSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get yardId => $composableBuilder(
    column: $table.yardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankDetails => $composableBuilder(
    column: $table.bankDetails,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentTerms => $composableBuilder(
    column: $table.paymentTerms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get billingDay => $composableBuilder(
    column: $table.billingDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cutoffBuffer => $composableBuilder(
    column: $table.cutoffBuffer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryColor => $composableBuilder(
    column: $table.primaryColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondaryColor => $composableBuilder(
    column: $table.secondaryColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InvoiceSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceSettingsTable> {
  $$InvoiceSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get yardId => $composableBuilder(
    column: $table.yardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankDetails => $composableBuilder(
    column: $table.bankDetails,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentTerms => $composableBuilder(
    column: $table.paymentTerms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billingDay => $composableBuilder(
    column: $table.billingDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cutoffBuffer => $composableBuilder(
    column: $table.cutoffBuffer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryColor => $composableBuilder(
    column: $table.primaryColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryColor => $composableBuilder(
    column: $table.secondaryColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvoiceSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceSettingsTable> {
  $$InvoiceSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get yardId =>
      $composableBuilder(column: $table.yardId, builder: (column) => column);

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<String> get bankDetails => $composableBuilder(
    column: $table.bankDetails,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentTerms => $composableBuilder(
    column: $table.paymentTerms,
    builder: (column) => column,
  );

  GeneratedColumn<int> get billingDay => $composableBuilder(
    column: $table.billingDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cutoffBuffer => $composableBuilder(
    column: $table.cutoffBuffer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryColor => $composableBuilder(
    column: $table.primaryColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondaryColor => $composableBuilder(
    column: $table.secondaryColor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$InvoiceSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoiceSettingsTable,
          InvoiceSetting,
          $$InvoiceSettingsTableFilterComposer,
          $$InvoiceSettingsTableOrderingComposer,
          $$InvoiceSettingsTableAnnotationComposer,
          $$InvoiceSettingsTableCreateCompanionBuilder,
          $$InvoiceSettingsTableUpdateCompanionBuilder,
          (
            InvoiceSetting,
            BaseReferences<
              _$AppDatabase,
              $InvoiceSettingsTable,
              InvoiceSetting
            >,
          ),
          InvoiceSetting,
          PrefetchHooks Function()
        > {
  $$InvoiceSettingsTableTableManager(
    _$AppDatabase db,
    $InvoiceSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> yardId = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> bankDetails = const Value.absent(),
                Value<String?> paymentTerms = const Value.absent(),
                Value<int?> billingDay = const Value.absent(),
                Value<int> cutoffBuffer = const Value.absent(),
                Value<String?> primaryColor = const Value.absent(),
                Value<String?> secondaryColor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => InvoiceSettingsCompanion(
                id: id,
                yardId: yardId,
                logoUrl: logoUrl,
                bankDetails: bankDetails,
                paymentTerms: paymentTerms,
                billingDay: billingDay,
                cutoffBuffer: cutoffBuffer,
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String yardId,
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> bankDetails = const Value.absent(),
                Value<String?> paymentTerms = const Value.absent(),
                Value<int?> billingDay = const Value.absent(),
                Value<int> cutoffBuffer = const Value.absent(),
                Value<String?> primaryColor = const Value.absent(),
                Value<String?> secondaryColor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => InvoiceSettingsCompanion.insert(
                id: id,
                yardId: yardId,
                logoUrl: logoUrl,
                bankDetails: bankDetails,
                paymentTerms: paymentTerms,
                billingDay: billingDay,
                cutoffBuffer: cutoffBuffer,
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InvoiceSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoiceSettingsTable,
      InvoiceSetting,
      $$InvoiceSettingsTableFilterComposer,
      $$InvoiceSettingsTableOrderingComposer,
      $$InvoiceSettingsTableAnnotationComposer,
      $$InvoiceSettingsTableCreateCompanionBuilder,
      $$InvoiceSettingsTableUpdateCompanionBuilder,
      (
        InvoiceSetting,
        BaseReferences<_$AppDatabase, $InvoiceSettingsTable, InvoiceSetting>,
      ),
      InvoiceSetting,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      required String id,
      required String targetTable,
      required String operation,
      Value<String?> recordId,
      required String payloadJson,
      Value<DateTime> createdAt,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<String?> groupId,
      Value<int> rowid,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<String> id,
      Value<String> targetTable,
      Value<String> operation,
      Value<String?> recordId,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<String?> groupId,
      Value<int> rowid,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
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

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
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

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String?> recordId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                targetTable: targetTable,
                operation: operation,
                recordId: recordId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                status: status,
                retryCount: retryCount,
                lastError: lastError,
                groupId: groupId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String targetTable,
                required String operation,
                Value<String?> recordId = const Value.absent(),
                required String payloadJson,
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                targetTable: targetTable,
                operation: operation,
                recordId: recordId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                status: status,
                retryCount: retryCount,
                lastError: lastError,
                groupId: groupId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;
typedef $$YardAccessRequestsTableCreateCompanionBuilder =
    YardAccessRequestsCompanion Function({
      required String id,
      required String yardId,
      required String userId,
      Value<String> status,
      Value<String?> message,
      Value<String?> reviewedBy,
      Value<DateTime?> reviewedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$YardAccessRequestsTableUpdateCompanionBuilder =
    YardAccessRequestsCompanion Function({
      Value<String> id,
      Value<String> yardId,
      Value<String> userId,
      Value<String> status,
      Value<String?> message,
      Value<String?> reviewedBy,
      Value<DateTime?> reviewedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$YardAccessRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $YardAccessRequestsTable> {
  $$YardAccessRequestsTableFilterComposer({
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

  ColumnFilters<String> get yardId => $composableBuilder(
    column: $table.yardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewedBy => $composableBuilder(
    column: $table.reviewedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$YardAccessRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $YardAccessRequestsTable> {
  $$YardAccessRequestsTableOrderingComposer({
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

  ColumnOrderings<String> get yardId => $composableBuilder(
    column: $table.yardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewedBy => $composableBuilder(
    column: $table.reviewedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$YardAccessRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $YardAccessRequestsTable> {
  $$YardAccessRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get yardId =>
      $composableBuilder(column: $table.yardId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get reviewedBy => $composableBuilder(
    column: $table.reviewedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$YardAccessRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $YardAccessRequestsTable,
          YardAccessRequest,
          $$YardAccessRequestsTableFilterComposer,
          $$YardAccessRequestsTableOrderingComposer,
          $$YardAccessRequestsTableAnnotationComposer,
          $$YardAccessRequestsTableCreateCompanionBuilder,
          $$YardAccessRequestsTableUpdateCompanionBuilder,
          (
            YardAccessRequest,
            BaseReferences<
              _$AppDatabase,
              $YardAccessRequestsTable,
              YardAccessRequest
            >,
          ),
          YardAccessRequest,
          PrefetchHooks Function()
        > {
  $$YardAccessRequestsTableTableManager(
    _$AppDatabase db,
    $YardAccessRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$YardAccessRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$YardAccessRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$YardAccessRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> yardId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<String?> reviewedBy = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => YardAccessRequestsCompanion(
                id: id,
                yardId: yardId,
                userId: userId,
                status: status,
                message: message,
                reviewedBy: reviewedBy,
                reviewedAt: reviewedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String yardId,
                required String userId,
                Value<String> status = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<String?> reviewedBy = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => YardAccessRequestsCompanion.insert(
                id: id,
                yardId: yardId,
                userId: userId,
                status: status,
                message: message,
                reviewedBy: reviewedBy,
                reviewedAt: reviewedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$YardAccessRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $YardAccessRequestsTable,
      YardAccessRequest,
      $$YardAccessRequestsTableFilterComposer,
      $$YardAccessRequestsTableOrderingComposer,
      $$YardAccessRequestsTableAnnotationComposer,
      $$YardAccessRequestsTableCreateCompanionBuilder,
      $$YardAccessRequestsTableUpdateCompanionBuilder,
      (
        YardAccessRequest,
        BaseReferences<
          _$AppDatabase,
          $YardAccessRequestsTable,
          YardAccessRequest
        >,
      ),
      YardAccessRequest,
      PrefetchHooks Function()
    >;
typedef $$HorsesTableCreateCompanionBuilder =
    HorsesCompanion Function({
      required String id,
      required String ownerId,
      required String name,
      Value<String?> breed,
      Value<String?> color,
      Value<int?> age,
      Value<String?> gender,
      Value<String?> stableNumber,
      Value<String?> photoUrl,
      Value<String?> dietNotes,
      Value<String?> careInstructions,
      Value<String?> feedInstructions,
      Value<String?> medicalNotes,
      Value<String?> vetName,
      Value<String?> vetPhone,
      Value<String?> farrierName,
      Value<String?> farrierPhone,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$HorsesTableUpdateCompanionBuilder =
    HorsesCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> name,
      Value<String?> breed,
      Value<String?> color,
      Value<int?> age,
      Value<String?> gender,
      Value<String?> stableNumber,
      Value<String?> photoUrl,
      Value<String?> dietNotes,
      Value<String?> careInstructions,
      Value<String?> feedInstructions,
      Value<String?> medicalNotes,
      Value<String?> vetName,
      Value<String?> vetPhone,
      Value<String?> farrierName,
      Value<String?> farrierPhone,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$HorsesTableFilterComposer
    extends Composer<_$AppDatabase, $HorsesTable> {
  $$HorsesTableFilterComposer({
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

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stableNumber => $composableBuilder(
    column: $table.stableNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dietNotes => $composableBuilder(
    column: $table.dietNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get careInstructions => $composableBuilder(
    column: $table.careInstructions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedInstructions => $composableBuilder(
    column: $table.feedInstructions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicalNotes => $composableBuilder(
    column: $table.medicalNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vetName => $composableBuilder(
    column: $table.vetName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vetPhone => $composableBuilder(
    column: $table.vetPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farrierName => $composableBuilder(
    column: $table.farrierName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farrierPhone => $composableBuilder(
    column: $table.farrierPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HorsesTableOrderingComposer
    extends Composer<_$AppDatabase, $HorsesTable> {
  $$HorsesTableOrderingComposer({
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

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stableNumber => $composableBuilder(
    column: $table.stableNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dietNotes => $composableBuilder(
    column: $table.dietNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get careInstructions => $composableBuilder(
    column: $table.careInstructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedInstructions => $composableBuilder(
    column: $table.feedInstructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicalNotes => $composableBuilder(
    column: $table.medicalNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vetName => $composableBuilder(
    column: $table.vetName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vetPhone => $composableBuilder(
    column: $table.vetPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farrierName => $composableBuilder(
    column: $table.farrierName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farrierPhone => $composableBuilder(
    column: $table.farrierPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HorsesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HorsesTable> {
  $$HorsesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get stableNumber => $composableBuilder(
    column: $table.stableNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get dietNotes =>
      $composableBuilder(column: $table.dietNotes, builder: (column) => column);

  GeneratedColumn<String> get careInstructions => $composableBuilder(
    column: $table.careInstructions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feedInstructions => $composableBuilder(
    column: $table.feedInstructions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get medicalNotes => $composableBuilder(
    column: $table.medicalNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vetName =>
      $composableBuilder(column: $table.vetName, builder: (column) => column);

  GeneratedColumn<String> get vetPhone =>
      $composableBuilder(column: $table.vetPhone, builder: (column) => column);

  GeneratedColumn<String> get farrierName => $composableBuilder(
    column: $table.farrierName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get farrierPhone => $composableBuilder(
    column: $table.farrierPhone,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HorsesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HorsesTable,
          Horse,
          $$HorsesTableFilterComposer,
          $$HorsesTableOrderingComposer,
          $$HorsesTableAnnotationComposer,
          $$HorsesTableCreateCompanionBuilder,
          $$HorsesTableUpdateCompanionBuilder,
          (Horse, BaseReferences<_$AppDatabase, $HorsesTable, Horse>),
          Horse,
          PrefetchHooks Function()
        > {
  $$HorsesTableTableManager(_$AppDatabase db, $HorsesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HorsesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HorsesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HorsesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> breed = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> stableNumber = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> dietNotes = const Value.absent(),
                Value<String?> careInstructions = const Value.absent(),
                Value<String?> feedInstructions = const Value.absent(),
                Value<String?> medicalNotes = const Value.absent(),
                Value<String?> vetName = const Value.absent(),
                Value<String?> vetPhone = const Value.absent(),
                Value<String?> farrierName = const Value.absent(),
                Value<String?> farrierPhone = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HorsesCompanion(
                id: id,
                ownerId: ownerId,
                name: name,
                breed: breed,
                color: color,
                age: age,
                gender: gender,
                stableNumber: stableNumber,
                photoUrl: photoUrl,
                dietNotes: dietNotes,
                careInstructions: careInstructions,
                feedInstructions: feedInstructions,
                medicalNotes: medicalNotes,
                vetName: vetName,
                vetPhone: vetPhone,
                farrierName: farrierName,
                farrierPhone: farrierPhone,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String name,
                Value<String?> breed = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> stableNumber = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> dietNotes = const Value.absent(),
                Value<String?> careInstructions = const Value.absent(),
                Value<String?> feedInstructions = const Value.absent(),
                Value<String?> medicalNotes = const Value.absent(),
                Value<String?> vetName = const Value.absent(),
                Value<String?> vetPhone = const Value.absent(),
                Value<String?> farrierName = const Value.absent(),
                Value<String?> farrierPhone = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HorsesCompanion.insert(
                id: id,
                ownerId: ownerId,
                name: name,
                breed: breed,
                color: color,
                age: age,
                gender: gender,
                stableNumber: stableNumber,
                photoUrl: photoUrl,
                dietNotes: dietNotes,
                careInstructions: careInstructions,
                feedInstructions: feedInstructions,
                medicalNotes: medicalNotes,
                vetName: vetName,
                vetPhone: vetPhone,
                farrierName: farrierName,
                farrierPhone: farrierPhone,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HorsesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HorsesTable,
      Horse,
      $$HorsesTableFilterComposer,
      $$HorsesTableOrderingComposer,
      $$HorsesTableAnnotationComposer,
      $$HorsesTableCreateCompanionBuilder,
      $$HorsesTableUpdateCompanionBuilder,
      (Horse, BaseReferences<_$AppDatabase, $HorsesTable, Horse>),
      Horse,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$YardsTableTableManager get yards =>
      $$YardsTableTableManager(_db, _db.yards);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$ConsumableTypesTableTableManager get consumableTypes =>
      $$ConsumableTypesTableTableManager(_db, _db.consumableTypes);
  $$LiveryPackagesTableTableManager get liveryPackages =>
      $$LiveryPackagesTableTableManager(_db, _db.liveryPackages);
  $$InvoiceSettingsTableTableManager get invoiceSettings =>
      $$InvoiceSettingsTableTableManager(_db, _db.invoiceSettings);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$YardAccessRequestsTableTableManager get yardAccessRequests =>
      $$YardAccessRequestsTableTableManager(_db, _db.yardAccessRequests);
  $$HorsesTableTableManager get horses =>
      $$HorsesTableTableManager(_db, _db.horses);
}
