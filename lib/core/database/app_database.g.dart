// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalUsersTable extends LocalUsers
    with TableInfo<$LocalUsersTable, LocalUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUsersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _fiftyThirtyTwentyNeedsMeta =
      const VerificationMeta('fiftyThirtyTwentyNeeds');
  @override
  late final GeneratedColumn<double> fiftyThirtyTwentyNeeds =
      GeneratedColumn<double>(
        'fifty_thirty_twenty_needs',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fiftyThirtyTwentyWantsMeta =
      const VerificationMeta('fiftyThirtyTwentyWants');
  @override
  late final GeneratedColumn<double> fiftyThirtyTwentyWants =
      GeneratedColumn<double>(
        'fifty_thirty_twenty_wants',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fiftyThirtyTwentySavingsMeta =
      const VerificationMeta('fiftyThirtyTwentySavings');
  @override
  late final GeneratedColumn<double> fiftyThirtyTwentySavings =
      GeneratedColumn<double>(
        'fifty_thirty_twenty_savings',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    email,
    photoUrl,
    createdAt,
    fiftyThirtyTwentyNeeds,
    fiftyThirtyTwentyWants,
    fiftyThirtyTwentySavings,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUser> instance, {
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
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
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
    if (data.containsKey('fifty_thirty_twenty_needs')) {
      context.handle(
        _fiftyThirtyTwentyNeedsMeta,
        fiftyThirtyTwentyNeeds.isAcceptableOrUnknown(
          data['fifty_thirty_twenty_needs']!,
          _fiftyThirtyTwentyNeedsMeta,
        ),
      );
    }
    if (data.containsKey('fifty_thirty_twenty_wants')) {
      context.handle(
        _fiftyThirtyTwentyWantsMeta,
        fiftyThirtyTwentyWants.isAcceptableOrUnknown(
          data['fifty_thirty_twenty_wants']!,
          _fiftyThirtyTwentyWantsMeta,
        ),
      );
    }
    if (data.containsKey('fifty_thirty_twenty_savings')) {
      context.handle(
        _fiftyThirtyTwentySavingsMeta,
        fiftyThirtyTwentySavings.isAcceptableOrUnknown(
          data['fifty_thirty_twenty_savings']!,
          _fiftyThirtyTwentySavingsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      fiftyThirtyTwentyNeeds: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fifty_thirty_twenty_needs'],
      ),
      fiftyThirtyTwentyWants: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fifty_thirty_twenty_wants'],
      ),
      fiftyThirtyTwentySavings: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fifty_thirty_twenty_savings'],
      ),
    );
  }

  @override
  $LocalUsersTable createAlias(String alias) {
    return $LocalUsersTable(attachedDatabase, alias);
  }
}

class LocalUser extends DataClass implements Insertable<LocalUser> {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final double? fiftyThirtyTwentyNeeds;
  final double? fiftyThirtyTwentyWants;
  final double? fiftyThirtyTwentySavings;
  const LocalUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.fiftyThirtyTwentyNeeds,
    this.fiftyThirtyTwentyWants,
    this.fiftyThirtyTwentySavings,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || fiftyThirtyTwentyNeeds != null) {
      map['fifty_thirty_twenty_needs'] = Variable<double>(
        fiftyThirtyTwentyNeeds,
      );
    }
    if (!nullToAbsent || fiftyThirtyTwentyWants != null) {
      map['fifty_thirty_twenty_wants'] = Variable<double>(
        fiftyThirtyTwentyWants,
      );
    }
    if (!nullToAbsent || fiftyThirtyTwentySavings != null) {
      map['fifty_thirty_twenty_savings'] = Variable<double>(
        fiftyThirtyTwentySavings,
      );
    }
    return map;
  }

  LocalUsersCompanion toCompanion(bool nullToAbsent) {
    return LocalUsersCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      createdAt: Value(createdAt),
      fiftyThirtyTwentyNeeds: fiftyThirtyTwentyNeeds == null && nullToAbsent
          ? const Value.absent()
          : Value(fiftyThirtyTwentyNeeds),
      fiftyThirtyTwentyWants: fiftyThirtyTwentyWants == null && nullToAbsent
          ? const Value.absent()
          : Value(fiftyThirtyTwentyWants),
      fiftyThirtyTwentySavings: fiftyThirtyTwentySavings == null && nullToAbsent
          ? const Value.absent()
          : Value(fiftyThirtyTwentySavings),
    );
  }

  factory LocalUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUser(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      fiftyThirtyTwentyNeeds: serializer.fromJson<double?>(
        json['fiftyThirtyTwentyNeeds'],
      ),
      fiftyThirtyTwentyWants: serializer.fromJson<double?>(
        json['fiftyThirtyTwentyWants'],
      ),
      fiftyThirtyTwentySavings: serializer.fromJson<double?>(
        json['fiftyThirtyTwentySavings'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'fiftyThirtyTwentyNeeds': serializer.toJson<double?>(
        fiftyThirtyTwentyNeeds,
      ),
      'fiftyThirtyTwentyWants': serializer.toJson<double?>(
        fiftyThirtyTwentyWants,
      ),
      'fiftyThirtyTwentySavings': serializer.toJson<double?>(
        fiftyThirtyTwentySavings,
      ),
    };
  }

  LocalUser copyWith({
    String? id,
    String? name,
    String? email,
    Value<String?> photoUrl = const Value.absent(),
    DateTime? createdAt,
    Value<double?> fiftyThirtyTwentyNeeds = const Value.absent(),
    Value<double?> fiftyThirtyTwentyWants = const Value.absent(),
    Value<double?> fiftyThirtyTwentySavings = const Value.absent(),
  }) => LocalUser(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    createdAt: createdAt ?? this.createdAt,
    fiftyThirtyTwentyNeeds: fiftyThirtyTwentyNeeds.present
        ? fiftyThirtyTwentyNeeds.value
        : this.fiftyThirtyTwentyNeeds,
    fiftyThirtyTwentyWants: fiftyThirtyTwentyWants.present
        ? fiftyThirtyTwentyWants.value
        : this.fiftyThirtyTwentyWants,
    fiftyThirtyTwentySavings: fiftyThirtyTwentySavings.present
        ? fiftyThirtyTwentySavings.value
        : this.fiftyThirtyTwentySavings,
  );
  LocalUser copyWithCompanion(LocalUsersCompanion data) {
    return LocalUser(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      fiftyThirtyTwentyNeeds: data.fiftyThirtyTwentyNeeds.present
          ? data.fiftyThirtyTwentyNeeds.value
          : this.fiftyThirtyTwentyNeeds,
      fiftyThirtyTwentyWants: data.fiftyThirtyTwentyWants.present
          ? data.fiftyThirtyTwentyWants.value
          : this.fiftyThirtyTwentyWants,
      fiftyThirtyTwentySavings: data.fiftyThirtyTwentySavings.present
          ? data.fiftyThirtyTwentySavings.value
          : this.fiftyThirtyTwentySavings,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUser(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('fiftyThirtyTwentyNeeds: $fiftyThirtyTwentyNeeds, ')
          ..write('fiftyThirtyTwentyWants: $fiftyThirtyTwentyWants, ')
          ..write('fiftyThirtyTwentySavings: $fiftyThirtyTwentySavings')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    email,
    photoUrl,
    createdAt,
    fiftyThirtyTwentyNeeds,
    fiftyThirtyTwentyWants,
    fiftyThirtyTwentySavings,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUser &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.photoUrl == this.photoUrl &&
          other.createdAt == this.createdAt &&
          other.fiftyThirtyTwentyNeeds == this.fiftyThirtyTwentyNeeds &&
          other.fiftyThirtyTwentyWants == this.fiftyThirtyTwentyWants &&
          other.fiftyThirtyTwentySavings == this.fiftyThirtyTwentySavings);
}

class LocalUsersCompanion extends UpdateCompanion<LocalUser> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String?> photoUrl;
  final Value<DateTime> createdAt;
  final Value<double?> fiftyThirtyTwentyNeeds;
  final Value<double?> fiftyThirtyTwentyWants;
  final Value<double?> fiftyThirtyTwentySavings;
  final Value<int> rowid;
  const LocalUsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.fiftyThirtyTwentyNeeds = const Value.absent(),
    this.fiftyThirtyTwentyWants = const Value.absent(),
    this.fiftyThirtyTwentySavings = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUsersCompanion.insert({
    required String id,
    required String name,
    required String email,
    this.photoUrl = const Value.absent(),
    required DateTime createdAt,
    this.fiftyThirtyTwentyNeeds = const Value.absent(),
    this.fiftyThirtyTwentyWants = const Value.absent(),
    this.fiftyThirtyTwentySavings = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       email = Value(email),
       createdAt = Value(createdAt);
  static Insertable<LocalUser> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? photoUrl,
    Expression<DateTime>? createdAt,
    Expression<double>? fiftyThirtyTwentyNeeds,
    Expression<double>? fiftyThirtyTwentyWants,
    Expression<double>? fiftyThirtyTwentySavings,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (fiftyThirtyTwentyNeeds != null)
        'fifty_thirty_twenty_needs': fiftyThirtyTwentyNeeds,
      if (fiftyThirtyTwentyWants != null)
        'fifty_thirty_twenty_wants': fiftyThirtyTwentyWants,
      if (fiftyThirtyTwentySavings != null)
        'fifty_thirty_twenty_savings': fiftyThirtyTwentySavings,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUsersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? email,
    Value<String?>? photoUrl,
    Value<DateTime>? createdAt,
    Value<double?>? fiftyThirtyTwentyNeeds,
    Value<double?>? fiftyThirtyTwentyWants,
    Value<double?>? fiftyThirtyTwentySavings,
    Value<int>? rowid,
  }) {
    return LocalUsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      fiftyThirtyTwentyNeeds:
          fiftyThirtyTwentyNeeds ?? this.fiftyThirtyTwentyNeeds,
      fiftyThirtyTwentyWants:
          fiftyThirtyTwentyWants ?? this.fiftyThirtyTwentyWants,
      fiftyThirtyTwentySavings:
          fiftyThirtyTwentySavings ?? this.fiftyThirtyTwentySavings,
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
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (fiftyThirtyTwentyNeeds.present) {
      map['fifty_thirty_twenty_needs'] = Variable<double>(
        fiftyThirtyTwentyNeeds.value,
      );
    }
    if (fiftyThirtyTwentyWants.present) {
      map['fifty_thirty_twenty_wants'] = Variable<double>(
        fiftyThirtyTwentyWants.value,
      );
    }
    if (fiftyThirtyTwentySavings.present) {
      map['fifty_thirty_twenty_savings'] = Variable<double>(
        fiftyThirtyTwentySavings.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('fiftyThirtyTwentyNeeds: $fiftyThirtyTwentyNeeds, ')
          ..write('fiftyThirtyTwentyWants: $fiftyThirtyTwentyWants, ')
          ..write('fiftyThirtyTwentySavings: $fiftyThirtyTwentySavings, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAccountsTable extends LocalAccounts
    with TableInfo<$LocalAccountsTable, LocalAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _bankMeta = const VerificationMeta('bank');
  @override
  late final GeneratedColumn<String> bank = GeneratedColumn<String>(
    'bank',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialBalanceMeta = const VerificationMeta(
    'initialBalance',
  );
  @override
  late final GeneratedColumn<double> initialBalance = GeneratedColumn<double>(
    'initial_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditLimitMeta = const VerificationMeta(
    'creditLimit',
  );
  @override
  late final GeneratedColumn<double> creditLimit = GeneratedColumn<double>(
    'credit_limit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closingDayMeta = const VerificationMeta(
    'closingDay',
  );
  @override
  late final GeneratedColumn<int> closingDay = GeneratedColumn<int>(
    'closing_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<int> dueDay = GeneratedColumn<int>(
    'due_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedAccountIdMeta = const VerificationMeta(
    'linkedAccountId',
  );
  @override
  late final GeneratedColumn<String> linkedAccountId = GeneratedColumn<String>(
    'linked_account_id',
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
    userId,
    name,
    type,
    bank,
    initialBalance,
    creditLimit,
    closingDay,
    dueDay,
    linkedAccountId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('bank')) {
      context.handle(
        _bankMeta,
        bank.isAcceptableOrUnknown(data['bank']!, _bankMeta),
      );
    } else if (isInserting) {
      context.missing(_bankMeta);
    }
    if (data.containsKey('initial_balance')) {
      context.handle(
        _initialBalanceMeta,
        initialBalance.isAcceptableOrUnknown(
          data['initial_balance']!,
          _initialBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialBalanceMeta);
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
        _creditLimitMeta,
        creditLimit.isAcceptableOrUnknown(
          data['credit_limit']!,
          _creditLimitMeta,
        ),
      );
    }
    if (data.containsKey('closing_day')) {
      context.handle(
        _closingDayMeta,
        closingDay.isAcceptableOrUnknown(data['closing_day']!, _closingDayMeta),
      );
    }
    if (data.containsKey('due_day')) {
      context.handle(
        _dueDayMeta,
        dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta),
      );
    }
    if (data.containsKey('linked_account_id')) {
      context.handle(
        _linkedAccountIdMeta,
        linkedAccountId.isAcceptableOrUnknown(
          data['linked_account_id']!,
          _linkedAccountIdMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      bank: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank'],
      )!,
      initialBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}initial_balance'],
      )!,
      creditLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit_limit'],
      ),
      closingDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closing_day'],
      ),
      dueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_day'],
      ),
      linkedAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_account_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalAccountsTable createAlias(String alias) {
    return $LocalAccountsTable(attachedDatabase, alias);
  }
}

class LocalAccount extends DataClass implements Insertable<LocalAccount> {
  final String id;
  final String userId;
  final String name;
  final String type;
  final String bank;
  final double initialBalance;
  final double? creditLimit;
  final int? closingDay;
  final int? dueDay;
  final String? linkedAccountId;
  final DateTime createdAt;
  const LocalAccount({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.bank,
    required this.initialBalance,
    this.creditLimit,
    this.closingDay,
    this.dueDay,
    this.linkedAccountId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['bank'] = Variable<String>(bank);
    map['initial_balance'] = Variable<double>(initialBalance);
    if (!nullToAbsent || creditLimit != null) {
      map['credit_limit'] = Variable<double>(creditLimit);
    }
    if (!nullToAbsent || closingDay != null) {
      map['closing_day'] = Variable<int>(closingDay);
    }
    if (!nullToAbsent || dueDay != null) {
      map['due_day'] = Variable<int>(dueDay);
    }
    if (!nullToAbsent || linkedAccountId != null) {
      map['linked_account_id'] = Variable<String>(linkedAccountId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalAccountsCompanion toCompanion(bool nullToAbsent) {
    return LocalAccountsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      type: Value(type),
      bank: Value(bank),
      initialBalance: Value(initialBalance),
      creditLimit: creditLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimit),
      closingDay: closingDay == null && nullToAbsent
          ? const Value.absent()
          : Value(closingDay),
      dueDay: dueDay == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDay),
      linkedAccountId: linkedAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedAccountId),
      createdAt: Value(createdAt),
    );
  }

  factory LocalAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAccount(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      bank: serializer.fromJson<String>(json['bank']),
      initialBalance: serializer.fromJson<double>(json['initialBalance']),
      creditLimit: serializer.fromJson<double?>(json['creditLimit']),
      closingDay: serializer.fromJson<int?>(json['closingDay']),
      dueDay: serializer.fromJson<int?>(json['dueDay']),
      linkedAccountId: serializer.fromJson<String?>(json['linkedAccountId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'bank': serializer.toJson<String>(bank),
      'initialBalance': serializer.toJson<double>(initialBalance),
      'creditLimit': serializer.toJson<double?>(creditLimit),
      'closingDay': serializer.toJson<int?>(closingDay),
      'dueDay': serializer.toJson<int?>(dueDay),
      'linkedAccountId': serializer.toJson<String?>(linkedAccountId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalAccount copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? bank,
    double? initialBalance,
    Value<double?> creditLimit = const Value.absent(),
    Value<int?> closingDay = const Value.absent(),
    Value<int?> dueDay = const Value.absent(),
    Value<String?> linkedAccountId = const Value.absent(),
    DateTime? createdAt,
  }) => LocalAccount(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    type: type ?? this.type,
    bank: bank ?? this.bank,
    initialBalance: initialBalance ?? this.initialBalance,
    creditLimit: creditLimit.present ? creditLimit.value : this.creditLimit,
    closingDay: closingDay.present ? closingDay.value : this.closingDay,
    dueDay: dueDay.present ? dueDay.value : this.dueDay,
    linkedAccountId: linkedAccountId.present
        ? linkedAccountId.value
        : this.linkedAccountId,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalAccount copyWithCompanion(LocalAccountsCompanion data) {
    return LocalAccount(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      bank: data.bank.present ? data.bank.value : this.bank,
      initialBalance: data.initialBalance.present
          ? data.initialBalance.value
          : this.initialBalance,
      creditLimit: data.creditLimit.present
          ? data.creditLimit.value
          : this.creditLimit,
      closingDay: data.closingDay.present
          ? data.closingDay.value
          : this.closingDay,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
      linkedAccountId: data.linkedAccountId.present
          ? data.linkedAccountId.value
          : this.linkedAccountId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccount(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('bank: $bank, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('closingDay: $closingDay, ')
          ..write('dueDay: $dueDay, ')
          ..write('linkedAccountId: $linkedAccountId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    type,
    bank,
    initialBalance,
    creditLimit,
    closingDay,
    dueDay,
    linkedAccountId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAccount &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.type == this.type &&
          other.bank == this.bank &&
          other.initialBalance == this.initialBalance &&
          other.creditLimit == this.creditLimit &&
          other.closingDay == this.closingDay &&
          other.dueDay == this.dueDay &&
          other.linkedAccountId == this.linkedAccountId &&
          other.createdAt == this.createdAt);
}

class LocalAccountsCompanion extends UpdateCompanion<LocalAccount> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> type;
  final Value<String> bank;
  final Value<double> initialBalance;
  final Value<double?> creditLimit;
  final Value<int?> closingDay;
  final Value<int?> dueDay;
  final Value<String?> linkedAccountId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalAccountsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.bank = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.closingDay = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.linkedAccountId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAccountsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required String type,
    required String bank,
    required double initialBalance,
    this.creditLimit = const Value.absent(),
    this.closingDay = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.linkedAccountId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       type = Value(type),
       bank = Value(bank),
       initialBalance = Value(initialBalance),
       createdAt = Value(createdAt);
  static Insertable<LocalAccount> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? bank,
    Expression<double>? initialBalance,
    Expression<double>? creditLimit,
    Expression<int>? closingDay,
    Expression<int>? dueDay,
    Expression<String>? linkedAccountId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (bank != null) 'bank': bank,
      if (initialBalance != null) 'initial_balance': initialBalance,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (closingDay != null) 'closing_day': closingDay,
      if (dueDay != null) 'due_day': dueDay,
      if (linkedAccountId != null) 'linked_account_id': linkedAccountId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String>? type,
    Value<String>? bank,
    Value<double>? initialBalance,
    Value<double?>? creditLimit,
    Value<int?>? closingDay,
    Value<int?>? dueDay,
    Value<String?>? linkedAccountId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalAccountsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      bank: bank ?? this.bank,
      initialBalance: initialBalance ?? this.initialBalance,
      creditLimit: creditLimit ?? this.creditLimit,
      closingDay: closingDay ?? this.closingDay,
      dueDay: dueDay ?? this.dueDay,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (bank.present) {
      map['bank'] = Variable<String>(bank.value);
    }
    if (initialBalance.present) {
      map['initial_balance'] = Variable<double>(initialBalance.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (closingDay.present) {
      map['closing_day'] = Variable<int>(closingDay.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<int>(dueDay.value);
    }
    if (linkedAccountId.present) {
      map['linked_account_id'] = Variable<String>(linkedAccountId.value);
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
    return (StringBuffer('LocalAccountsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('bank: $bank, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('closingDay: $closingDay, ')
          ..write('dueDay: $dueDay, ')
          ..write('linkedAccountId: $linkedAccountId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTransactionsTable extends LocalTransactions
    with TableInfo<$LocalTransactionsTable, LocalTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _settlementStatusMeta = const VerificationMeta(
    'settlementStatus',
  );
  @override
  late final GeneratedColumn<String> settlementStatus = GeneratedColumn<String>(
    'settlement_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('paid'),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _settledAtMeta = const VerificationMeta(
    'settledAt',
  );
  @override
  late final GeneratedColumn<DateTime> settledAt = GeneratedColumn<DateTime>(
    'settled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceMeta = const VerificationMeta(
    'recurrence',
  );
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
    'recurrence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('single'),
  );
  static const VerificationMeta _recurrenceGroupIdMeta = const VerificationMeta(
    'recurrenceGroupId',
  );
  @override
  late final GeneratedColumn<String> recurrenceGroupId =
      GeneratedColumn<String>(
        'recurrence_group_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurrenceIntervalMonthsMeta =
      const VerificationMeta('recurrenceIntervalMonths');
  @override
  late final GeneratedColumn<int> recurrenceIntervalMonths =
      GeneratedColumn<int>(
        'recurrence_interval_months',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(1),
      );
  static const VerificationMeta _recurrenceIndexMeta = const VerificationMeta(
    'recurrenceIndex',
  );
  @override
  late final GeneratedColumn<int> recurrenceIndex = GeneratedColumn<int>(
    'recurrence_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceTotalMeta = const VerificationMeta(
    'recurrenceTotal',
  );
  @override
  late final GeneratedColumn<int> recurrenceTotal = GeneratedColumn<int>(
    'recurrence_total',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceBaseDescriptionMeta =
      const VerificationMeta('recurrenceBaseDescription');
  @override
  late final GeneratedColumn<String> recurrenceBaseDescription =
      GeneratedColumn<String>(
        'recurrence_base_description',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurrenceEndDateMeta = const VerificationMeta(
    'recurrenceEndDate',
  );
  @override
  late final GeneratedColumn<DateTime> recurrenceEndDate =
      GeneratedColumn<DateTime>(
        'recurrence_end_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
  static const VerificationMeta _linkedTransactionIdMeta =
      const VerificationMeta('linkedTransactionId');
  @override
  late final GeneratedColumn<String> linkedTransactionId =
      GeneratedColumn<String>(
        'linked_transaction_id',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    accountId,
    categoryId,
    type,
    amount,
    description,
    date,
    settlementStatus,
    dueDate,
    settledAt,
    recurrence,
    recurrenceGroupId,
    recurrenceIntervalMonths,
    recurrenceIndex,
    recurrenceTotal,
    recurrenceBaseDescription,
    recurrenceEndDate,
    notes,
    linkedTransactionId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('settlement_status')) {
      context.handle(
        _settlementStatusMeta,
        settlementStatus.isAcceptableOrUnknown(
          data['settlement_status']!,
          _settlementStatusMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('settled_at')) {
      context.handle(
        _settledAtMeta,
        settledAt.isAcceptableOrUnknown(data['settled_at']!, _settledAtMeta),
      );
    }
    if (data.containsKey('recurrence')) {
      context.handle(
        _recurrenceMeta,
        recurrence.isAcceptableOrUnknown(data['recurrence']!, _recurrenceMeta),
      );
    }
    if (data.containsKey('recurrence_group_id')) {
      context.handle(
        _recurrenceGroupIdMeta,
        recurrenceGroupId.isAcceptableOrUnknown(
          data['recurrence_group_id']!,
          _recurrenceGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_interval_months')) {
      context.handle(
        _recurrenceIntervalMonthsMeta,
        recurrenceIntervalMonths.isAcceptableOrUnknown(
          data['recurrence_interval_months']!,
          _recurrenceIntervalMonthsMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_index')) {
      context.handle(
        _recurrenceIndexMeta,
        recurrenceIndex.isAcceptableOrUnknown(
          data['recurrence_index']!,
          _recurrenceIndexMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_total')) {
      context.handle(
        _recurrenceTotalMeta,
        recurrenceTotal.isAcceptableOrUnknown(
          data['recurrence_total']!,
          _recurrenceTotalMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_base_description')) {
      context.handle(
        _recurrenceBaseDescriptionMeta,
        recurrenceBaseDescription.isAcceptableOrUnknown(
          data['recurrence_base_description']!,
          _recurrenceBaseDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_end_date')) {
      context.handle(
        _recurrenceEndDateMeta,
        recurrenceEndDate.isAcceptableOrUnknown(
          data['recurrence_end_date']!,
          _recurrenceEndDateMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('linked_transaction_id')) {
      context.handle(
        _linkedTransactionIdMeta,
        linkedTransactionId.isAcceptableOrUnknown(
          data['linked_transaction_id']!,
          _linkedTransactionIdMeta,
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      settlementStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settlement_status'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      settledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}settled_at'],
      ),
      recurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence'],
      )!,
      recurrenceGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_group_id'],
      ),
      recurrenceIntervalMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurrence_interval_months'],
      )!,
      recurrenceIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurrence_index'],
      ),
      recurrenceTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurrence_total'],
      ),
      recurrenceBaseDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_base_description'],
      ),
      recurrenceEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recurrence_end_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      linkedTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_transaction_id'],
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
  $LocalTransactionsTable createAlias(String alias) {
    return $LocalTransactionsTable(attachedDatabase, alias);
  }
}

class LocalTransaction extends DataClass
    implements Insertable<LocalTransaction> {
  final String id;
  final String userId;
  final String accountId;
  final String categoryId;
  final String type;
  final double amount;
  final String description;
  final DateTime date;
  final String settlementStatus;
  final DateTime? dueDate;
  final DateTime? settledAt;
  final String recurrence;
  final String? recurrenceGroupId;
  final int recurrenceIntervalMonths;
  final int? recurrenceIndex;
  final int? recurrenceTotal;
  final String? recurrenceBaseDescription;
  final DateTime? recurrenceEndDate;
  final String? notes;
  final String? linkedTransactionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalTransaction({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.settlementStatus,
    this.dueDate,
    this.settledAt,
    required this.recurrence,
    this.recurrenceGroupId,
    required this.recurrenceIntervalMonths,
    this.recurrenceIndex,
    this.recurrenceTotal,
    this.recurrenceBaseDescription,
    this.recurrenceEndDate,
    this.notes,
    this.linkedTransactionId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['account_id'] = Variable<String>(accountId);
    map['category_id'] = Variable<String>(categoryId);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    map['description'] = Variable<String>(description);
    map['date'] = Variable<DateTime>(date);
    map['settlement_status'] = Variable<String>(settlementStatus);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || settledAt != null) {
      map['settled_at'] = Variable<DateTime>(settledAt);
    }
    map['recurrence'] = Variable<String>(recurrence);
    if (!nullToAbsent || recurrenceGroupId != null) {
      map['recurrence_group_id'] = Variable<String>(recurrenceGroupId);
    }
    map['recurrence_interval_months'] = Variable<int>(recurrenceIntervalMonths);
    if (!nullToAbsent || recurrenceIndex != null) {
      map['recurrence_index'] = Variable<int>(recurrenceIndex);
    }
    if (!nullToAbsent || recurrenceTotal != null) {
      map['recurrence_total'] = Variable<int>(recurrenceTotal);
    }
    if (!nullToAbsent || recurrenceBaseDescription != null) {
      map['recurrence_base_description'] = Variable<String>(
        recurrenceBaseDescription,
      );
    }
    if (!nullToAbsent || recurrenceEndDate != null) {
      map['recurrence_end_date'] = Variable<DateTime>(recurrenceEndDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || linkedTransactionId != null) {
      map['linked_transaction_id'] = Variable<String>(linkedTransactionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalTransactionsCompanion toCompanion(bool nullToAbsent) {
    return LocalTransactionsCompanion(
      id: Value(id),
      userId: Value(userId),
      accountId: Value(accountId),
      categoryId: Value(categoryId),
      type: Value(type),
      amount: Value(amount),
      description: Value(description),
      date: Value(date),
      settlementStatus: Value(settlementStatus),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      settledAt: settledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(settledAt),
      recurrence: Value(recurrence),
      recurrenceGroupId: recurrenceGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceGroupId),
      recurrenceIntervalMonths: Value(recurrenceIntervalMonths),
      recurrenceIndex: recurrenceIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceIndex),
      recurrenceTotal: recurrenceTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceTotal),
      recurrenceBaseDescription:
          recurrenceBaseDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceBaseDescription),
      recurrenceEndDate: recurrenceEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceEndDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      linkedTransactionId: linkedTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedTransactionId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTransaction(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String>(json['description']),
      date: serializer.fromJson<DateTime>(json['date']),
      settlementStatus: serializer.fromJson<String>(json['settlementStatus']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      settledAt: serializer.fromJson<DateTime?>(json['settledAt']),
      recurrence: serializer.fromJson<String>(json['recurrence']),
      recurrenceGroupId: serializer.fromJson<String?>(
        json['recurrenceGroupId'],
      ),
      recurrenceIntervalMonths: serializer.fromJson<int>(
        json['recurrenceIntervalMonths'],
      ),
      recurrenceIndex: serializer.fromJson<int?>(json['recurrenceIndex']),
      recurrenceTotal: serializer.fromJson<int?>(json['recurrenceTotal']),
      recurrenceBaseDescription: serializer.fromJson<String?>(
        json['recurrenceBaseDescription'],
      ),
      recurrenceEndDate: serializer.fromJson<DateTime?>(
        json['recurrenceEndDate'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      linkedTransactionId: serializer.fromJson<String?>(
        json['linkedTransactionId'],
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
      'userId': serializer.toJson<String>(userId),
      'accountId': serializer.toJson<String>(accountId),
      'categoryId': serializer.toJson<String>(categoryId),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String>(description),
      'date': serializer.toJson<DateTime>(date),
      'settlementStatus': serializer.toJson<String>(settlementStatus),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'settledAt': serializer.toJson<DateTime?>(settledAt),
      'recurrence': serializer.toJson<String>(recurrence),
      'recurrenceGroupId': serializer.toJson<String?>(recurrenceGroupId),
      'recurrenceIntervalMonths': serializer.toJson<int>(
        recurrenceIntervalMonths,
      ),
      'recurrenceIndex': serializer.toJson<int?>(recurrenceIndex),
      'recurrenceTotal': serializer.toJson<int?>(recurrenceTotal),
      'recurrenceBaseDescription': serializer.toJson<String?>(
        recurrenceBaseDescription,
      ),
      'recurrenceEndDate': serializer.toJson<DateTime?>(recurrenceEndDate),
      'notes': serializer.toJson<String?>(notes),
      'linkedTransactionId': serializer.toJson<String?>(linkedTransactionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalTransaction copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? categoryId,
    String? type,
    double? amount,
    String? description,
    DateTime? date,
    String? settlementStatus,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<DateTime?> settledAt = const Value.absent(),
    String? recurrence,
    Value<String?> recurrenceGroupId = const Value.absent(),
    int? recurrenceIntervalMonths,
    Value<int?> recurrenceIndex = const Value.absent(),
    Value<int?> recurrenceTotal = const Value.absent(),
    Value<String?> recurrenceBaseDescription = const Value.absent(),
    Value<DateTime?> recurrenceEndDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> linkedTransactionId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalTransaction(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    accountId: accountId ?? this.accountId,
    categoryId: categoryId ?? this.categoryId,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    date: date ?? this.date,
    settlementStatus: settlementStatus ?? this.settlementStatus,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    settledAt: settledAt.present ? settledAt.value : this.settledAt,
    recurrence: recurrence ?? this.recurrence,
    recurrenceGroupId: recurrenceGroupId.present
        ? recurrenceGroupId.value
        : this.recurrenceGroupId,
    recurrenceIntervalMonths:
        recurrenceIntervalMonths ?? this.recurrenceIntervalMonths,
    recurrenceIndex: recurrenceIndex.present
        ? recurrenceIndex.value
        : this.recurrenceIndex,
    recurrenceTotal: recurrenceTotal.present
        ? recurrenceTotal.value
        : this.recurrenceTotal,
    recurrenceBaseDescription: recurrenceBaseDescription.present
        ? recurrenceBaseDescription.value
        : this.recurrenceBaseDescription,
    recurrenceEndDate: recurrenceEndDate.present
        ? recurrenceEndDate.value
        : this.recurrenceEndDate,
    notes: notes.present ? notes.value : this.notes,
    linkedTransactionId: linkedTransactionId.present
        ? linkedTransactionId.value
        : this.linkedTransactionId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalTransaction copyWithCompanion(LocalTransactionsCompanion data) {
    return LocalTransaction(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      description: data.description.present
          ? data.description.value
          : this.description,
      date: data.date.present ? data.date.value : this.date,
      settlementStatus: data.settlementStatus.present
          ? data.settlementStatus.value
          : this.settlementStatus,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      settledAt: data.settledAt.present ? data.settledAt.value : this.settledAt,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      recurrenceGroupId: data.recurrenceGroupId.present
          ? data.recurrenceGroupId.value
          : this.recurrenceGroupId,
      recurrenceIntervalMonths: data.recurrenceIntervalMonths.present
          ? data.recurrenceIntervalMonths.value
          : this.recurrenceIntervalMonths,
      recurrenceIndex: data.recurrenceIndex.present
          ? data.recurrenceIndex.value
          : this.recurrenceIndex,
      recurrenceTotal: data.recurrenceTotal.present
          ? data.recurrenceTotal.value
          : this.recurrenceTotal,
      recurrenceBaseDescription: data.recurrenceBaseDescription.present
          ? data.recurrenceBaseDescription.value
          : this.recurrenceBaseDescription,
      recurrenceEndDate: data.recurrenceEndDate.present
          ? data.recurrenceEndDate.value
          : this.recurrenceEndDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      linkedTransactionId: data.linkedTransactionId.present
          ? data.linkedTransactionId.value
          : this.linkedTransactionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransaction(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('settlementStatus: $settlementStatus, ')
          ..write('dueDate: $dueDate, ')
          ..write('settledAt: $settledAt, ')
          ..write('recurrence: $recurrence, ')
          ..write('recurrenceGroupId: $recurrenceGroupId, ')
          ..write('recurrenceIntervalMonths: $recurrenceIntervalMonths, ')
          ..write('recurrenceIndex: $recurrenceIndex, ')
          ..write('recurrenceTotal: $recurrenceTotal, ')
          ..write('recurrenceBaseDescription: $recurrenceBaseDescription, ')
          ..write('recurrenceEndDate: $recurrenceEndDate, ')
          ..write('notes: $notes, ')
          ..write('linkedTransactionId: $linkedTransactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    accountId,
    categoryId,
    type,
    amount,
    description,
    date,
    settlementStatus,
    dueDate,
    settledAt,
    recurrence,
    recurrenceGroupId,
    recurrenceIntervalMonths,
    recurrenceIndex,
    recurrenceTotal,
    recurrenceBaseDescription,
    recurrenceEndDate,
    notes,
    linkedTransactionId,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTransaction &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.accountId == this.accountId &&
          other.categoryId == this.categoryId &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.date == this.date &&
          other.settlementStatus == this.settlementStatus &&
          other.dueDate == this.dueDate &&
          other.settledAt == this.settledAt &&
          other.recurrence == this.recurrence &&
          other.recurrenceGroupId == this.recurrenceGroupId &&
          other.recurrenceIntervalMonths == this.recurrenceIntervalMonths &&
          other.recurrenceIndex == this.recurrenceIndex &&
          other.recurrenceTotal == this.recurrenceTotal &&
          other.recurrenceBaseDescription == this.recurrenceBaseDescription &&
          other.recurrenceEndDate == this.recurrenceEndDate &&
          other.notes == this.notes &&
          other.linkedTransactionId == this.linkedTransactionId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalTransactionsCompanion extends UpdateCompanion<LocalTransaction> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> accountId;
  final Value<String> categoryId;
  final Value<String> type;
  final Value<double> amount;
  final Value<String> description;
  final Value<DateTime> date;
  final Value<String> settlementStatus;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> settledAt;
  final Value<String> recurrence;
  final Value<String?> recurrenceGroupId;
  final Value<int> recurrenceIntervalMonths;
  final Value<int?> recurrenceIndex;
  final Value<int?> recurrenceTotal;
  final Value<String?> recurrenceBaseDescription;
  final Value<DateTime?> recurrenceEndDate;
  final Value<String?> notes;
  final Value<String?> linkedTransactionId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalTransactionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.settlementStatus = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.settledAt = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.recurrenceGroupId = const Value.absent(),
    this.recurrenceIntervalMonths = const Value.absent(),
    this.recurrenceIndex = const Value.absent(),
    this.recurrenceTotal = const Value.absent(),
    this.recurrenceBaseDescription = const Value.absent(),
    this.recurrenceEndDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.linkedTransactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTransactionsCompanion.insert({
    required String id,
    required String userId,
    required String accountId,
    required String categoryId,
    required String type,
    required double amount,
    required String description,
    required DateTime date,
    this.settlementStatus = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.settledAt = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.recurrenceGroupId = const Value.absent(),
    this.recurrenceIntervalMonths = const Value.absent(),
    this.recurrenceIndex = const Value.absent(),
    this.recurrenceTotal = const Value.absent(),
    this.recurrenceBaseDescription = const Value.absent(),
    this.recurrenceEndDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.linkedTransactionId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       accountId = Value(accountId),
       categoryId = Value(categoryId),
       type = Value(type),
       amount = Value(amount),
       description = Value(description),
       date = Value(date),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalTransaction> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? accountId,
    Expression<String>? categoryId,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<DateTime>? date,
    Expression<String>? settlementStatus,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? settledAt,
    Expression<String>? recurrence,
    Expression<String>? recurrenceGroupId,
    Expression<int>? recurrenceIntervalMonths,
    Expression<int>? recurrenceIndex,
    Expression<int>? recurrenceTotal,
    Expression<String>? recurrenceBaseDescription,
    Expression<DateTime>? recurrenceEndDate,
    Expression<String>? notes,
    Expression<String>? linkedTransactionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (settlementStatus != null) 'settlement_status': settlementStatus,
      if (dueDate != null) 'due_date': dueDate,
      if (settledAt != null) 'settled_at': settledAt,
      if (recurrence != null) 'recurrence': recurrence,
      if (recurrenceGroupId != null) 'recurrence_group_id': recurrenceGroupId,
      if (recurrenceIntervalMonths != null)
        'recurrence_interval_months': recurrenceIntervalMonths,
      if (recurrenceIndex != null) 'recurrence_index': recurrenceIndex,
      if (recurrenceTotal != null) 'recurrence_total': recurrenceTotal,
      if (recurrenceBaseDescription != null)
        'recurrence_base_description': recurrenceBaseDescription,
      if (recurrenceEndDate != null) 'recurrence_end_date': recurrenceEndDate,
      if (notes != null) 'notes': notes,
      if (linkedTransactionId != null)
        'linked_transaction_id': linkedTransactionId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? accountId,
    Value<String>? categoryId,
    Value<String>? type,
    Value<double>? amount,
    Value<String>? description,
    Value<DateTime>? date,
    Value<String>? settlementStatus,
    Value<DateTime?>? dueDate,
    Value<DateTime?>? settledAt,
    Value<String>? recurrence,
    Value<String?>? recurrenceGroupId,
    Value<int>? recurrenceIntervalMonths,
    Value<int?>? recurrenceIndex,
    Value<int?>? recurrenceTotal,
    Value<String?>? recurrenceBaseDescription,
    Value<DateTime?>? recurrenceEndDate,
    Value<String?>? notes,
    Value<String?>? linkedTransactionId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalTransactionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      settlementStatus: settlementStatus ?? this.settlementStatus,
      dueDate: dueDate ?? this.dueDate,
      settledAt: settledAt ?? this.settledAt,
      recurrence: recurrence ?? this.recurrence,
      recurrenceGroupId: recurrenceGroupId ?? this.recurrenceGroupId,
      recurrenceIntervalMonths:
          recurrenceIntervalMonths ?? this.recurrenceIntervalMonths,
      recurrenceIndex: recurrenceIndex ?? this.recurrenceIndex,
      recurrenceTotal: recurrenceTotal ?? this.recurrenceTotal,
      recurrenceBaseDescription:
          recurrenceBaseDescription ?? this.recurrenceBaseDescription,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      notes: notes ?? this.notes,
      linkedTransactionId: linkedTransactionId ?? this.linkedTransactionId,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (settlementStatus.present) {
      map['settlement_status'] = Variable<String>(settlementStatus.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (settledAt.present) {
      map['settled_at'] = Variable<DateTime>(settledAt.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (recurrenceGroupId.present) {
      map['recurrence_group_id'] = Variable<String>(recurrenceGroupId.value);
    }
    if (recurrenceIntervalMonths.present) {
      map['recurrence_interval_months'] = Variable<int>(
        recurrenceIntervalMonths.value,
      );
    }
    if (recurrenceIndex.present) {
      map['recurrence_index'] = Variable<int>(recurrenceIndex.value);
    }
    if (recurrenceTotal.present) {
      map['recurrence_total'] = Variable<int>(recurrenceTotal.value);
    }
    if (recurrenceBaseDescription.present) {
      map['recurrence_base_description'] = Variable<String>(
        recurrenceBaseDescription.value,
      );
    }
    if (recurrenceEndDate.present) {
      map['recurrence_end_date'] = Variable<DateTime>(recurrenceEndDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (linkedTransactionId.present) {
      map['linked_transaction_id'] = Variable<String>(
        linkedTransactionId.value,
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
    return (StringBuffer('LocalTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('settlementStatus: $settlementStatus, ')
          ..write('dueDate: $dueDate, ')
          ..write('settledAt: $settledAt, ')
          ..write('recurrence: $recurrence, ')
          ..write('recurrenceGroupId: $recurrenceGroupId, ')
          ..write('recurrenceIntervalMonths: $recurrenceIntervalMonths, ')
          ..write('recurrenceIndex: $recurrenceIndex, ')
          ..write('recurrenceTotal: $recurrenceTotal, ')
          ..write('recurrenceBaseDescription: $recurrenceBaseDescription, ')
          ..write('recurrenceEndDate: $recurrenceEndDate, ')
          ..write('notes: $notes, ')
          ..write('linkedTransactionId: $linkedTransactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCategoriesTable extends LocalCategories
    with TableInfo<$LocalCategoriesTable, LocalCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<int> icon = GeneratedColumn<int>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bucketMeta = const VerificationMeta('bucket');
  @override
  late final GeneratedColumn<String> bucket = GeneratedColumn<String>(
    'bucket',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countsInFiftyThirtyTwentyMeta =
      const VerificationMeta('countsInFiftyThirtyTwenty');
  @override
  late final GeneratedColumn<bool> countsInFiftyThirtyTwenty =
      GeneratedColumn<bool>(
        'counts_in_fifty_thirty_twenty',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("counts_in_fifty_thirty_twenty" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    icon,
    color,
    type,
    parentId,
    bucket,
    countsInFiftyThirtyTwenty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('bucket')) {
      context.handle(
        _bucketMeta,
        bucket.isAcceptableOrUnknown(data['bucket']!, _bucketMeta),
      );
    }
    if (data.containsKey('counts_in_fifty_thirty_twenty')) {
      context.handle(
        _countsInFiftyThirtyTwentyMeta,
        countsInFiftyThirtyTwenty.isAcceptableOrUnknown(
          data['counts_in_fifty_thirty_twenty']!,
          _countsInFiftyThirtyTwentyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      bucket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bucket'],
      ),
      countsInFiftyThirtyTwenty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}counts_in_fifty_thirty_twenty'],
      )!,
    );
  }

  @override
  $LocalCategoriesTable createAlias(String alias) {
    return $LocalCategoriesTable(attachedDatabase, alias);
  }
}

class LocalCategory extends DataClass implements Insertable<LocalCategory> {
  final String id;
  final String? userId;
  final String name;
  final int icon;
  final int color;
  final String type;
  final String? parentId;
  final String? bucket;
  final bool countsInFiftyThirtyTwenty;
  const LocalCategory({
    required this.id,
    this.userId,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.parentId,
    this.bucket,
    required this.countsInFiftyThirtyTwenty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<int>(icon);
    map['color'] = Variable<int>(color);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || bucket != null) {
      map['bucket'] = Variable<String>(bucket);
    }
    map['counts_in_fifty_thirty_twenty'] = Variable<bool>(
      countsInFiftyThirtyTwenty,
    );
    return map;
  }

  LocalCategoriesCompanion toCompanion(bool nullToAbsent) {
    return LocalCategoriesCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      type: Value(type),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      bucket: bucket == null && nullToAbsent
          ? const Value.absent()
          : Value(bucket),
      countsInFiftyThirtyTwenty: Value(countsInFiftyThirtyTwenty),
    );
  }

  factory LocalCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCategory(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<int>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      type: serializer.fromJson<String>(json['type']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      bucket: serializer.fromJson<String?>(json['bucket']),
      countsInFiftyThirtyTwenty: serializer.fromJson<bool>(
        json['countsInFiftyThirtyTwenty'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<int>(icon),
      'color': serializer.toJson<int>(color),
      'type': serializer.toJson<String>(type),
      'parentId': serializer.toJson<String?>(parentId),
      'bucket': serializer.toJson<String?>(bucket),
      'countsInFiftyThirtyTwenty': serializer.toJson<bool>(
        countsInFiftyThirtyTwenty,
      ),
    };
  }

  LocalCategory copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    String? name,
    int? icon,
    int? color,
    String? type,
    Value<String?> parentId = const Value.absent(),
    Value<String?> bucket = const Value.absent(),
    bool? countsInFiftyThirtyTwenty,
  }) => LocalCategory(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    type: type ?? this.type,
    parentId: parentId.present ? parentId.value : this.parentId,
    bucket: bucket.present ? bucket.value : this.bucket,
    countsInFiftyThirtyTwenty:
        countsInFiftyThirtyTwenty ?? this.countsInFiftyThirtyTwenty,
  );
  LocalCategory copyWithCompanion(LocalCategoriesCompanion data) {
    return LocalCategory(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      type: data.type.present ? data.type.value : this.type,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      bucket: data.bucket.present ? data.bucket.value : this.bucket,
      countsInFiftyThirtyTwenty: data.countsInFiftyThirtyTwenty.present
          ? data.countsInFiftyThirtyTwenty.value
          : this.countsInFiftyThirtyTwenty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategory(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('parentId: $parentId, ')
          ..write('bucket: $bucket, ')
          ..write('countsInFiftyThirtyTwenty: $countsInFiftyThirtyTwenty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    icon,
    color,
    type,
    parentId,
    bucket,
    countsInFiftyThirtyTwenty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCategory &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.type == this.type &&
          other.parentId == this.parentId &&
          other.bucket == this.bucket &&
          other.countsInFiftyThirtyTwenty == this.countsInFiftyThirtyTwenty);
}

class LocalCategoriesCompanion extends UpdateCompanion<LocalCategory> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> name;
  final Value<int> icon;
  final Value<int> color;
  final Value<String> type;
  final Value<String?> parentId;
  final Value<String?> bucket;
  final Value<bool> countsInFiftyThirtyTwenty;
  final Value<int> rowid;
  const LocalCategoriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.type = const Value.absent(),
    this.parentId = const Value.absent(),
    this.bucket = const Value.absent(),
    this.countsInFiftyThirtyTwenty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCategoriesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String name,
    required int icon,
    required int color,
    required String type,
    this.parentId = const Value.absent(),
    this.bucket = const Value.absent(),
    this.countsInFiftyThirtyTwenty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       icon = Value(icon),
       color = Value(color),
       type = Value(type);
  static Insertable<LocalCategory> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<int>? icon,
    Expression<int>? color,
    Expression<String>? type,
    Expression<String>? parentId,
    Expression<String>? bucket,
    Expression<bool>? countsInFiftyThirtyTwenty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (type != null) 'type': type,
      if (parentId != null) 'parent_id': parentId,
      if (bucket != null) 'bucket': bucket,
      if (countsInFiftyThirtyTwenty != null)
        'counts_in_fifty_thirty_twenty': countsInFiftyThirtyTwenty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String>? name,
    Value<int>? icon,
    Value<int>? color,
    Value<String>? type,
    Value<String?>? parentId,
    Value<String?>? bucket,
    Value<bool>? countsInFiftyThirtyTwenty,
    Value<int>? rowid,
  }) {
    return LocalCategoriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      bucket: bucket ?? this.bucket,
      countsInFiftyThirtyTwenty:
          countsInFiftyThirtyTwenty ?? this.countsInFiftyThirtyTwenty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<int>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (bucket.present) {
      map['bucket'] = Variable<String>(bucket.value);
    }
    if (countsInFiftyThirtyTwenty.present) {
      map['counts_in_fifty_thirty_twenty'] = Variable<bool>(
        countsInFiftyThirtyTwenty.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('parentId: $parentId, ')
          ..write('bucket: $bucket, ')
          ..write('countsInFiftyThirtyTwenty: $countsInFiftyThirtyTwenty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalBillsTable extends LocalBills
    with TableInfo<$LocalBillsTable, LocalBill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalBillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('payable'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurrenceMeta = const VerificationMeta(
    'recurrence',
  );
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
    'recurrence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paidTransactionIdMeta = const VerificationMeta(
    'paidTransactionId',
  );
  @override
  late final GeneratedColumn<String> paidTransactionId =
      GeneratedColumn<String>(
        'paid_transaction_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _parentBillIdMeta = const VerificationMeta(
    'parentBillId',
  );
  @override
  late final GeneratedColumn<String> parentBillId = GeneratedColumn<String>(
    'parent_bill_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rejectedTransactionIdsMeta =
      const VerificationMeta('rejectedTransactionIds');
  @override
  late final GeneratedColumn<String> rejectedTransactionIds =
      GeneratedColumn<String>(
        'rejected_transaction_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    type,
    description,
    amount,
    dueDate,
    status,
    recurrence,
    categoryId,
    notes,
    paidAt,
    paidTransactionId,
    parentBillId,
    rejectedTransactionIds,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_bills';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalBill> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('recurrence')) {
      context.handle(
        _recurrenceMeta,
        recurrence.isAcceptableOrUnknown(data['recurrence']!, _recurrenceMeta),
      );
    } else if (isInserting) {
      context.missing(_recurrenceMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    }
    if (data.containsKey('paid_transaction_id')) {
      context.handle(
        _paidTransactionIdMeta,
        paidTransactionId.isAcceptableOrUnknown(
          data['paid_transaction_id']!,
          _paidTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('parent_bill_id')) {
      context.handle(
        _parentBillIdMeta,
        parentBillId.isAcceptableOrUnknown(
          data['parent_bill_id']!,
          _parentBillIdMeta,
        ),
      );
    }
    if (data.containsKey('rejected_transaction_ids')) {
      context.handle(
        _rejectedTransactionIdsMeta,
        rejectedTransactionIds.isAcceptableOrUnknown(
          data['rejected_transaction_ids']!,
          _rejectedTransactionIdsMeta,
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalBill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalBill(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      recurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      ),
      paidTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_transaction_id'],
      ),
      parentBillId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_bill_id'],
      ),
      rejectedTransactionIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rejected_transaction_ids'],
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
  $LocalBillsTable createAlias(String alias) {
    return $LocalBillsTable(attachedDatabase, alias);
  }
}

class LocalBill extends DataClass implements Insertable<LocalBill> {
  final String id;
  final String userId;
  final String type;
  final String description;
  final double amount;
  final DateTime dueDate;
  final String status;
  final String recurrence;
  final String? categoryId;
  final String? notes;
  final DateTime? paidAt;
  final String? paidTransactionId;
  final String? parentBillId;
  final String rejectedTransactionIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalBill({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.recurrence,
    this.categoryId,
    this.notes,
    this.paidAt,
    this.paidTransactionId,
    this.parentBillId,
    required this.rejectedTransactionIds,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['type'] = Variable<String>(type);
    map['description'] = Variable<String>(description);
    map['amount'] = Variable<double>(amount);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['status'] = Variable<String>(status);
    map['recurrence'] = Variable<String>(recurrence);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || paidAt != null) {
      map['paid_at'] = Variable<DateTime>(paidAt);
    }
    if (!nullToAbsent || paidTransactionId != null) {
      map['paid_transaction_id'] = Variable<String>(paidTransactionId);
    }
    if (!nullToAbsent || parentBillId != null) {
      map['parent_bill_id'] = Variable<String>(parentBillId);
    }
    map['rejected_transaction_ids'] = Variable<String>(rejectedTransactionIds);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalBillsCompanion toCompanion(bool nullToAbsent) {
    return LocalBillsCompanion(
      id: Value(id),
      userId: Value(userId),
      type: Value(type),
      description: Value(description),
      amount: Value(amount),
      dueDate: Value(dueDate),
      status: Value(status),
      recurrence: Value(recurrence),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      paidAt: paidAt == null && nullToAbsent
          ? const Value.absent()
          : Value(paidAt),
      paidTransactionId: paidTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(paidTransactionId),
      parentBillId: parentBillId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentBillId),
      rejectedTransactionIds: Value(rejectedTransactionIds),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalBill.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalBill(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      status: serializer.fromJson<String>(json['status']),
      recurrence: serializer.fromJson<String>(json['recurrence']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      notes: serializer.fromJson<String?>(json['notes']),
      paidAt: serializer.fromJson<DateTime?>(json['paidAt']),
      paidTransactionId: serializer.fromJson<String?>(
        json['paidTransactionId'],
      ),
      parentBillId: serializer.fromJson<String?>(json['parentBillId']),
      rejectedTransactionIds: serializer.fromJson<String>(
        json['rejectedTransactionIds'],
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
      'userId': serializer.toJson<String>(userId),
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String>(description),
      'amount': serializer.toJson<double>(amount),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'status': serializer.toJson<String>(status),
      'recurrence': serializer.toJson<String>(recurrence),
      'categoryId': serializer.toJson<String?>(categoryId),
      'notes': serializer.toJson<String?>(notes),
      'paidAt': serializer.toJson<DateTime?>(paidAt),
      'paidTransactionId': serializer.toJson<String?>(paidTransactionId),
      'parentBillId': serializer.toJson<String?>(parentBillId),
      'rejectedTransactionIds': serializer.toJson<String>(
        rejectedTransactionIds,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalBill copyWith({
    String? id,
    String? userId,
    String? type,
    String? description,
    double? amount,
    DateTime? dueDate,
    String? status,
    String? recurrence,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> paidAt = const Value.absent(),
    Value<String?> paidTransactionId = const Value.absent(),
    Value<String?> parentBillId = const Value.absent(),
    String? rejectedTransactionIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalBill(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    type: type ?? this.type,
    description: description ?? this.description,
    amount: amount ?? this.amount,
    dueDate: dueDate ?? this.dueDate,
    status: status ?? this.status,
    recurrence: recurrence ?? this.recurrence,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    notes: notes.present ? notes.value : this.notes,
    paidAt: paidAt.present ? paidAt.value : this.paidAt,
    paidTransactionId: paidTransactionId.present
        ? paidTransactionId.value
        : this.paidTransactionId,
    parentBillId: parentBillId.present ? parentBillId.value : this.parentBillId,
    rejectedTransactionIds:
        rejectedTransactionIds ?? this.rejectedTransactionIds,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalBill copyWithCompanion(LocalBillsCompanion data) {
    return LocalBill(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      description: data.description.present
          ? data.description.value
          : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      status: data.status.present ? data.status.value : this.status,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      notes: data.notes.present ? data.notes.value : this.notes,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      paidTransactionId: data.paidTransactionId.present
          ? data.paidTransactionId.value
          : this.paidTransactionId,
      parentBillId: data.parentBillId.present
          ? data.parentBillId.value
          : this.parentBillId,
      rejectedTransactionIds: data.rejectedTransactionIds.present
          ? data.rejectedTransactionIds.value
          : this.rejectedTransactionIds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalBill(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('recurrence: $recurrence, ')
          ..write('categoryId: $categoryId, ')
          ..write('notes: $notes, ')
          ..write('paidAt: $paidAt, ')
          ..write('paidTransactionId: $paidTransactionId, ')
          ..write('parentBillId: $parentBillId, ')
          ..write('rejectedTransactionIds: $rejectedTransactionIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    type,
    description,
    amount,
    dueDate,
    status,
    recurrence,
    categoryId,
    notes,
    paidAt,
    paidTransactionId,
    parentBillId,
    rejectedTransactionIds,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalBill &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.recurrence == this.recurrence &&
          other.categoryId == this.categoryId &&
          other.notes == this.notes &&
          other.paidAt == this.paidAt &&
          other.paidTransactionId == this.paidTransactionId &&
          other.parentBillId == this.parentBillId &&
          other.rejectedTransactionIds == this.rejectedTransactionIds &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalBillsCompanion extends UpdateCompanion<LocalBill> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> type;
  final Value<String> description;
  final Value<double> amount;
  final Value<DateTime> dueDate;
  final Value<String> status;
  final Value<String> recurrence;
  final Value<String?> categoryId;
  final Value<String?> notes;
  final Value<DateTime?> paidAt;
  final Value<String?> paidTransactionId;
  final Value<String?> parentBillId;
  final Value<String> rejectedTransactionIds;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalBillsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.notes = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.paidTransactionId = const Value.absent(),
    this.parentBillId = const Value.absent(),
    this.rejectedTransactionIds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalBillsCompanion.insert({
    required String id,
    required String userId,
    this.type = const Value.absent(),
    required String description,
    required double amount,
    required DateTime dueDate,
    required String status,
    required String recurrence,
    this.categoryId = const Value.absent(),
    this.notes = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.paidTransactionId = const Value.absent(),
    this.parentBillId = const Value.absent(),
    this.rejectedTransactionIds = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       description = Value(description),
       amount = Value(amount),
       dueDate = Value(dueDate),
       status = Value(status),
       recurrence = Value(recurrence),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalBill> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? type,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<DateTime>? dueDate,
    Expression<String>? status,
    Expression<String>? recurrence,
    Expression<String>? categoryId,
    Expression<String>? notes,
    Expression<DateTime>? paidAt,
    Expression<String>? paidTransactionId,
    Expression<String>? parentBillId,
    Expression<String>? rejectedTransactionIds,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (recurrence != null) 'recurrence': recurrence,
      if (categoryId != null) 'category_id': categoryId,
      if (notes != null) 'notes': notes,
      if (paidAt != null) 'paid_at': paidAt,
      if (paidTransactionId != null) 'paid_transaction_id': paidTransactionId,
      if (parentBillId != null) 'parent_bill_id': parentBillId,
      if (rejectedTransactionIds != null)
        'rejected_transaction_ids': rejectedTransactionIds,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalBillsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? type,
    Value<String>? description,
    Value<double>? amount,
    Value<DateTime>? dueDate,
    Value<String>? status,
    Value<String>? recurrence,
    Value<String?>? categoryId,
    Value<String?>? notes,
    Value<DateTime?>? paidAt,
    Value<String?>? paidTransactionId,
    Value<String?>? parentBillId,
    Value<String>? rejectedTransactionIds,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalBillsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      recurrence: recurrence ?? this.recurrence,
      categoryId: categoryId ?? this.categoryId,
      notes: notes ?? this.notes,
      paidAt: paidAt ?? this.paidAt,
      paidTransactionId: paidTransactionId ?? this.paidTransactionId,
      parentBillId: parentBillId ?? this.parentBillId,
      rejectedTransactionIds:
          rejectedTransactionIds ?? this.rejectedTransactionIds,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (paidTransactionId.present) {
      map['paid_transaction_id'] = Variable<String>(paidTransactionId.value);
    }
    if (parentBillId.present) {
      map['parent_bill_id'] = Variable<String>(parentBillId.value);
    }
    if (rejectedTransactionIds.present) {
      map['rejected_transaction_ids'] = Variable<String>(
        rejectedTransactionIds.value,
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
    return (StringBuffer('LocalBillsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('recurrence: $recurrence, ')
          ..write('categoryId: $categoryId, ')
          ..write('notes: $notes, ')
          ..write('paidAt: $paidAt, ')
          ..write('paidTransactionId: $paidTransactionId, ')
          ..write('parentBillId: $parentBillId, ')
          ..write('rejectedTransactionIds: $rejectedTransactionIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalBudgetsTable extends LocalBudgets
    with TableInfo<$LocalBudgetsTable, LocalBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalBudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    categoryId,
    amount,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalBudget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalBudget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
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
  $LocalBudgetsTable createAlias(String alias) {
    return $LocalBudgetsTable(attachedDatabase, alias);
  }
}

class LocalBudget extends DataClass implements Insertable<LocalBudget> {
  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalBudget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['category_id'] = Variable<String>(categoryId);
    map['amount'] = Variable<double>(amount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalBudgetsCompanion toCompanion(bool nullToAbsent) {
    return LocalBudgetsCompanion(
      id: Value(id),
      userId: Value(userId),
      categoryId: Value(categoryId),
      amount: Value(amount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalBudget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalBudget(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      amount: serializer.fromJson<double>(json['amount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'categoryId': serializer.toJson<String>(categoryId),
      'amount': serializer.toJson<double>(amount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalBudget copyWith({
    String? id,
    String? userId,
    String? categoryId,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalBudget(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    categoryId: categoryId ?? this.categoryId,
    amount: amount ?? this.amount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalBudget copyWithCompanion(LocalBudgetsCompanion data) {
    return LocalBudget(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amount: data.amount.present ? data.amount.value : this.amount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalBudget(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, categoryId, amount, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalBudget &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.categoryId == this.categoryId &&
          other.amount == this.amount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalBudgetsCompanion extends UpdateCompanion<LocalBudget> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> categoryId;
  final Value<double> amount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalBudgetsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalBudgetsCompanion.insert({
    required String id,
    required String userId,
    required String categoryId,
    required double amount,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       categoryId = Value(categoryId),
       amount = Value(amount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalBudget> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? categoryId,
    Expression<double>? amount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (categoryId != null) 'category_id': categoryId,
      if (amount != null) 'amount': amount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalBudgetsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? categoryId,
    Value<double>? amount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalBudgetsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
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
    return (StringBuffer('LocalBudgetsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAssetClassesTable extends LocalAssetClasses
    with TableInfo<$LocalAssetClassesTable, LocalAssetClassesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAssetClassesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<int> icon = GeneratedColumn<int>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetPercentMeta = const VerificationMeta(
    'targetPercent',
  );
  @override
  late final GeneratedColumn<double> targetPercent = GeneratedColumn<double>(
    'target_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
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
    userId,
    name,
    icon,
    color,
    targetPercent,
    parentId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_asset_classes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAssetClassesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('target_percent')) {
      context.handle(
        _targetPercentMeta,
        targetPercent.isAcceptableOrUnknown(
          data['target_percent']!,
          _targetPercentMeta,
        ),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
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
  LocalAssetClassesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAssetClassesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      targetPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_percent'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalAssetClassesTable createAlias(String alias) {
    return $LocalAssetClassesTable(attachedDatabase, alias);
  }
}

class LocalAssetClassesData extends DataClass
    implements Insertable<LocalAssetClassesData> {
  final String id;
  final String userId;
  final String name;
  final int icon;
  final int color;
  final double targetPercent;
  final String? parentId;
  final DateTime createdAt;
  const LocalAssetClassesData({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.color,
    required this.targetPercent,
    this.parentId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<int>(icon);
    map['color'] = Variable<int>(color);
    map['target_percent'] = Variable<double>(targetPercent);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalAssetClassesCompanion toCompanion(bool nullToAbsent) {
    return LocalAssetClassesCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      targetPercent: Value(targetPercent),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      createdAt: Value(createdAt),
    );
  }

  factory LocalAssetClassesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAssetClassesData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<int>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      targetPercent: serializer.fromJson<double>(json['targetPercent']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<int>(icon),
      'color': serializer.toJson<int>(color),
      'targetPercent': serializer.toJson<double>(targetPercent),
      'parentId': serializer.toJson<String?>(parentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalAssetClassesData copyWith({
    String? id,
    String? userId,
    String? name,
    int? icon,
    int? color,
    double? targetPercent,
    Value<String?> parentId = const Value.absent(),
    DateTime? createdAt,
  }) => LocalAssetClassesData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    targetPercent: targetPercent ?? this.targetPercent,
    parentId: parentId.present ? parentId.value : this.parentId,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalAssetClassesData copyWithCompanion(LocalAssetClassesCompanion data) {
    return LocalAssetClassesData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      targetPercent: data.targetPercent.present
          ? data.targetPercent.value
          : this.targetPercent,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssetClassesData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('targetPercent: $targetPercent, ')
          ..write('parentId: $parentId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    icon,
    color,
    targetPercent,
    parentId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAssetClassesData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.targetPercent == this.targetPercent &&
          other.parentId == this.parentId &&
          other.createdAt == this.createdAt);
}

class LocalAssetClassesCompanion
    extends UpdateCompanion<LocalAssetClassesData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<int> icon;
  final Value<int> color;
  final Value<double> targetPercent;
  final Value<String?> parentId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalAssetClassesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.targetPercent = const Value.absent(),
    this.parentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAssetClassesCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required int icon,
    required int color,
    this.targetPercent = const Value.absent(),
    this.parentId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       icon = Value(icon),
       color = Value(color),
       createdAt = Value(createdAt);
  static Insertable<LocalAssetClassesData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<int>? icon,
    Expression<int>? color,
    Expression<double>? targetPercent,
    Expression<String>? parentId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (targetPercent != null) 'target_percent': targetPercent,
      if (parentId != null) 'parent_id': parentId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAssetClassesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<int>? icon,
    Value<int>? color,
    Value<double>? targetPercent,
    Value<String?>? parentId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalAssetClassesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      targetPercent: targetPercent ?? this.targetPercent,
      parentId: parentId ?? this.parentId,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<int>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (targetPercent.present) {
      map['target_percent'] = Variable<double>(targetPercent.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
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
    return (StringBuffer('LocalAssetClassesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('targetPercent: $targetPercent, ')
          ..write('parentId: $parentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAssetHoldingsTable extends LocalAssetHoldings
    with TableInfo<$LocalAssetHoldingsTable, LocalAssetHolding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAssetHoldingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetClassIdMeta = const VerificationMeta(
    'assetClassId',
  );
  @override
  late final GeneratedColumn<String> assetClassId = GeneratedColumn<String>(
    'asset_class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    accountId,
    assetClassId,
    amount,
    notes,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_asset_holdings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAssetHolding> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('asset_class_id')) {
      context.handle(
        _assetClassIdMeta,
        assetClassId.isAcceptableOrUnknown(
          data['asset_class_id']!,
          _assetClassIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assetClassIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAssetHolding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAssetHolding(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      assetClassId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_class_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalAssetHoldingsTable createAlias(String alias) {
    return $LocalAssetHoldingsTable(attachedDatabase, alias);
  }
}

class LocalAssetHolding extends DataClass
    implements Insertable<LocalAssetHolding> {
  final String id;
  final String userId;
  final String accountId;
  final String assetClassId;
  final double amount;
  final String? notes;
  final DateTime updatedAt;
  const LocalAssetHolding({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.assetClassId,
    required this.amount,
    this.notes,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['account_id'] = Variable<String>(accountId);
    map['asset_class_id'] = Variable<String>(assetClassId);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalAssetHoldingsCompanion toCompanion(bool nullToAbsent) {
    return LocalAssetHoldingsCompanion(
      id: Value(id),
      userId: Value(userId),
      accountId: Value(accountId),
      assetClassId: Value(assetClassId),
      amount: Value(amount),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalAssetHolding.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAssetHolding(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      assetClassId: serializer.fromJson<String>(json['assetClassId']),
      amount: serializer.fromJson<double>(json['amount']),
      notes: serializer.fromJson<String?>(json['notes']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'accountId': serializer.toJson<String>(accountId),
      'assetClassId': serializer.toJson<String>(assetClassId),
      'amount': serializer.toJson<double>(amount),
      'notes': serializer.toJson<String?>(notes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalAssetHolding copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? assetClassId,
    double? amount,
    Value<String?> notes = const Value.absent(),
    DateTime? updatedAt,
  }) => LocalAssetHolding(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    accountId: accountId ?? this.accountId,
    assetClassId: assetClassId ?? this.assetClassId,
    amount: amount ?? this.amount,
    notes: notes.present ? notes.value : this.notes,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalAssetHolding copyWithCompanion(LocalAssetHoldingsCompanion data) {
    return LocalAssetHolding(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      assetClassId: data.assetClassId.present
          ? data.assetClassId.value
          : this.assetClassId,
      amount: data.amount.present ? data.amount.value : this.amount,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssetHolding(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('assetClassId: $assetClassId, ')
          ..write('amount: $amount, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    accountId,
    assetClassId,
    amount,
    notes,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAssetHolding &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.accountId == this.accountId &&
          other.assetClassId == this.assetClassId &&
          other.amount == this.amount &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt);
}

class LocalAssetHoldingsCompanion extends UpdateCompanion<LocalAssetHolding> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> accountId;
  final Value<String> assetClassId;
  final Value<double> amount;
  final Value<String?> notes;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalAssetHoldingsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.assetClassId = const Value.absent(),
    this.amount = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAssetHoldingsCompanion.insert({
    required String id,
    required String userId,
    required String accountId,
    required String assetClassId,
    required double amount,
    this.notes = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       accountId = Value(accountId),
       assetClassId = Value(assetClassId),
       amount = Value(amount),
       updatedAt = Value(updatedAt);
  static Insertable<LocalAssetHolding> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? accountId,
    Expression<String>? assetClassId,
    Expression<double>? amount,
    Expression<String>? notes,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (accountId != null) 'account_id': accountId,
      if (assetClassId != null) 'asset_class_id': assetClassId,
      if (amount != null) 'amount': amount,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAssetHoldingsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? accountId,
    Value<String>? assetClassId,
    Value<double>? amount,
    Value<String?>? notes,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalAssetHoldingsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      assetClassId: assetClassId ?? this.assetClassId,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (assetClassId.present) {
      map['asset_class_id'] = Variable<String>(assetClassId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('LocalAssetHoldingsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('assetClassId: $assetClassId, ')
          ..write('amount: $amount, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalUsersTable localUsers = $LocalUsersTable(this);
  late final $LocalAccountsTable localAccounts = $LocalAccountsTable(this);
  late final $LocalTransactionsTable localTransactions =
      $LocalTransactionsTable(this);
  late final $LocalCategoriesTable localCategories = $LocalCategoriesTable(
    this,
  );
  late final $LocalBillsTable localBills = $LocalBillsTable(this);
  late final $LocalBudgetsTable localBudgets = $LocalBudgetsTable(this);
  late final $LocalAssetClassesTable localAssetClasses =
      $LocalAssetClassesTable(this);
  late final $LocalAssetHoldingsTable localAssetHoldings =
      $LocalAssetHoldingsTable(this);
  late final UsersDao usersDao = UsersDao(this as AppDatabase);
  late final AccountsDao accountsDao = AccountsDao(this as AppDatabase);
  late final TransactionsDao transactionsDao = TransactionsDao(
    this as AppDatabase,
  );
  late final CategoriesDao categoriesDao = CategoriesDao(this as AppDatabase);
  late final BillsDao billsDao = BillsDao(this as AppDatabase);
  late final BudgetsDao budgetsDao = BudgetsDao(this as AppDatabase);
  late final AssetClassesDao assetClassesDao = AssetClassesDao(
    this as AppDatabase,
  );
  late final AssetHoldingsDao assetHoldingsDao = AssetHoldingsDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localUsers,
    localAccounts,
    localTransactions,
    localCategories,
    localBills,
    localBudgets,
    localAssetClasses,
    localAssetHoldings,
  ];
}

typedef $$LocalUsersTableCreateCompanionBuilder =
    LocalUsersCompanion Function({
      required String id,
      required String name,
      required String email,
      Value<String?> photoUrl,
      required DateTime createdAt,
      Value<double?> fiftyThirtyTwentyNeeds,
      Value<double?> fiftyThirtyTwentyWants,
      Value<double?> fiftyThirtyTwentySavings,
      Value<int> rowid,
    });
typedef $$LocalUsersTableUpdateCompanionBuilder =
    LocalUsersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> email,
      Value<String?> photoUrl,
      Value<DateTime> createdAt,
      Value<double?> fiftyThirtyTwentyNeeds,
      Value<double?> fiftyThirtyTwentyWants,
      Value<double?> fiftyThirtyTwentySavings,
      Value<int> rowid,
    });

class $$LocalUsersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableFilterComposer({
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

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiftyThirtyTwentyNeeds => $composableBuilder(
    column: $table.fiftyThirtyTwentyNeeds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiftyThirtyTwentyWants => $composableBuilder(
    column: $table.fiftyThirtyTwentyWants,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiftyThirtyTwentySavings => $composableBuilder(
    column: $table.fiftyThirtyTwentySavings,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableOrderingComposer({
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

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiftyThirtyTwentyNeeds => $composableBuilder(
    column: $table.fiftyThirtyTwentyNeeds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiftyThirtyTwentyWants => $composableBuilder(
    column: $table.fiftyThirtyTwentyWants,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiftyThirtyTwentySavings => $composableBuilder(
    column: $table.fiftyThirtyTwentySavings,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableAnnotationComposer({
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

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<double> get fiftyThirtyTwentyNeeds => $composableBuilder(
    column: $table.fiftyThirtyTwentyNeeds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fiftyThirtyTwentyWants => $composableBuilder(
    column: $table.fiftyThirtyTwentyWants,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fiftyThirtyTwentySavings => $composableBuilder(
    column: $table.fiftyThirtyTwentySavings,
    builder: (column) => column,
  );
}

class $$LocalUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalUsersTable,
          LocalUser,
          $$LocalUsersTableFilterComposer,
          $$LocalUsersTableOrderingComposer,
          $$LocalUsersTableAnnotationComposer,
          $$LocalUsersTableCreateCompanionBuilder,
          $$LocalUsersTableUpdateCompanionBuilder,
          (
            LocalUser,
            BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>,
          ),
          LocalUser,
          PrefetchHooks Function()
        > {
  $$LocalUsersTableTableManager(_$AppDatabase db, $LocalUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<double?> fiftyThirtyTwentyNeeds = const Value.absent(),
                Value<double?> fiftyThirtyTwentyWants = const Value.absent(),
                Value<double?> fiftyThirtyTwentySavings = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion(
                id: id,
                name: name,
                email: email,
                photoUrl: photoUrl,
                createdAt: createdAt,
                fiftyThirtyTwentyNeeds: fiftyThirtyTwentyNeeds,
                fiftyThirtyTwentyWants: fiftyThirtyTwentyWants,
                fiftyThirtyTwentySavings: fiftyThirtyTwentySavings,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String email,
                Value<String?> photoUrl = const Value.absent(),
                required DateTime createdAt,
                Value<double?> fiftyThirtyTwentyNeeds = const Value.absent(),
                Value<double?> fiftyThirtyTwentyWants = const Value.absent(),
                Value<double?> fiftyThirtyTwentySavings = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion.insert(
                id: id,
                name: name,
                email: email,
                photoUrl: photoUrl,
                createdAt: createdAt,
                fiftyThirtyTwentyNeeds: fiftyThirtyTwentyNeeds,
                fiftyThirtyTwentyWants: fiftyThirtyTwentyWants,
                fiftyThirtyTwentySavings: fiftyThirtyTwentySavings,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalUsersTable,
      LocalUser,
      $$LocalUsersTableFilterComposer,
      $$LocalUsersTableOrderingComposer,
      $$LocalUsersTableAnnotationComposer,
      $$LocalUsersTableCreateCompanionBuilder,
      $$LocalUsersTableUpdateCompanionBuilder,
      (LocalUser, BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>),
      LocalUser,
      PrefetchHooks Function()
    >;
typedef $$LocalAccountsTableCreateCompanionBuilder =
    LocalAccountsCompanion Function({
      required String id,
      required String userId,
      required String name,
      required String type,
      required String bank,
      required double initialBalance,
      Value<double?> creditLimit,
      Value<int?> closingDay,
      Value<int?> dueDay,
      Value<String?> linkedAccountId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalAccountsTableUpdateCompanionBuilder =
    LocalAccountsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String> type,
      Value<String> bank,
      Value<double> initialBalance,
      Value<double?> creditLimit,
      Value<int?> closingDay,
      Value<int?> dueDay,
      Value<String?> linkedAccountId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bank => $composableBuilder(
    column: $table.bank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get closingDay => $composableBuilder(
    column: $table.closingDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedAccountId => $composableBuilder(
    column: $table.linkedAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bank => $composableBuilder(
    column: $table.bank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closingDay => $composableBuilder(
    column: $table.closingDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedAccountId => $composableBuilder(
    column: $table.linkedAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get bank =>
      $composableBuilder(column: $table.bank, builder: (column) => column);

  GeneratedColumn<double> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get closingDay => $composableBuilder(
    column: $table.closingDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => column);

  GeneratedColumn<String> get linkedAccountId => $composableBuilder(
    column: $table.linkedAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAccountsTable,
          LocalAccount,
          $$LocalAccountsTableFilterComposer,
          $$LocalAccountsTableOrderingComposer,
          $$LocalAccountsTableAnnotationComposer,
          $$LocalAccountsTableCreateCompanionBuilder,
          $$LocalAccountsTableUpdateCompanionBuilder,
          (
            LocalAccount,
            BaseReferences<_$AppDatabase, $LocalAccountsTable, LocalAccount>,
          ),
          LocalAccount,
          PrefetchHooks Function()
        > {
  $$LocalAccountsTableTableManager(_$AppDatabase db, $LocalAccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> bank = const Value.absent(),
                Value<double> initialBalance = const Value.absent(),
                Value<double?> creditLimit = const Value.absent(),
                Value<int?> closingDay = const Value.absent(),
                Value<int?> dueDay = const Value.absent(),
                Value<String?> linkedAccountId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAccountsCompanion(
                id: id,
                userId: userId,
                name: name,
                type: type,
                bank: bank,
                initialBalance: initialBalance,
                creditLimit: creditLimit,
                closingDay: closingDay,
                dueDay: dueDay,
                linkedAccountId: linkedAccountId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                required String type,
                required String bank,
                required double initialBalance,
                Value<double?> creditLimit = const Value.absent(),
                Value<int?> closingDay = const Value.absent(),
                Value<int?> dueDay = const Value.absent(),
                Value<String?> linkedAccountId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalAccountsCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                type: type,
                bank: bank,
                initialBalance: initialBalance,
                creditLimit: creditLimit,
                closingDay: closingDay,
                dueDay: dueDay,
                linkedAccountId: linkedAccountId,
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

typedef $$LocalAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAccountsTable,
      LocalAccount,
      $$LocalAccountsTableFilterComposer,
      $$LocalAccountsTableOrderingComposer,
      $$LocalAccountsTableAnnotationComposer,
      $$LocalAccountsTableCreateCompanionBuilder,
      $$LocalAccountsTableUpdateCompanionBuilder,
      (
        LocalAccount,
        BaseReferences<_$AppDatabase, $LocalAccountsTable, LocalAccount>,
      ),
      LocalAccount,
      PrefetchHooks Function()
    >;
typedef $$LocalTransactionsTableCreateCompanionBuilder =
    LocalTransactionsCompanion Function({
      required String id,
      required String userId,
      required String accountId,
      required String categoryId,
      required String type,
      required double amount,
      required String description,
      required DateTime date,
      Value<String> settlementStatus,
      Value<DateTime?> dueDate,
      Value<DateTime?> settledAt,
      Value<String> recurrence,
      Value<String?> recurrenceGroupId,
      Value<int> recurrenceIntervalMonths,
      Value<int?> recurrenceIndex,
      Value<int?> recurrenceTotal,
      Value<String?> recurrenceBaseDescription,
      Value<DateTime?> recurrenceEndDate,
      Value<String?> notes,
      Value<String?> linkedTransactionId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalTransactionsTableUpdateCompanionBuilder =
    LocalTransactionsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> accountId,
      Value<String> categoryId,
      Value<String> type,
      Value<double> amount,
      Value<String> description,
      Value<DateTime> date,
      Value<String> settlementStatus,
      Value<DateTime?> dueDate,
      Value<DateTime?> settledAt,
      Value<String> recurrence,
      Value<String?> recurrenceGroupId,
      Value<int> recurrenceIntervalMonths,
      Value<int?> recurrenceIndex,
      Value<int?> recurrenceTotal,
      Value<String?> recurrenceBaseDescription,
      Value<DateTime?> recurrenceEndDate,
      Value<String?> notes,
      Value<String?> linkedTransactionId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settlementStatus => $composableBuilder(
    column: $table.settlementStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceGroupId => $composableBuilder(
    column: $table.recurrenceGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurrenceIntervalMonths => $composableBuilder(
    column: $table.recurrenceIntervalMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurrenceIndex => $composableBuilder(
    column: $table.recurrenceIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurrenceTotal => $composableBuilder(
    column: $table.recurrenceTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceBaseDescription => $composableBuilder(
    column: $table.recurrenceBaseDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recurrenceEndDate => $composableBuilder(
    column: $table.recurrenceEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedTransactionId => $composableBuilder(
    column: $table.linkedTransactionId,
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

class $$LocalTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settlementStatus => $composableBuilder(
    column: $table.settlementStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceGroupId => $composableBuilder(
    column: $table.recurrenceGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrenceIntervalMonths => $composableBuilder(
    column: $table.recurrenceIntervalMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrenceIndex => $composableBuilder(
    column: $table.recurrenceIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrenceTotal => $composableBuilder(
    column: $table.recurrenceTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceBaseDescription => $composableBuilder(
    column: $table.recurrenceBaseDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recurrenceEndDate => $composableBuilder(
    column: $table.recurrenceEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedTransactionId => $composableBuilder(
    column: $table.linkedTransactionId,
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

class $$LocalTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get settlementStatus => $composableBuilder(
    column: $table.settlementStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get settledAt =>
      $composableBuilder(column: $table.settledAt, builder: (column) => column);

  GeneratedColumn<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceGroupId => $composableBuilder(
    column: $table.recurrenceGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurrenceIntervalMonths => $composableBuilder(
    column: $table.recurrenceIntervalMonths,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurrenceIndex => $composableBuilder(
    column: $table.recurrenceIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurrenceTotal => $composableBuilder(
    column: $table.recurrenceTotal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceBaseDescription => $composableBuilder(
    column: $table.recurrenceBaseDescription,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recurrenceEndDate => $composableBuilder(
    column: $table.recurrenceEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get linkedTransactionId => $composableBuilder(
    column: $table.linkedTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTransactionsTable,
          LocalTransaction,
          $$LocalTransactionsTableFilterComposer,
          $$LocalTransactionsTableOrderingComposer,
          $$LocalTransactionsTableAnnotationComposer,
          $$LocalTransactionsTableCreateCompanionBuilder,
          $$LocalTransactionsTableUpdateCompanionBuilder,
          (
            LocalTransaction,
            BaseReferences<
              _$AppDatabase,
              $LocalTransactionsTable,
              LocalTransaction
            >,
          ),
          LocalTransaction,
          PrefetchHooks Function()
        > {
  $$LocalTransactionsTableTableManager(
    _$AppDatabase db,
    $LocalTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> settlementStatus = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> settledAt = const Value.absent(),
                Value<String> recurrence = const Value.absent(),
                Value<String?> recurrenceGroupId = const Value.absent(),
                Value<int> recurrenceIntervalMonths = const Value.absent(),
                Value<int?> recurrenceIndex = const Value.absent(),
                Value<int?> recurrenceTotal = const Value.absent(),
                Value<String?> recurrenceBaseDescription = const Value.absent(),
                Value<DateTime?> recurrenceEndDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> linkedTransactionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTransactionsCompanion(
                id: id,
                userId: userId,
                accountId: accountId,
                categoryId: categoryId,
                type: type,
                amount: amount,
                description: description,
                date: date,
                settlementStatus: settlementStatus,
                dueDate: dueDate,
                settledAt: settledAt,
                recurrence: recurrence,
                recurrenceGroupId: recurrenceGroupId,
                recurrenceIntervalMonths: recurrenceIntervalMonths,
                recurrenceIndex: recurrenceIndex,
                recurrenceTotal: recurrenceTotal,
                recurrenceBaseDescription: recurrenceBaseDescription,
                recurrenceEndDate: recurrenceEndDate,
                notes: notes,
                linkedTransactionId: linkedTransactionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String accountId,
                required String categoryId,
                required String type,
                required double amount,
                required String description,
                required DateTime date,
                Value<String> settlementStatus = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> settledAt = const Value.absent(),
                Value<String> recurrence = const Value.absent(),
                Value<String?> recurrenceGroupId = const Value.absent(),
                Value<int> recurrenceIntervalMonths = const Value.absent(),
                Value<int?> recurrenceIndex = const Value.absent(),
                Value<int?> recurrenceTotal = const Value.absent(),
                Value<String?> recurrenceBaseDescription = const Value.absent(),
                Value<DateTime?> recurrenceEndDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> linkedTransactionId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalTransactionsCompanion.insert(
                id: id,
                userId: userId,
                accountId: accountId,
                categoryId: categoryId,
                type: type,
                amount: amount,
                description: description,
                date: date,
                settlementStatus: settlementStatus,
                dueDate: dueDate,
                settledAt: settledAt,
                recurrence: recurrence,
                recurrenceGroupId: recurrenceGroupId,
                recurrenceIntervalMonths: recurrenceIntervalMonths,
                recurrenceIndex: recurrenceIndex,
                recurrenceTotal: recurrenceTotal,
                recurrenceBaseDescription: recurrenceBaseDescription,
                recurrenceEndDate: recurrenceEndDate,
                notes: notes,
                linkedTransactionId: linkedTransactionId,
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

typedef $$LocalTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTransactionsTable,
      LocalTransaction,
      $$LocalTransactionsTableFilterComposer,
      $$LocalTransactionsTableOrderingComposer,
      $$LocalTransactionsTableAnnotationComposer,
      $$LocalTransactionsTableCreateCompanionBuilder,
      $$LocalTransactionsTableUpdateCompanionBuilder,
      (
        LocalTransaction,
        BaseReferences<
          _$AppDatabase,
          $LocalTransactionsTable,
          LocalTransaction
        >,
      ),
      LocalTransaction,
      PrefetchHooks Function()
    >;
typedef $$LocalCategoriesTableCreateCompanionBuilder =
    LocalCategoriesCompanion Function({
      required String id,
      Value<String?> userId,
      required String name,
      required int icon,
      required int color,
      required String type,
      Value<String?> parentId,
      Value<String?> bucket,
      Value<bool> countsInFiftyThirtyTwenty,
      Value<int> rowid,
    });
typedef $$LocalCategoriesTableUpdateCompanionBuilder =
    LocalCategoriesCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String> name,
      Value<int> icon,
      Value<int> color,
      Value<String> type,
      Value<String?> parentId,
      Value<String?> bucket,
      Value<bool> countsInFiftyThirtyTwenty,
      Value<int> rowid,
    });

class $$LocalCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get countsInFiftyThirtyTwenty => $composableBuilder(
    column: $table.countsInFiftyThirtyTwenty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get countsInFiftyThirtyTwenty => $composableBuilder(
    column: $table.countsInFiftyThirtyTwenty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get bucket =>
      $composableBuilder(column: $table.bucket, builder: (column) => column);

  GeneratedColumn<bool> get countsInFiftyThirtyTwenty => $composableBuilder(
    column: $table.countsInFiftyThirtyTwenty,
    builder: (column) => column,
  );
}

class $$LocalCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCategoriesTable,
          LocalCategory,
          $$LocalCategoriesTableFilterComposer,
          $$LocalCategoriesTableOrderingComposer,
          $$LocalCategoriesTableAnnotationComposer,
          $$LocalCategoriesTableCreateCompanionBuilder,
          $$LocalCategoriesTableUpdateCompanionBuilder,
          (
            LocalCategory,
            BaseReferences<_$AppDatabase, $LocalCategoriesTable, LocalCategory>,
          ),
          LocalCategory,
          PrefetchHooks Function()
        > {
  $$LocalCategoriesTableTableManager(
    _$AppDatabase db,
    $LocalCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String?> bucket = const Value.absent(),
                Value<bool> countsInFiftyThirtyTwenty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCategoriesCompanion(
                id: id,
                userId: userId,
                name: name,
                icon: icon,
                color: color,
                type: type,
                parentId: parentId,
                bucket: bucket,
                countsInFiftyThirtyTwenty: countsInFiftyThirtyTwenty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userId = const Value.absent(),
                required String name,
                required int icon,
                required int color,
                required String type,
                Value<String?> parentId = const Value.absent(),
                Value<String?> bucket = const Value.absent(),
                Value<bool> countsInFiftyThirtyTwenty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCategoriesCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                icon: icon,
                color: color,
                type: type,
                parentId: parentId,
                bucket: bucket,
                countsInFiftyThirtyTwenty: countsInFiftyThirtyTwenty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCategoriesTable,
      LocalCategory,
      $$LocalCategoriesTableFilterComposer,
      $$LocalCategoriesTableOrderingComposer,
      $$LocalCategoriesTableAnnotationComposer,
      $$LocalCategoriesTableCreateCompanionBuilder,
      $$LocalCategoriesTableUpdateCompanionBuilder,
      (
        LocalCategory,
        BaseReferences<_$AppDatabase, $LocalCategoriesTable, LocalCategory>,
      ),
      LocalCategory,
      PrefetchHooks Function()
    >;
typedef $$LocalBillsTableCreateCompanionBuilder =
    LocalBillsCompanion Function({
      required String id,
      required String userId,
      Value<String> type,
      required String description,
      required double amount,
      required DateTime dueDate,
      required String status,
      required String recurrence,
      Value<String?> categoryId,
      Value<String?> notes,
      Value<DateTime?> paidAt,
      Value<String?> paidTransactionId,
      Value<String?> parentBillId,
      Value<String> rejectedTransactionIds,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalBillsTableUpdateCompanionBuilder =
    LocalBillsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> type,
      Value<String> description,
      Value<double> amount,
      Value<DateTime> dueDate,
      Value<String> status,
      Value<String> recurrence,
      Value<String?> categoryId,
      Value<String?> notes,
      Value<DateTime?> paidAt,
      Value<String?> paidTransactionId,
      Value<String?> parentBillId,
      Value<String> rejectedTransactionIds,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalBillsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalBillsTable> {
  $$LocalBillsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paidTransactionId => $composableBuilder(
    column: $table.paidTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentBillId => $composableBuilder(
    column: $table.parentBillId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rejectedTransactionIds => $composableBuilder(
    column: $table.rejectedTransactionIds,
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

class $$LocalBillsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalBillsTable> {
  $$LocalBillsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paidTransactionId => $composableBuilder(
    column: $table.paidTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentBillId => $composableBuilder(
    column: $table.parentBillId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rejectedTransactionIds => $composableBuilder(
    column: $table.rejectedTransactionIds,
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

class $$LocalBillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalBillsTable> {
  $$LocalBillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<String> get paidTransactionId => $composableBuilder(
    column: $table.paidTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentBillId => $composableBuilder(
    column: $table.parentBillId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rejectedTransactionIds => $composableBuilder(
    column: $table.rejectedTransactionIds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalBillsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalBillsTable,
          LocalBill,
          $$LocalBillsTableFilterComposer,
          $$LocalBillsTableOrderingComposer,
          $$LocalBillsTableAnnotationComposer,
          $$LocalBillsTableCreateCompanionBuilder,
          $$LocalBillsTableUpdateCompanionBuilder,
          (
            LocalBill,
            BaseReferences<_$AppDatabase, $LocalBillsTable, LocalBill>,
          ),
          LocalBill,
          PrefetchHooks Function()
        > {
  $$LocalBillsTableTableManager(_$AppDatabase db, $LocalBillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalBillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalBillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalBillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> recurrence = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> paidAt = const Value.absent(),
                Value<String?> paidTransactionId = const Value.absent(),
                Value<String?> parentBillId = const Value.absent(),
                Value<String> rejectedTransactionIds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalBillsCompanion(
                id: id,
                userId: userId,
                type: type,
                description: description,
                amount: amount,
                dueDate: dueDate,
                status: status,
                recurrence: recurrence,
                categoryId: categoryId,
                notes: notes,
                paidAt: paidAt,
                paidTransactionId: paidTransactionId,
                parentBillId: parentBillId,
                rejectedTransactionIds: rejectedTransactionIds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String> type = const Value.absent(),
                required String description,
                required double amount,
                required DateTime dueDate,
                required String status,
                required String recurrence,
                Value<String?> categoryId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> paidAt = const Value.absent(),
                Value<String?> paidTransactionId = const Value.absent(),
                Value<String?> parentBillId = const Value.absent(),
                Value<String> rejectedTransactionIds = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalBillsCompanion.insert(
                id: id,
                userId: userId,
                type: type,
                description: description,
                amount: amount,
                dueDate: dueDate,
                status: status,
                recurrence: recurrence,
                categoryId: categoryId,
                notes: notes,
                paidAt: paidAt,
                paidTransactionId: paidTransactionId,
                parentBillId: parentBillId,
                rejectedTransactionIds: rejectedTransactionIds,
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

typedef $$LocalBillsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalBillsTable,
      LocalBill,
      $$LocalBillsTableFilterComposer,
      $$LocalBillsTableOrderingComposer,
      $$LocalBillsTableAnnotationComposer,
      $$LocalBillsTableCreateCompanionBuilder,
      $$LocalBillsTableUpdateCompanionBuilder,
      (LocalBill, BaseReferences<_$AppDatabase, $LocalBillsTable, LocalBill>),
      LocalBill,
      PrefetchHooks Function()
    >;
typedef $$LocalBudgetsTableCreateCompanionBuilder =
    LocalBudgetsCompanion Function({
      required String id,
      required String userId,
      required String categoryId,
      required double amount,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalBudgetsTableUpdateCompanionBuilder =
    LocalBudgetsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> categoryId,
      Value<double> amount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalBudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalBudgetsTable> {
  $$LocalBudgetsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
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

class $$LocalBudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalBudgetsTable> {
  $$LocalBudgetsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
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

class $$LocalBudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalBudgetsTable> {
  $$LocalBudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalBudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalBudgetsTable,
          LocalBudget,
          $$LocalBudgetsTableFilterComposer,
          $$LocalBudgetsTableOrderingComposer,
          $$LocalBudgetsTableAnnotationComposer,
          $$LocalBudgetsTableCreateCompanionBuilder,
          $$LocalBudgetsTableUpdateCompanionBuilder,
          (
            LocalBudget,
            BaseReferences<_$AppDatabase, $LocalBudgetsTable, LocalBudget>,
          ),
          LocalBudget,
          PrefetchHooks Function()
        > {
  $$LocalBudgetsTableTableManager(_$AppDatabase db, $LocalBudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalBudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalBudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalBudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalBudgetsCompanion(
                id: id,
                userId: userId,
                categoryId: categoryId,
                amount: amount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String categoryId,
                required double amount,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalBudgetsCompanion.insert(
                id: id,
                userId: userId,
                categoryId: categoryId,
                amount: amount,
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

typedef $$LocalBudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalBudgetsTable,
      LocalBudget,
      $$LocalBudgetsTableFilterComposer,
      $$LocalBudgetsTableOrderingComposer,
      $$LocalBudgetsTableAnnotationComposer,
      $$LocalBudgetsTableCreateCompanionBuilder,
      $$LocalBudgetsTableUpdateCompanionBuilder,
      (
        LocalBudget,
        BaseReferences<_$AppDatabase, $LocalBudgetsTable, LocalBudget>,
      ),
      LocalBudget,
      PrefetchHooks Function()
    >;
typedef $$LocalAssetClassesTableCreateCompanionBuilder =
    LocalAssetClassesCompanion Function({
      required String id,
      required String userId,
      required String name,
      required int icon,
      required int color,
      Value<double> targetPercent,
      Value<String?> parentId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalAssetClassesTableUpdateCompanionBuilder =
    LocalAssetClassesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<int> icon,
      Value<int> color,
      Value<double> targetPercent,
      Value<String?> parentId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalAssetClassesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAssetClassesTable> {
  $$LocalAssetClassesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetPercent => $composableBuilder(
    column: $table.targetPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAssetClassesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAssetClassesTable> {
  $$LocalAssetClassesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetPercent => $composableBuilder(
    column: $table.targetPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAssetClassesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAssetClassesTable> {
  $$LocalAssetClassesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<double> get targetPercent => $composableBuilder(
    column: $table.targetPercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalAssetClassesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAssetClassesTable,
          LocalAssetClassesData,
          $$LocalAssetClassesTableFilterComposer,
          $$LocalAssetClassesTableOrderingComposer,
          $$LocalAssetClassesTableAnnotationComposer,
          $$LocalAssetClassesTableCreateCompanionBuilder,
          $$LocalAssetClassesTableUpdateCompanionBuilder,
          (
            LocalAssetClassesData,
            BaseReferences<
              _$AppDatabase,
              $LocalAssetClassesTable,
              LocalAssetClassesData
            >,
          ),
          LocalAssetClassesData,
          PrefetchHooks Function()
        > {
  $$LocalAssetClassesTableTableManager(
    _$AppDatabase db,
    $LocalAssetClassesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAssetClassesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAssetClassesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAssetClassesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<double> targetPercent = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssetClassesCompanion(
                id: id,
                userId: userId,
                name: name,
                icon: icon,
                color: color,
                targetPercent: targetPercent,
                parentId: parentId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                required int icon,
                required int color,
                Value<double> targetPercent = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalAssetClassesCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                icon: icon,
                color: color,
                targetPercent: targetPercent,
                parentId: parentId,
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

typedef $$LocalAssetClassesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAssetClassesTable,
      LocalAssetClassesData,
      $$LocalAssetClassesTableFilterComposer,
      $$LocalAssetClassesTableOrderingComposer,
      $$LocalAssetClassesTableAnnotationComposer,
      $$LocalAssetClassesTableCreateCompanionBuilder,
      $$LocalAssetClassesTableUpdateCompanionBuilder,
      (
        LocalAssetClassesData,
        BaseReferences<
          _$AppDatabase,
          $LocalAssetClassesTable,
          LocalAssetClassesData
        >,
      ),
      LocalAssetClassesData,
      PrefetchHooks Function()
    >;
typedef $$LocalAssetHoldingsTableCreateCompanionBuilder =
    LocalAssetHoldingsCompanion Function({
      required String id,
      required String userId,
      required String accountId,
      required String assetClassId,
      required double amount,
      Value<String?> notes,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalAssetHoldingsTableUpdateCompanionBuilder =
    LocalAssetHoldingsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> accountId,
      Value<String> assetClassId,
      Value<double> amount,
      Value<String?> notes,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalAssetHoldingsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAssetHoldingsTable> {
  $$LocalAssetHoldingsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetClassId => $composableBuilder(
    column: $table.assetClassId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAssetHoldingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAssetHoldingsTable> {
  $$LocalAssetHoldingsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetClassId => $composableBuilder(
    column: $table.assetClassId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAssetHoldingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAssetHoldingsTable> {
  $$LocalAssetHoldingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get assetClassId => $composableBuilder(
    column: $table.assetClassId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalAssetHoldingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAssetHoldingsTable,
          LocalAssetHolding,
          $$LocalAssetHoldingsTableFilterComposer,
          $$LocalAssetHoldingsTableOrderingComposer,
          $$LocalAssetHoldingsTableAnnotationComposer,
          $$LocalAssetHoldingsTableCreateCompanionBuilder,
          $$LocalAssetHoldingsTableUpdateCompanionBuilder,
          (
            LocalAssetHolding,
            BaseReferences<
              _$AppDatabase,
              $LocalAssetHoldingsTable,
              LocalAssetHolding
            >,
          ),
          LocalAssetHolding,
          PrefetchHooks Function()
        > {
  $$LocalAssetHoldingsTableTableManager(
    _$AppDatabase db,
    $LocalAssetHoldingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAssetHoldingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAssetHoldingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAssetHoldingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> assetClassId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssetHoldingsCompanion(
                id: id,
                userId: userId,
                accountId: accountId,
                assetClassId: assetClassId,
                amount: amount,
                notes: notes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String accountId,
                required String assetClassId,
                required double amount,
                Value<String?> notes = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalAssetHoldingsCompanion.insert(
                id: id,
                userId: userId,
                accountId: accountId,
                assetClassId: assetClassId,
                amount: amount,
                notes: notes,
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

typedef $$LocalAssetHoldingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAssetHoldingsTable,
      LocalAssetHolding,
      $$LocalAssetHoldingsTableFilterComposer,
      $$LocalAssetHoldingsTableOrderingComposer,
      $$LocalAssetHoldingsTableAnnotationComposer,
      $$LocalAssetHoldingsTableCreateCompanionBuilder,
      $$LocalAssetHoldingsTableUpdateCompanionBuilder,
      (
        LocalAssetHolding,
        BaseReferences<
          _$AppDatabase,
          $LocalAssetHoldingsTable,
          LocalAssetHolding
        >,
      ),
      LocalAssetHolding,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db, _db.localUsers);
  $$LocalAccountsTableTableManager get localAccounts =>
      $$LocalAccountsTableTableManager(_db, _db.localAccounts);
  $$LocalTransactionsTableTableManager get localTransactions =>
      $$LocalTransactionsTableTableManager(_db, _db.localTransactions);
  $$LocalCategoriesTableTableManager get localCategories =>
      $$LocalCategoriesTableTableManager(_db, _db.localCategories);
  $$LocalBillsTableTableManager get localBills =>
      $$LocalBillsTableTableManager(_db, _db.localBills);
  $$LocalBudgetsTableTableManager get localBudgets =>
      $$LocalBudgetsTableTableManager(_db, _db.localBudgets);
  $$LocalAssetClassesTableTableManager get localAssetClasses =>
      $$LocalAssetClassesTableTableManager(_db, _db.localAssetClasses);
  $$LocalAssetHoldingsTableTableManager get localAssetHoldings =>
      $$LocalAssetHoldingsTableTableManager(_db, _db.localAssetHoldings);
}
