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

class $LocalInstitutionsTable extends LocalInstitutions
    with TableInfo<$LocalInstitutionsTable, LocalInstitution> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalInstitutionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    kind,
    currency,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_institutions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalInstitution> instance, {
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
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
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
  LocalInstitution map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalInstitution(
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
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalInstitutionsTable createAlias(String alias) {
    return $LocalInstitutionsTable(attachedDatabase, alias);
  }
}

class LocalInstitution extends DataClass
    implements Insertable<LocalInstitution> {
  final String id;
  final String userId;
  final String name;
  final String kind;
  final String currency;
  final DateTime createdAt;
  const LocalInstitution({
    required this.id,
    required this.userId,
    required this.name,
    required this.kind,
    required this.currency,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['currency'] = Variable<String>(currency);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalInstitutionsCompanion toCompanion(bool nullToAbsent) {
    return LocalInstitutionsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      kind: Value(kind),
      currency: Value(currency),
      createdAt: Value(createdAt),
    );
  }

  factory LocalInstitution.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalInstitution(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      currency: serializer.fromJson<String>(json['currency']),
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
      'kind': serializer.toJson<String>(kind),
      'currency': serializer.toJson<String>(currency),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalInstitution copyWith({
    String? id,
    String? userId,
    String? name,
    String? kind,
    String? currency,
    DateTime? createdAt,
  }) => LocalInstitution(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    currency: currency ?? this.currency,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalInstitution copyWithCompanion(LocalInstitutionsCompanion data) {
    return LocalInstitution(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      currency: data.currency.present ? data.currency.value : this.currency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalInstitution(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, name, kind, currency, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalInstitution &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.currency == this.currency &&
          other.createdAt == this.createdAt);
}

class LocalInstitutionsCompanion extends UpdateCompanion<LocalInstitution> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> currency;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalInstitutionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.currency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalInstitutionsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required String kind,
    required String currency,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       kind = Value(kind),
       currency = Value(currency),
       createdAt = Value(createdAt);
  static Insertable<LocalInstitution> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? currency,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (currency != null) 'currency': currency,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalInstitutionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? currency,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalInstitutionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      currency: currency ?? this.currency,
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
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
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
    return (StringBuffer('LocalInstitutionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalInvestmentAssetsTable extends LocalInvestmentAssets
    with TableInfo<$LocalInvestmentAssetsTable, LocalInvestmentAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalInvestmentAssetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tickerMeta = const VerificationMeta('ticker');
  @override
  late final GeneratedColumn<String> ticker = GeneratedColumn<String>(
    'ticker',
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketMeta = const VerificationMeta('market');
  @override
  late final GeneratedColumn<String> market = GeneratedColumn<String>(
    'market',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _institutionIdMeta = const VerificationMeta(
    'institutionId',
  );
  @override
  late final GeneratedColumn<String> institutionId = GeneratedColumn<String>(
    'institution_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
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
    ticker,
    name,
    kind,
    market,
    currency,
    institutionId,
    metadata,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_investment_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalInvestmentAsset> instance, {
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
    if (data.containsKey('ticker')) {
      context.handle(
        _tickerMeta,
        ticker.isAcceptableOrUnknown(data['ticker']!, _tickerMeta),
      );
    } else if (isInserting) {
      context.missing(_tickerMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('market')) {
      context.handle(
        _marketMeta,
        market.isAcceptableOrUnknown(data['market']!, _marketMeta),
      );
    } else if (isInserting) {
      context.missing(_marketMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('institution_id')) {
      context.handle(
        _institutionIdMeta,
        institutionId.isAcceptableOrUnknown(
          data['institution_id']!,
          _institutionIdMeta,
        ),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
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
  LocalInvestmentAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalInvestmentAsset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      ticker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ticker'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      market: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      institutionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution_id'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalInvestmentAssetsTable createAlias(String alias) {
    return $LocalInvestmentAssetsTable(attachedDatabase, alias);
  }
}

class LocalInvestmentAsset extends DataClass
    implements Insertable<LocalInvestmentAsset> {
  final String id;
  final String userId;
  final String ticker;
  final String name;
  final String kind;
  final String market;
  final String currency;
  final String? institutionId;
  final String metadata;
  final DateTime createdAt;
  const LocalInvestmentAsset({
    required this.id,
    required this.userId,
    required this.ticker,
    required this.name,
    required this.kind,
    required this.market,
    required this.currency,
    this.institutionId,
    required this.metadata,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['ticker'] = Variable<String>(ticker);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['market'] = Variable<String>(market);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || institutionId != null) {
      map['institution_id'] = Variable<String>(institutionId);
    }
    map['metadata'] = Variable<String>(metadata);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalInvestmentAssetsCompanion toCompanion(bool nullToAbsent) {
    return LocalInvestmentAssetsCompanion(
      id: Value(id),
      userId: Value(userId),
      ticker: Value(ticker),
      name: Value(name),
      kind: Value(kind),
      market: Value(market),
      currency: Value(currency),
      institutionId: institutionId == null && nullToAbsent
          ? const Value.absent()
          : Value(institutionId),
      metadata: Value(metadata),
      createdAt: Value(createdAt),
    );
  }

  factory LocalInvestmentAsset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalInvestmentAsset(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      ticker: serializer.fromJson<String>(json['ticker']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      market: serializer.fromJson<String>(json['market']),
      currency: serializer.fromJson<String>(json['currency']),
      institutionId: serializer.fromJson<String?>(json['institutionId']),
      metadata: serializer.fromJson<String>(json['metadata']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'ticker': serializer.toJson<String>(ticker),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'market': serializer.toJson<String>(market),
      'currency': serializer.toJson<String>(currency),
      'institutionId': serializer.toJson<String?>(institutionId),
      'metadata': serializer.toJson<String>(metadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalInvestmentAsset copyWith({
    String? id,
    String? userId,
    String? ticker,
    String? name,
    String? kind,
    String? market,
    String? currency,
    Value<String?> institutionId = const Value.absent(),
    String? metadata,
    DateTime? createdAt,
  }) => LocalInvestmentAsset(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    ticker: ticker ?? this.ticker,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    market: market ?? this.market,
    currency: currency ?? this.currency,
    institutionId: institutionId.present
        ? institutionId.value
        : this.institutionId,
    metadata: metadata ?? this.metadata,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalInvestmentAsset copyWithCompanion(LocalInvestmentAssetsCompanion data) {
    return LocalInvestmentAsset(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      ticker: data.ticker.present ? data.ticker.value : this.ticker,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      market: data.market.present ? data.market.value : this.market,
      currency: data.currency.present ? data.currency.value : this.currency,
      institutionId: data.institutionId.present
          ? data.institutionId.value
          : this.institutionId,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalInvestmentAsset(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('ticker: $ticker, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('market: $market, ')
          ..write('currency: $currency, ')
          ..write('institutionId: $institutionId, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    ticker,
    name,
    kind,
    market,
    currency,
    institutionId,
    metadata,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalInvestmentAsset &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.ticker == this.ticker &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.market == this.market &&
          other.currency == this.currency &&
          other.institutionId == this.institutionId &&
          other.metadata == this.metadata &&
          other.createdAt == this.createdAt);
}

class LocalInvestmentAssetsCompanion
    extends UpdateCompanion<LocalInvestmentAsset> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> ticker;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> market;
  final Value<String> currency;
  final Value<String?> institutionId;
  final Value<String> metadata;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalInvestmentAssetsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.ticker = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.market = const Value.absent(),
    this.currency = const Value.absent(),
    this.institutionId = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalInvestmentAssetsCompanion.insert({
    required String id,
    required String userId,
    required String ticker,
    required String name,
    required String kind,
    required String market,
    required String currency,
    this.institutionId = const Value.absent(),
    this.metadata = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       ticker = Value(ticker),
       name = Value(name),
       kind = Value(kind),
       market = Value(market),
       currency = Value(currency),
       createdAt = Value(createdAt);
  static Insertable<LocalInvestmentAsset> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? ticker,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? market,
    Expression<String>? currency,
    Expression<String>? institutionId,
    Expression<String>? metadata,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (ticker != null) 'ticker': ticker,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (market != null) 'market': market,
      if (currency != null) 'currency': currency,
      if (institutionId != null) 'institution_id': institutionId,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalInvestmentAssetsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? ticker,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? market,
    Value<String>? currency,
    Value<String?>? institutionId,
    Value<String>? metadata,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalInvestmentAssetsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      ticker: ticker ?? this.ticker,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      market: market ?? this.market,
      currency: currency ?? this.currency,
      institutionId: institutionId ?? this.institutionId,
      metadata: metadata ?? this.metadata,
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
    if (ticker.present) {
      map['ticker'] = Variable<String>(ticker.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (market.present) {
      map['market'] = Variable<String>(market.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (institutionId.present) {
      map['institution_id'] = Variable<String>(institutionId.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
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
    return (StringBuffer('LocalInvestmentAssetsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('ticker: $ticker, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('market: $market, ')
          ..write('currency: $currency, ')
          ..write('institutionId: $institutionId, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalInvestmentTransactionsTable extends LocalInvestmentTransactions
    with
        TableInfo<
          $LocalInvestmentTransactionsTable,
          LocalInvestmentTransaction
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalInvestmentTransactionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _institutionIdMeta = const VerificationMeta(
    'institutionId',
  );
  @override
  late final GeneratedColumn<String> institutionId = GeneratedColumn<String>(
    'institution_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMinorMeta = const VerificationMeta(
    'unitPriceMinor',
  );
  @override
  late final GeneratedColumn<int> unitPriceMinor = GeneratedColumn<int>(
    'unit_price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feesMinorMeta = const VerificationMeta(
    'feesMinor',
  );
  @override
  late final GeneratedColumn<int> feesMinor = GeneratedColumn<int>(
    'fees_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    institutionId,
    assetId,
    kind,
    quantity,
    unitPriceMinor,
    feesMinor,
    amountMinor,
    currency,
    date,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_investment_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalInvestmentTransaction> instance, {
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
    if (data.containsKey('institution_id')) {
      context.handle(
        _institutionIdMeta,
        institutionId.isAcceptableOrUnknown(
          data['institution_id']!,
          _institutionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institutionIdMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price_minor')) {
      context.handle(
        _unitPriceMinorMeta,
        unitPriceMinor.isAcceptableOrUnknown(
          data['unit_price_minor']!,
          _unitPriceMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMinorMeta);
    }
    if (data.containsKey('fees_minor')) {
      context.handle(
        _feesMinorMeta,
        feesMinor.isAcceptableOrUnknown(data['fees_minor']!, _feesMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_feesMinorMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
  LocalInvestmentTransaction map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalInvestmentTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      institutionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution_id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unitPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_minor'],
      )!,
      feesMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fees_minor'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
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
  $LocalInvestmentTransactionsTable createAlias(String alias) {
    return $LocalInvestmentTransactionsTable(attachedDatabase, alias);
  }
}

class LocalInvestmentTransaction extends DataClass
    implements Insertable<LocalInvestmentTransaction> {
  final String id;
  final String userId;
  final String institutionId;
  final String assetId;
  final String kind;
  final double quantity;
  final int unitPriceMinor;
  final int feesMinor;
  final int amountMinor;
  final String currency;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalInvestmentTransaction({
    required this.id,
    required this.userId,
    required this.institutionId,
    required this.assetId,
    required this.kind,
    required this.quantity,
    required this.unitPriceMinor,
    required this.feesMinor,
    required this.amountMinor,
    required this.currency,
    required this.date,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['institution_id'] = Variable<String>(institutionId);
    map['asset_id'] = Variable<String>(assetId);
    map['kind'] = Variable<String>(kind);
    map['quantity'] = Variable<double>(quantity);
    map['unit_price_minor'] = Variable<int>(unitPriceMinor);
    map['fees_minor'] = Variable<int>(feesMinor);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalInvestmentTransactionsCompanion toCompanion(bool nullToAbsent) {
    return LocalInvestmentTransactionsCompanion(
      id: Value(id),
      userId: Value(userId),
      institutionId: Value(institutionId),
      assetId: Value(assetId),
      kind: Value(kind),
      quantity: Value(quantity),
      unitPriceMinor: Value(unitPriceMinor),
      feesMinor: Value(feesMinor),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      date: Value(date),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalInvestmentTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalInvestmentTransaction(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      institutionId: serializer.fromJson<String>(json['institutionId']),
      assetId: serializer.fromJson<String>(json['assetId']),
      kind: serializer.fromJson<String>(json['kind']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitPriceMinor: serializer.fromJson<int>(json['unitPriceMinor']),
      feesMinor: serializer.fromJson<int>(json['feesMinor']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
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
      'institutionId': serializer.toJson<String>(institutionId),
      'assetId': serializer.toJson<String>(assetId),
      'kind': serializer.toJson<String>(kind),
      'quantity': serializer.toJson<double>(quantity),
      'unitPriceMinor': serializer.toJson<int>(unitPriceMinor),
      'feesMinor': serializer.toJson<int>(feesMinor),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalInvestmentTransaction copyWith({
    String? id,
    String? userId,
    String? institutionId,
    String? assetId,
    String? kind,
    double? quantity,
    int? unitPriceMinor,
    int? feesMinor,
    int? amountMinor,
    String? currency,
    DateTime? date,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalInvestmentTransaction(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    institutionId: institutionId ?? this.institutionId,
    assetId: assetId ?? this.assetId,
    kind: kind ?? this.kind,
    quantity: quantity ?? this.quantity,
    unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
    feesMinor: feesMinor ?? this.feesMinor,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    date: date ?? this.date,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalInvestmentTransaction copyWithCompanion(
    LocalInvestmentTransactionsCompanion data,
  ) {
    return LocalInvestmentTransaction(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      institutionId: data.institutionId.present
          ? data.institutionId.value
          : this.institutionId,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      kind: data.kind.present ? data.kind.value : this.kind,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPriceMinor: data.unitPriceMinor.present
          ? data.unitPriceMinor.value
          : this.unitPriceMinor,
      feesMinor: data.feesMinor.present ? data.feesMinor.value : this.feesMinor,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalInvestmentTransaction(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('institutionId: $institutionId, ')
          ..write('assetId: $assetId, ')
          ..write('kind: $kind, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('feesMinor: $feesMinor, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    institutionId,
    assetId,
    kind,
    quantity,
    unitPriceMinor,
    feesMinor,
    amountMinor,
    currency,
    date,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalInvestmentTransaction &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.institutionId == this.institutionId &&
          other.assetId == this.assetId &&
          other.kind == this.kind &&
          other.quantity == this.quantity &&
          other.unitPriceMinor == this.unitPriceMinor &&
          other.feesMinor == this.feesMinor &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.date == this.date &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalInvestmentTransactionsCompanion
    extends UpdateCompanion<LocalInvestmentTransaction> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> institutionId;
  final Value<String> assetId;
  final Value<String> kind;
  final Value<double> quantity;
  final Value<int> unitPriceMinor;
  final Value<int> feesMinor;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalInvestmentTransactionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.institutionId = const Value.absent(),
    this.assetId = const Value.absent(),
    this.kind = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPriceMinor = const Value.absent(),
    this.feesMinor = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalInvestmentTransactionsCompanion.insert({
    required String id,
    required String userId,
    required String institutionId,
    required String assetId,
    required String kind,
    required double quantity,
    required int unitPriceMinor,
    required int feesMinor,
    required int amountMinor,
    required String currency,
    required DateTime date,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       institutionId = Value(institutionId),
       assetId = Value(assetId),
       kind = Value(kind),
       quantity = Value(quantity),
       unitPriceMinor = Value(unitPriceMinor),
       feesMinor = Value(feesMinor),
       amountMinor = Value(amountMinor),
       currency = Value(currency),
       date = Value(date),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalInvestmentTransaction> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? institutionId,
    Expression<String>? assetId,
    Expression<String>? kind,
    Expression<double>? quantity,
    Expression<int>? unitPriceMinor,
    Expression<int>? feesMinor,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (institutionId != null) 'institution_id': institutionId,
      if (assetId != null) 'asset_id': assetId,
      if (kind != null) 'kind': kind,
      if (quantity != null) 'quantity': quantity,
      if (unitPriceMinor != null) 'unit_price_minor': unitPriceMinor,
      if (feesMinor != null) 'fees_minor': feesMinor,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalInvestmentTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? institutionId,
    Value<String>? assetId,
    Value<String>? kind,
    Value<double>? quantity,
    Value<int>? unitPriceMinor,
    Value<int>? feesMinor,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<DateTime>? date,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalInvestmentTransactionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      institutionId: institutionId ?? this.institutionId,
      assetId: assetId ?? this.assetId,
      kind: kind ?? this.kind,
      quantity: quantity ?? this.quantity,
      unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
      feesMinor: feesMinor ?? this.feesMinor,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      notes: notes ?? this.notes,
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
    if (institutionId.present) {
      map['institution_id'] = Variable<String>(institutionId.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitPriceMinor.present) {
      map['unit_price_minor'] = Variable<int>(unitPriceMinor.value);
    }
    if (feesMinor.present) {
      map['fees_minor'] = Variable<int>(feesMinor.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('LocalInvestmentTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('institutionId: $institutionId, ')
          ..write('assetId: $assetId, ')
          ..write('kind: $kind, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('feesMinor: $feesMinor, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalInvestmentSnapshotsTable extends LocalInvestmentSnapshots
    with TableInfo<$LocalInvestmentSnapshotsTable, LocalInvestmentSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalInvestmentSnapshotsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalValueMinorMeta = const VerificationMeta(
    'totalValueMinor',
  );
  @override
  late final GeneratedColumn<int> totalValueMinor = GeneratedColumn<int>(
    'total_value_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalInvestedMinorMeta =
      const VerificationMeta('totalInvestedMinor');
  @override
  late final GeneratedColumn<int> totalInvestedMinor = GeneratedColumn<int>(
    'total_invested_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unrealizedPlMinorMeta = const VerificationMeta(
    'unrealizedPlMinor',
  );
  @override
  late final GeneratedColumn<int> unrealizedPlMinor = GeneratedColumn<int>(
    'unrealized_pl_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    date,
    totalValueMinor,
    totalInvestedMinor,
    unrealizedPlMinor,
    currency,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_investment_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalInvestmentSnapshot> instance, {
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
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('total_value_minor')) {
      context.handle(
        _totalValueMinorMeta,
        totalValueMinor.isAcceptableOrUnknown(
          data['total_value_minor']!,
          _totalValueMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalValueMinorMeta);
    }
    if (data.containsKey('total_invested_minor')) {
      context.handle(
        _totalInvestedMinorMeta,
        totalInvestedMinor.isAcceptableOrUnknown(
          data['total_invested_minor']!,
          _totalInvestedMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalInvestedMinorMeta);
    }
    if (data.containsKey('unrealized_pl_minor')) {
      context.handle(
        _unrealizedPlMinorMeta,
        unrealizedPlMinor.isAcceptableOrUnknown(
          data['unrealized_pl_minor']!,
          _unrealizedPlMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unrealizedPlMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalInvestmentSnapshot map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalInvestmentSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      totalValueMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_value_minor'],
      )!,
      totalInvestedMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_invested_minor'],
      )!,
      unrealizedPlMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unrealized_pl_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
    );
  }

  @override
  $LocalInvestmentSnapshotsTable createAlias(String alias) {
    return $LocalInvestmentSnapshotsTable(attachedDatabase, alias);
  }
}

class LocalInvestmentSnapshot extends DataClass
    implements Insertable<LocalInvestmentSnapshot> {
  final String id;
  final String userId;
  final DateTime date;
  final int totalValueMinor;
  final int totalInvestedMinor;
  final int unrealizedPlMinor;
  final String currency;
  const LocalInvestmentSnapshot({
    required this.id,
    required this.userId,
    required this.date,
    required this.totalValueMinor,
    required this.totalInvestedMinor,
    required this.unrealizedPlMinor,
    required this.currency,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['date'] = Variable<DateTime>(date);
    map['total_value_minor'] = Variable<int>(totalValueMinor);
    map['total_invested_minor'] = Variable<int>(totalInvestedMinor);
    map['unrealized_pl_minor'] = Variable<int>(unrealizedPlMinor);
    map['currency'] = Variable<String>(currency);
    return map;
  }

  LocalInvestmentSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return LocalInvestmentSnapshotsCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      totalValueMinor: Value(totalValueMinor),
      totalInvestedMinor: Value(totalInvestedMinor),
      unrealizedPlMinor: Value(unrealizedPlMinor),
      currency: Value(currency),
    );
  }

  factory LocalInvestmentSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalInvestmentSnapshot(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      totalValueMinor: serializer.fromJson<int>(json['totalValueMinor']),
      totalInvestedMinor: serializer.fromJson<int>(json['totalInvestedMinor']),
      unrealizedPlMinor: serializer.fromJson<int>(json['unrealizedPlMinor']),
      currency: serializer.fromJson<String>(json['currency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'date': serializer.toJson<DateTime>(date),
      'totalValueMinor': serializer.toJson<int>(totalValueMinor),
      'totalInvestedMinor': serializer.toJson<int>(totalInvestedMinor),
      'unrealizedPlMinor': serializer.toJson<int>(unrealizedPlMinor),
      'currency': serializer.toJson<String>(currency),
    };
  }

  LocalInvestmentSnapshot copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? totalValueMinor,
    int? totalInvestedMinor,
    int? unrealizedPlMinor,
    String? currency,
  }) => LocalInvestmentSnapshot(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    totalValueMinor: totalValueMinor ?? this.totalValueMinor,
    totalInvestedMinor: totalInvestedMinor ?? this.totalInvestedMinor,
    unrealizedPlMinor: unrealizedPlMinor ?? this.unrealizedPlMinor,
    currency: currency ?? this.currency,
  );
  LocalInvestmentSnapshot copyWithCompanion(
    LocalInvestmentSnapshotsCompanion data,
  ) {
    return LocalInvestmentSnapshot(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      totalValueMinor: data.totalValueMinor.present
          ? data.totalValueMinor.value
          : this.totalValueMinor,
      totalInvestedMinor: data.totalInvestedMinor.present
          ? data.totalInvestedMinor.value
          : this.totalInvestedMinor,
      unrealizedPlMinor: data.unrealizedPlMinor.present
          ? data.unrealizedPlMinor.value
          : this.unrealizedPlMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalInvestmentSnapshot(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('totalValueMinor: $totalValueMinor, ')
          ..write('totalInvestedMinor: $totalInvestedMinor, ')
          ..write('unrealizedPlMinor: $unrealizedPlMinor, ')
          ..write('currency: $currency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    date,
    totalValueMinor,
    totalInvestedMinor,
    unrealizedPlMinor,
    currency,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalInvestmentSnapshot &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.totalValueMinor == this.totalValueMinor &&
          other.totalInvestedMinor == this.totalInvestedMinor &&
          other.unrealizedPlMinor == this.unrealizedPlMinor &&
          other.currency == this.currency);
}

class LocalInvestmentSnapshotsCompanion
    extends UpdateCompanion<LocalInvestmentSnapshot> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> date;
  final Value<int> totalValueMinor;
  final Value<int> totalInvestedMinor;
  final Value<int> unrealizedPlMinor;
  final Value<String> currency;
  final Value<int> rowid;
  const LocalInvestmentSnapshotsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.totalValueMinor = const Value.absent(),
    this.totalInvestedMinor = const Value.absent(),
    this.unrealizedPlMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalInvestmentSnapshotsCompanion.insert({
    required String id,
    required String userId,
    required DateTime date,
    required int totalValueMinor,
    required int totalInvestedMinor,
    required int unrealizedPlMinor,
    required String currency,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       date = Value(date),
       totalValueMinor = Value(totalValueMinor),
       totalInvestedMinor = Value(totalInvestedMinor),
       unrealizedPlMinor = Value(unrealizedPlMinor),
       currency = Value(currency);
  static Insertable<LocalInvestmentSnapshot> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? date,
    Expression<int>? totalValueMinor,
    Expression<int>? totalInvestedMinor,
    Expression<int>? unrealizedPlMinor,
    Expression<String>? currency,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (totalValueMinor != null) 'total_value_minor': totalValueMinor,
      if (totalInvestedMinor != null)
        'total_invested_minor': totalInvestedMinor,
      if (unrealizedPlMinor != null) 'unrealized_pl_minor': unrealizedPlMinor,
      if (currency != null) 'currency': currency,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalInvestmentSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<DateTime>? date,
    Value<int>? totalValueMinor,
    Value<int>? totalInvestedMinor,
    Value<int>? unrealizedPlMinor,
    Value<String>? currency,
    Value<int>? rowid,
  }) {
    return LocalInvestmentSnapshotsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      totalValueMinor: totalValueMinor ?? this.totalValueMinor,
      totalInvestedMinor: totalInvestedMinor ?? this.totalInvestedMinor,
      unrealizedPlMinor: unrealizedPlMinor ?? this.unrealizedPlMinor,
      currency: currency ?? this.currency,
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
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (totalValueMinor.present) {
      map['total_value_minor'] = Variable<int>(totalValueMinor.value);
    }
    if (totalInvestedMinor.present) {
      map['total_invested_minor'] = Variable<int>(totalInvestedMinor.value);
    }
    if (unrealizedPlMinor.present) {
      map['unrealized_pl_minor'] = Variable<int>(unrealizedPlMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalInvestmentSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('totalValueMinor: $totalValueMinor, ')
          ..write('totalInvestedMinor: $totalInvestedMinor, ')
          ..write('unrealizedPlMinor: $unrealizedPlMinor, ')
          ..write('currency: $currency, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalQuotesTable extends LocalQuotes
    with TableInfo<$LocalQuotesTable, LocalQuote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalQuotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMinorMeta = const VerificationMeta(
    'unitPriceMinor',
  );
  @override
  late final GeneratedColumn<int> unitPriceMinor = GeneratedColumn<int>(
    'unit_price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousCloseMinorMeta =
      const VerificationMeta('previousCloseMinor');
  @override
  late final GeneratedColumn<int> previousCloseMinor = GeneratedColumn<int>(
    'previous_close_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _asOfMeta = const VerificationMeta('asOf');
  @override
  late final GeneratedColumn<DateTime> asOf = GeneratedColumn<DateTime>(
    'as_of',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    assetId,
    unitPriceMinor,
    previousCloseMinor,
    currency,
    asOf,
    fetchedAt,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_quotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalQuote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('unit_price_minor')) {
      context.handle(
        _unitPriceMinorMeta,
        unitPriceMinor.isAcceptableOrUnknown(
          data['unit_price_minor']!,
          _unitPriceMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMinorMeta);
    }
    if (data.containsKey('previous_close_minor')) {
      context.handle(
        _previousCloseMinorMeta,
        previousCloseMinor.isAcceptableOrUnknown(
          data['previous_close_minor']!,
          _previousCloseMinorMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('as_of')) {
      context.handle(
        _asOfMeta,
        asOf.isAcceptableOrUnknown(data['as_of']!, _asOfMeta),
      );
    } else if (isInserting) {
      context.missing(_asOfMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assetId};
  @override
  LocalQuote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalQuote(
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
      unitPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_minor'],
      )!,
      previousCloseMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}previous_close_minor'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      asOf: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}as_of'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $LocalQuotesTable createAlias(String alias) {
    return $LocalQuotesTable(attachedDatabase, alias);
  }
}

class LocalQuote extends DataClass implements Insertable<LocalQuote> {
  final String assetId;
  final int unitPriceMinor;
  final int? previousCloseMinor;
  final String currency;
  final DateTime asOf;
  final DateTime fetchedAt;
  final String source;
  const LocalQuote({
    required this.assetId,
    required this.unitPriceMinor,
    this.previousCloseMinor,
    required this.currency,
    required this.asOf,
    required this.fetchedAt,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset_id'] = Variable<String>(assetId);
    map['unit_price_minor'] = Variable<int>(unitPriceMinor);
    if (!nullToAbsent || previousCloseMinor != null) {
      map['previous_close_minor'] = Variable<int>(previousCloseMinor);
    }
    map['currency'] = Variable<String>(currency);
    map['as_of'] = Variable<DateTime>(asOf);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['source'] = Variable<String>(source);
    return map;
  }

  LocalQuotesCompanion toCompanion(bool nullToAbsent) {
    return LocalQuotesCompanion(
      assetId: Value(assetId),
      unitPriceMinor: Value(unitPriceMinor),
      previousCloseMinor: previousCloseMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(previousCloseMinor),
      currency: Value(currency),
      asOf: Value(asOf),
      fetchedAt: Value(fetchedAt),
      source: Value(source),
    );
  }

  factory LocalQuote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalQuote(
      assetId: serializer.fromJson<String>(json['assetId']),
      unitPriceMinor: serializer.fromJson<int>(json['unitPriceMinor']),
      previousCloseMinor: serializer.fromJson<int?>(json['previousCloseMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      asOf: serializer.fromJson<DateTime>(json['asOf']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assetId': serializer.toJson<String>(assetId),
      'unitPriceMinor': serializer.toJson<int>(unitPriceMinor),
      'previousCloseMinor': serializer.toJson<int?>(previousCloseMinor),
      'currency': serializer.toJson<String>(currency),
      'asOf': serializer.toJson<DateTime>(asOf),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'source': serializer.toJson<String>(source),
    };
  }

  LocalQuote copyWith({
    String? assetId,
    int? unitPriceMinor,
    Value<int?> previousCloseMinor = const Value.absent(),
    String? currency,
    DateTime? asOf,
    DateTime? fetchedAt,
    String? source,
  }) => LocalQuote(
    assetId: assetId ?? this.assetId,
    unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
    previousCloseMinor: previousCloseMinor.present
        ? previousCloseMinor.value
        : this.previousCloseMinor,
    currency: currency ?? this.currency,
    asOf: asOf ?? this.asOf,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    source: source ?? this.source,
  );
  LocalQuote copyWithCompanion(LocalQuotesCompanion data) {
    return LocalQuote(
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      unitPriceMinor: data.unitPriceMinor.present
          ? data.unitPriceMinor.value
          : this.unitPriceMinor,
      previousCloseMinor: data.previousCloseMinor.present
          ? data.previousCloseMinor.value
          : this.previousCloseMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      asOf: data.asOf.present ? data.asOf.value : this.asOf,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuote(')
          ..write('assetId: $assetId, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('previousCloseMinor: $previousCloseMinor, ')
          ..write('currency: $currency, ')
          ..write('asOf: $asOf, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    assetId,
    unitPriceMinor,
    previousCloseMinor,
    currency,
    asOf,
    fetchedAt,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalQuote &&
          other.assetId == this.assetId &&
          other.unitPriceMinor == this.unitPriceMinor &&
          other.previousCloseMinor == this.previousCloseMinor &&
          other.currency == this.currency &&
          other.asOf == this.asOf &&
          other.fetchedAt == this.fetchedAt &&
          other.source == this.source);
}

class LocalQuotesCompanion extends UpdateCompanion<LocalQuote> {
  final Value<String> assetId;
  final Value<int> unitPriceMinor;
  final Value<int?> previousCloseMinor;
  final Value<String> currency;
  final Value<DateTime> asOf;
  final Value<DateTime> fetchedAt;
  final Value<String> source;
  final Value<int> rowid;
  const LocalQuotesCompanion({
    this.assetId = const Value.absent(),
    this.unitPriceMinor = const Value.absent(),
    this.previousCloseMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.asOf = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalQuotesCompanion.insert({
    required String assetId,
    required int unitPriceMinor,
    this.previousCloseMinor = const Value.absent(),
    required String currency,
    required DateTime asOf,
    required DateTime fetchedAt,
    required String source,
    this.rowid = const Value.absent(),
  }) : assetId = Value(assetId),
       unitPriceMinor = Value(unitPriceMinor),
       currency = Value(currency),
       asOf = Value(asOf),
       fetchedAt = Value(fetchedAt),
       source = Value(source);
  static Insertable<LocalQuote> custom({
    Expression<String>? assetId,
    Expression<int>? unitPriceMinor,
    Expression<int>? previousCloseMinor,
    Expression<String>? currency,
    Expression<DateTime>? asOf,
    Expression<DateTime>? fetchedAt,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assetId != null) 'asset_id': assetId,
      if (unitPriceMinor != null) 'unit_price_minor': unitPriceMinor,
      if (previousCloseMinor != null)
        'previous_close_minor': previousCloseMinor,
      if (currency != null) 'currency': currency,
      if (asOf != null) 'as_of': asOf,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalQuotesCompanion copyWith({
    Value<String>? assetId,
    Value<int>? unitPriceMinor,
    Value<int?>? previousCloseMinor,
    Value<String>? currency,
    Value<DateTime>? asOf,
    Value<DateTime>? fetchedAt,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return LocalQuotesCompanion(
      assetId: assetId ?? this.assetId,
      unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
      previousCloseMinor: previousCloseMinor ?? this.previousCloseMinor,
      currency: currency ?? this.currency,
      asOf: asOf ?? this.asOf,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (unitPriceMinor.present) {
      map['unit_price_minor'] = Variable<int>(unitPriceMinor.value);
    }
    if (previousCloseMinor.present) {
      map['previous_close_minor'] = Variable<int>(previousCloseMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (asOf.present) {
      map['as_of'] = Variable<DateTime>(asOf.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuotesCompanion(')
          ..write('assetId: $assetId, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('previousCloseMinor: $previousCloseMinor, ')
          ..write('currency: $currency, ')
          ..write('asOf: $asOf, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalFxRatesTable extends LocalFxRates
    with TableInfo<$LocalFxRatesTable, LocalFxRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFxRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pairMeta = const VerificationMeta('pair');
  @override
  late final GeneratedColumn<String> pair = GeneratedColumn<String>(
    'pair',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [pair, rate, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_fx_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalFxRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pair')) {
      context.handle(
        _pairMeta,
        pair.isAcceptableOrUnknown(data['pair']!, _pairMeta),
      );
    } else if (isInserting) {
      context.missing(_pairMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pair};
  @override
  LocalFxRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFxRate(
      pair: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pair'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $LocalFxRatesTable createAlias(String alias) {
    return $LocalFxRatesTable(attachedDatabase, alias);
  }
}

class LocalFxRate extends DataClass implements Insertable<LocalFxRate> {
  final String pair;
  final double rate;
  final DateTime fetchedAt;
  const LocalFxRate({
    required this.pair,
    required this.rate,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pair'] = Variable<String>(pair);
    map['rate'] = Variable<double>(rate);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  LocalFxRatesCompanion toCompanion(bool nullToAbsent) {
    return LocalFxRatesCompanion(
      pair: Value(pair),
      rate: Value(rate),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory LocalFxRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFxRate(
      pair: serializer.fromJson<String>(json['pair']),
      rate: serializer.fromJson<double>(json['rate']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pair': serializer.toJson<String>(pair),
      'rate': serializer.toJson<double>(rate),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  LocalFxRate copyWith({String? pair, double? rate, DateTime? fetchedAt}) =>
      LocalFxRate(
        pair: pair ?? this.pair,
        rate: rate ?? this.rate,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  LocalFxRate copyWithCompanion(LocalFxRatesCompanion data) {
    return LocalFxRate(
      pair: data.pair.present ? data.pair.value : this.pair,
      rate: data.rate.present ? data.rate.value : this.rate,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFxRate(')
          ..write('pair: $pair, ')
          ..write('rate: $rate, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pair, rate, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFxRate &&
          other.pair == this.pair &&
          other.rate == this.rate &&
          other.fetchedAt == this.fetchedAt);
}

class LocalFxRatesCompanion extends UpdateCompanion<LocalFxRate> {
  final Value<String> pair;
  final Value<double> rate;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const LocalFxRatesCompanion({
    this.pair = const Value.absent(),
    this.rate = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFxRatesCompanion.insert({
    required String pair,
    required double rate,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : pair = Value(pair),
       rate = Value(rate),
       fetchedAt = Value(fetchedAt);
  static Insertable<LocalFxRate> custom({
    Expression<String>? pair,
    Expression<double>? rate,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pair != null) 'pair': pair,
      if (rate != null) 'rate': rate,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalFxRatesCompanion copyWith({
    Value<String>? pair,
    Value<double>? rate,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return LocalFxRatesCompanion(
      pair: pair ?? this.pair,
      rate: rate ?? this.rate,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pair.present) {
      map['pair'] = Variable<String>(pair.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFxRatesCompanion(')
          ..write('pair: $pair, ')
          ..write('rate: $rate, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalIndexPointsTable extends LocalIndexPoints
    with TableInfo<$LocalIndexPointsTable, LocalIndexPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalIndexPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _indexNameMeta = const VerificationMeta(
    'indexName',
  );
  @override
  late final GeneratedColumn<String> indexName = GeneratedColumn<String>(
    'index_name',
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
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [indexName, date, rate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_index_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalIndexPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('index_name')) {
      context.handle(
        _indexNameMeta,
        indexName.isAcceptableOrUnknown(data['index_name']!, _indexNameMeta),
      );
    } else if (isInserting) {
      context.missing(_indexNameMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {indexName, date};
  @override
  LocalIndexPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalIndexPoint(
      indexName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}index_name'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
    );
  }

  @override
  $LocalIndexPointsTable createAlias(String alias) {
    return $LocalIndexPointsTable(attachedDatabase, alias);
  }
}

class LocalIndexPoint extends DataClass implements Insertable<LocalIndexPoint> {
  final String indexName;
  final DateTime date;
  final double rate;
  const LocalIndexPoint({
    required this.indexName,
    required this.date,
    required this.rate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['index_name'] = Variable<String>(indexName);
    map['date'] = Variable<DateTime>(date);
    map['rate'] = Variable<double>(rate);
    return map;
  }

  LocalIndexPointsCompanion toCompanion(bool nullToAbsent) {
    return LocalIndexPointsCompanion(
      indexName: Value(indexName),
      date: Value(date),
      rate: Value(rate),
    );
  }

  factory LocalIndexPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalIndexPoint(
      indexName: serializer.fromJson<String>(json['indexName']),
      date: serializer.fromJson<DateTime>(json['date']),
      rate: serializer.fromJson<double>(json['rate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'indexName': serializer.toJson<String>(indexName),
      'date': serializer.toJson<DateTime>(date),
      'rate': serializer.toJson<double>(rate),
    };
  }

  LocalIndexPoint copyWith({String? indexName, DateTime? date, double? rate}) =>
      LocalIndexPoint(
        indexName: indexName ?? this.indexName,
        date: date ?? this.date,
        rate: rate ?? this.rate,
      );
  LocalIndexPoint copyWithCompanion(LocalIndexPointsCompanion data) {
    return LocalIndexPoint(
      indexName: data.indexName.present ? data.indexName.value : this.indexName,
      date: data.date.present ? data.date.value : this.date,
      rate: data.rate.present ? data.rate.value : this.rate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalIndexPoint(')
          ..write('indexName: $indexName, ')
          ..write('date: $date, ')
          ..write('rate: $rate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(indexName, date, rate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalIndexPoint &&
          other.indexName == this.indexName &&
          other.date == this.date &&
          other.rate == this.rate);
}

class LocalIndexPointsCompanion extends UpdateCompanion<LocalIndexPoint> {
  final Value<String> indexName;
  final Value<DateTime> date;
  final Value<double> rate;
  final Value<int> rowid;
  const LocalIndexPointsCompanion({
    this.indexName = const Value.absent(),
    this.date = const Value.absent(),
    this.rate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalIndexPointsCompanion.insert({
    required String indexName,
    required DateTime date,
    required double rate,
    this.rowid = const Value.absent(),
  }) : indexName = Value(indexName),
       date = Value(date),
       rate = Value(rate);
  static Insertable<LocalIndexPoint> custom({
    Expression<String>? indexName,
    Expression<DateTime>? date,
    Expression<double>? rate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (indexName != null) 'index_name': indexName,
      if (date != null) 'date': date,
      if (rate != null) 'rate': rate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalIndexPointsCompanion copyWith({
    Value<String>? indexName,
    Value<DateTime>? date,
    Value<double>? rate,
    Value<int>? rowid,
  }) {
    return LocalIndexPointsCompanion(
      indexName: indexName ?? this.indexName,
      date: date ?? this.date,
      rate: rate ?? this.rate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (indexName.present) {
      map['index_name'] = Variable<String>(indexName.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalIndexPointsCompanion(')
          ..write('indexName: $indexName, ')
          ..write('date: $date, ')
          ..write('rate: $rate, ')
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
  late final $LocalBudgetsTable localBudgets = $LocalBudgetsTable(this);
  late final $LocalAssetClassesTable localAssetClasses =
      $LocalAssetClassesTable(this);
  late final $LocalAssetHoldingsTable localAssetHoldings =
      $LocalAssetHoldingsTable(this);
  late final $LocalInstitutionsTable localInstitutions =
      $LocalInstitutionsTable(this);
  late final $LocalInvestmentAssetsTable localInvestmentAssets =
      $LocalInvestmentAssetsTable(this);
  late final $LocalInvestmentTransactionsTable localInvestmentTransactions =
      $LocalInvestmentTransactionsTable(this);
  late final $LocalInvestmentSnapshotsTable localInvestmentSnapshots =
      $LocalInvestmentSnapshotsTable(this);
  late final $LocalQuotesTable localQuotes = $LocalQuotesTable(this);
  late final $LocalFxRatesTable localFxRates = $LocalFxRatesTable(this);
  late final $LocalIndexPointsTable localIndexPoints = $LocalIndexPointsTable(
    this,
  );
  late final UsersDao usersDao = UsersDao(this as AppDatabase);
  late final AccountsDao accountsDao = AccountsDao(this as AppDatabase);
  late final TransactionsDao transactionsDao = TransactionsDao(
    this as AppDatabase,
  );
  late final CategoriesDao categoriesDao = CategoriesDao(this as AppDatabase);
  late final BudgetsDao budgetsDao = BudgetsDao(this as AppDatabase);
  late final AssetClassesDao assetClassesDao = AssetClassesDao(
    this as AppDatabase,
  );
  late final AssetHoldingsDao assetHoldingsDao = AssetHoldingsDao(
    this as AppDatabase,
  );
  late final InstitutionsDao institutionsDao = InstitutionsDao(
    this as AppDatabase,
  );
  late final InvestmentAssetsDao investmentAssetsDao = InvestmentAssetsDao(
    this as AppDatabase,
  );
  late final InvestmentTransactionsDao investmentTransactionsDao =
      InvestmentTransactionsDao(this as AppDatabase);
  late final InvestmentSnapshotsDao investmentSnapshotsDao =
      InvestmentSnapshotsDao(this as AppDatabase);
  late final QuotesDao quotesDao = QuotesDao(this as AppDatabase);
  late final FxRatesDao fxRatesDao = FxRatesDao(this as AppDatabase);
  late final IndexPointsDao indexPointsDao = IndexPointsDao(
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
    localBudgets,
    localAssetClasses,
    localAssetHoldings,
    localInstitutions,
    localInvestmentAssets,
    localInvestmentTransactions,
    localInvestmentSnapshots,
    localQuotes,
    localFxRates,
    localIndexPoints,
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
typedef $$LocalInstitutionsTableCreateCompanionBuilder =
    LocalInstitutionsCompanion Function({
      required String id,
      required String userId,
      required String name,
      required String kind,
      required String currency,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalInstitutionsTableUpdateCompanionBuilder =
    LocalInstitutionsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String> kind,
      Value<String> currency,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalInstitutionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalInstitutionsTable> {
  $$LocalInstitutionsTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalInstitutionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalInstitutionsTable> {
  $$LocalInstitutionsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalInstitutionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalInstitutionsTable> {
  $$LocalInstitutionsTableAnnotationComposer({
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

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalInstitutionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalInstitutionsTable,
          LocalInstitution,
          $$LocalInstitutionsTableFilterComposer,
          $$LocalInstitutionsTableOrderingComposer,
          $$LocalInstitutionsTableAnnotationComposer,
          $$LocalInstitutionsTableCreateCompanionBuilder,
          $$LocalInstitutionsTableUpdateCompanionBuilder,
          (
            LocalInstitution,
            BaseReferences<
              _$AppDatabase,
              $LocalInstitutionsTable,
              LocalInstitution
            >,
          ),
          LocalInstitution,
          PrefetchHooks Function()
        > {
  $$LocalInstitutionsTableTableManager(
    _$AppDatabase db,
    $LocalInstitutionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalInstitutionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalInstitutionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalInstitutionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInstitutionsCompanion(
                id: id,
                userId: userId,
                name: name,
                kind: kind,
                currency: currency,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                required String kind,
                required String currency,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalInstitutionsCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                kind: kind,
                currency: currency,
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

typedef $$LocalInstitutionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalInstitutionsTable,
      LocalInstitution,
      $$LocalInstitutionsTableFilterComposer,
      $$LocalInstitutionsTableOrderingComposer,
      $$LocalInstitutionsTableAnnotationComposer,
      $$LocalInstitutionsTableCreateCompanionBuilder,
      $$LocalInstitutionsTableUpdateCompanionBuilder,
      (
        LocalInstitution,
        BaseReferences<
          _$AppDatabase,
          $LocalInstitutionsTable,
          LocalInstitution
        >,
      ),
      LocalInstitution,
      PrefetchHooks Function()
    >;
typedef $$LocalInvestmentAssetsTableCreateCompanionBuilder =
    LocalInvestmentAssetsCompanion Function({
      required String id,
      required String userId,
      required String ticker,
      required String name,
      required String kind,
      required String market,
      required String currency,
      Value<String?> institutionId,
      Value<String> metadata,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalInvestmentAssetsTableUpdateCompanionBuilder =
    LocalInvestmentAssetsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> ticker,
      Value<String> name,
      Value<String> kind,
      Value<String> market,
      Value<String> currency,
      Value<String?> institutionId,
      Value<String> metadata,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalInvestmentAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalInvestmentAssetsTable> {
  $$LocalInvestmentAssetsTableFilterComposer({
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

  ColumnFilters<String> get ticker => $composableBuilder(
    column: $table.ticker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalInvestmentAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalInvestmentAssetsTable> {
  $$LocalInvestmentAssetsTableOrderingComposer({
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

  ColumnOrderings<String> get ticker => $composableBuilder(
    column: $table.ticker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalInvestmentAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalInvestmentAssetsTable> {
  $$LocalInvestmentAssetsTableAnnotationComposer({
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

  GeneratedColumn<String> get ticker =>
      $composableBuilder(column: $table.ticker, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get market =>
      $composableBuilder(column: $table.market, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalInvestmentAssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalInvestmentAssetsTable,
          LocalInvestmentAsset,
          $$LocalInvestmentAssetsTableFilterComposer,
          $$LocalInvestmentAssetsTableOrderingComposer,
          $$LocalInvestmentAssetsTableAnnotationComposer,
          $$LocalInvestmentAssetsTableCreateCompanionBuilder,
          $$LocalInvestmentAssetsTableUpdateCompanionBuilder,
          (
            LocalInvestmentAsset,
            BaseReferences<
              _$AppDatabase,
              $LocalInvestmentAssetsTable,
              LocalInvestmentAsset
            >,
          ),
          LocalInvestmentAsset,
          PrefetchHooks Function()
        > {
  $$LocalInvestmentAssetsTableTableManager(
    _$AppDatabase db,
    $LocalInvestmentAssetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalInvestmentAssetsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalInvestmentAssetsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalInvestmentAssetsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> ticker = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> market = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> institutionId = const Value.absent(),
                Value<String> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInvestmentAssetsCompanion(
                id: id,
                userId: userId,
                ticker: ticker,
                name: name,
                kind: kind,
                market: market,
                currency: currency,
                institutionId: institutionId,
                metadata: metadata,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String ticker,
                required String name,
                required String kind,
                required String market,
                required String currency,
                Value<String?> institutionId = const Value.absent(),
                Value<String> metadata = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalInvestmentAssetsCompanion.insert(
                id: id,
                userId: userId,
                ticker: ticker,
                name: name,
                kind: kind,
                market: market,
                currency: currency,
                institutionId: institutionId,
                metadata: metadata,
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

typedef $$LocalInvestmentAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalInvestmentAssetsTable,
      LocalInvestmentAsset,
      $$LocalInvestmentAssetsTableFilterComposer,
      $$LocalInvestmentAssetsTableOrderingComposer,
      $$LocalInvestmentAssetsTableAnnotationComposer,
      $$LocalInvestmentAssetsTableCreateCompanionBuilder,
      $$LocalInvestmentAssetsTableUpdateCompanionBuilder,
      (
        LocalInvestmentAsset,
        BaseReferences<
          _$AppDatabase,
          $LocalInvestmentAssetsTable,
          LocalInvestmentAsset
        >,
      ),
      LocalInvestmentAsset,
      PrefetchHooks Function()
    >;
typedef $$LocalInvestmentTransactionsTableCreateCompanionBuilder =
    LocalInvestmentTransactionsCompanion Function({
      required String id,
      required String userId,
      required String institutionId,
      required String assetId,
      required String kind,
      required double quantity,
      required int unitPriceMinor,
      required int feesMinor,
      required int amountMinor,
      required String currency,
      required DateTime date,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalInvestmentTransactionsTableUpdateCompanionBuilder =
    LocalInvestmentTransactionsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> institutionId,
      Value<String> assetId,
      Value<String> kind,
      Value<double> quantity,
      Value<int> unitPriceMinor,
      Value<int> feesMinor,
      Value<int> amountMinor,
      Value<String> currency,
      Value<DateTime> date,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalInvestmentTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalInvestmentTransactionsTable> {
  $$LocalInvestmentTransactionsTableFilterComposer({
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

  ColumnFilters<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feesMinor => $composableBuilder(
    column: $table.feesMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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

class $$LocalInvestmentTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalInvestmentTransactionsTable> {
  $$LocalInvestmentTransactionsTableOrderingComposer({
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

  ColumnOrderings<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feesMinor => $composableBuilder(
    column: $table.feesMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

class $$LocalInvestmentTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalInvestmentTransactionsTable> {
  $$LocalInvestmentTransactionsTableAnnotationComposer({
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

  GeneratedColumn<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get feesMinor =>
      $composableBuilder(column: $table.feesMinor, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalInvestmentTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalInvestmentTransactionsTable,
          LocalInvestmentTransaction,
          $$LocalInvestmentTransactionsTableFilterComposer,
          $$LocalInvestmentTransactionsTableOrderingComposer,
          $$LocalInvestmentTransactionsTableAnnotationComposer,
          $$LocalInvestmentTransactionsTableCreateCompanionBuilder,
          $$LocalInvestmentTransactionsTableUpdateCompanionBuilder,
          (
            LocalInvestmentTransaction,
            BaseReferences<
              _$AppDatabase,
              $LocalInvestmentTransactionsTable,
              LocalInvestmentTransaction
            >,
          ),
          LocalInvestmentTransaction,
          PrefetchHooks Function()
        > {
  $$LocalInvestmentTransactionsTableTableManager(
    _$AppDatabase db,
    $LocalInvestmentTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalInvestmentTransactionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalInvestmentTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalInvestmentTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> institutionId = const Value.absent(),
                Value<String> assetId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<int> unitPriceMinor = const Value.absent(),
                Value<int> feesMinor = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInvestmentTransactionsCompanion(
                id: id,
                userId: userId,
                institutionId: institutionId,
                assetId: assetId,
                kind: kind,
                quantity: quantity,
                unitPriceMinor: unitPriceMinor,
                feesMinor: feesMinor,
                amountMinor: amountMinor,
                currency: currency,
                date: date,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String institutionId,
                required String assetId,
                required String kind,
                required double quantity,
                required int unitPriceMinor,
                required int feesMinor,
                required int amountMinor,
                required String currency,
                required DateTime date,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalInvestmentTransactionsCompanion.insert(
                id: id,
                userId: userId,
                institutionId: institutionId,
                assetId: assetId,
                kind: kind,
                quantity: quantity,
                unitPriceMinor: unitPriceMinor,
                feesMinor: feesMinor,
                amountMinor: amountMinor,
                currency: currency,
                date: date,
                notes: notes,
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

typedef $$LocalInvestmentTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalInvestmentTransactionsTable,
      LocalInvestmentTransaction,
      $$LocalInvestmentTransactionsTableFilterComposer,
      $$LocalInvestmentTransactionsTableOrderingComposer,
      $$LocalInvestmentTransactionsTableAnnotationComposer,
      $$LocalInvestmentTransactionsTableCreateCompanionBuilder,
      $$LocalInvestmentTransactionsTableUpdateCompanionBuilder,
      (
        LocalInvestmentTransaction,
        BaseReferences<
          _$AppDatabase,
          $LocalInvestmentTransactionsTable,
          LocalInvestmentTransaction
        >,
      ),
      LocalInvestmentTransaction,
      PrefetchHooks Function()
    >;
typedef $$LocalInvestmentSnapshotsTableCreateCompanionBuilder =
    LocalInvestmentSnapshotsCompanion Function({
      required String id,
      required String userId,
      required DateTime date,
      required int totalValueMinor,
      required int totalInvestedMinor,
      required int unrealizedPlMinor,
      required String currency,
      Value<int> rowid,
    });
typedef $$LocalInvestmentSnapshotsTableUpdateCompanionBuilder =
    LocalInvestmentSnapshotsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<DateTime> date,
      Value<int> totalValueMinor,
      Value<int> totalInvestedMinor,
      Value<int> unrealizedPlMinor,
      Value<String> currency,
      Value<int> rowid,
    });

class $$LocalInvestmentSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalInvestmentSnapshotsTable> {
  $$LocalInvestmentSnapshotsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalValueMinor => $composableBuilder(
    column: $table.totalValueMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalInvestedMinor => $composableBuilder(
    column: $table.totalInvestedMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unrealizedPlMinor => $composableBuilder(
    column: $table.unrealizedPlMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalInvestmentSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalInvestmentSnapshotsTable> {
  $$LocalInvestmentSnapshotsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalValueMinor => $composableBuilder(
    column: $table.totalValueMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalInvestedMinor => $composableBuilder(
    column: $table.totalInvestedMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unrealizedPlMinor => $composableBuilder(
    column: $table.unrealizedPlMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalInvestmentSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalInvestmentSnapshotsTable> {
  $$LocalInvestmentSnapshotsTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get totalValueMinor => $composableBuilder(
    column: $table.totalValueMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalInvestedMinor => $composableBuilder(
    column: $table.totalInvestedMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unrealizedPlMinor => $composableBuilder(
    column: $table.unrealizedPlMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);
}

class $$LocalInvestmentSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalInvestmentSnapshotsTable,
          LocalInvestmentSnapshot,
          $$LocalInvestmentSnapshotsTableFilterComposer,
          $$LocalInvestmentSnapshotsTableOrderingComposer,
          $$LocalInvestmentSnapshotsTableAnnotationComposer,
          $$LocalInvestmentSnapshotsTableCreateCompanionBuilder,
          $$LocalInvestmentSnapshotsTableUpdateCompanionBuilder,
          (
            LocalInvestmentSnapshot,
            BaseReferences<
              _$AppDatabase,
              $LocalInvestmentSnapshotsTable,
              LocalInvestmentSnapshot
            >,
          ),
          LocalInvestmentSnapshot,
          PrefetchHooks Function()
        > {
  $$LocalInvestmentSnapshotsTableTableManager(
    _$AppDatabase db,
    $LocalInvestmentSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalInvestmentSnapshotsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalInvestmentSnapshotsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalInvestmentSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> totalValueMinor = const Value.absent(),
                Value<int> totalInvestedMinor = const Value.absent(),
                Value<int> unrealizedPlMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInvestmentSnapshotsCompanion(
                id: id,
                userId: userId,
                date: date,
                totalValueMinor: totalValueMinor,
                totalInvestedMinor: totalInvestedMinor,
                unrealizedPlMinor: unrealizedPlMinor,
                currency: currency,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required DateTime date,
                required int totalValueMinor,
                required int totalInvestedMinor,
                required int unrealizedPlMinor,
                required String currency,
                Value<int> rowid = const Value.absent(),
              }) => LocalInvestmentSnapshotsCompanion.insert(
                id: id,
                userId: userId,
                date: date,
                totalValueMinor: totalValueMinor,
                totalInvestedMinor: totalInvestedMinor,
                unrealizedPlMinor: unrealizedPlMinor,
                currency: currency,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalInvestmentSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalInvestmentSnapshotsTable,
      LocalInvestmentSnapshot,
      $$LocalInvestmentSnapshotsTableFilterComposer,
      $$LocalInvestmentSnapshotsTableOrderingComposer,
      $$LocalInvestmentSnapshotsTableAnnotationComposer,
      $$LocalInvestmentSnapshotsTableCreateCompanionBuilder,
      $$LocalInvestmentSnapshotsTableUpdateCompanionBuilder,
      (
        LocalInvestmentSnapshot,
        BaseReferences<
          _$AppDatabase,
          $LocalInvestmentSnapshotsTable,
          LocalInvestmentSnapshot
        >,
      ),
      LocalInvestmentSnapshot,
      PrefetchHooks Function()
    >;
typedef $$LocalQuotesTableCreateCompanionBuilder =
    LocalQuotesCompanion Function({
      required String assetId,
      required int unitPriceMinor,
      Value<int?> previousCloseMinor,
      required String currency,
      required DateTime asOf,
      required DateTime fetchedAt,
      required String source,
      Value<int> rowid,
    });
typedef $$LocalQuotesTableUpdateCompanionBuilder =
    LocalQuotesCompanion Function({
      Value<String> assetId,
      Value<int> unitPriceMinor,
      Value<int?> previousCloseMinor,
      Value<String> currency,
      Value<DateTime> asOf,
      Value<DateTime> fetchedAt,
      Value<String> source,
      Value<int> rowid,
    });

class $$LocalQuotesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalQuotesTable> {
  $$LocalQuotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get previousCloseMinor => $composableBuilder(
    column: $table.previousCloseMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get asOf => $composableBuilder(
    column: $table.asOf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalQuotesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalQuotesTable> {
  $$LocalQuotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previousCloseMinor => $composableBuilder(
    column: $table.previousCloseMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get asOf => $composableBuilder(
    column: $table.asOf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalQuotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalQuotesTable> {
  $$LocalQuotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get previousCloseMinor => $composableBuilder(
    column: $table.previousCloseMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get asOf =>
      $composableBuilder(column: $table.asOf, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$LocalQuotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalQuotesTable,
          LocalQuote,
          $$LocalQuotesTableFilterComposer,
          $$LocalQuotesTableOrderingComposer,
          $$LocalQuotesTableAnnotationComposer,
          $$LocalQuotesTableCreateCompanionBuilder,
          $$LocalQuotesTableUpdateCompanionBuilder,
          (
            LocalQuote,
            BaseReferences<_$AppDatabase, $LocalQuotesTable, LocalQuote>,
          ),
          LocalQuote,
          PrefetchHooks Function()
        > {
  $$LocalQuotesTableTableManager(_$AppDatabase db, $LocalQuotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalQuotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalQuotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalQuotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> assetId = const Value.absent(),
                Value<int> unitPriceMinor = const Value.absent(),
                Value<int?> previousCloseMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> asOf = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalQuotesCompanion(
                assetId: assetId,
                unitPriceMinor: unitPriceMinor,
                previousCloseMinor: previousCloseMinor,
                currency: currency,
                asOf: asOf,
                fetchedAt: fetchedAt,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String assetId,
                required int unitPriceMinor,
                Value<int?> previousCloseMinor = const Value.absent(),
                required String currency,
                required DateTime asOf,
                required DateTime fetchedAt,
                required String source,
                Value<int> rowid = const Value.absent(),
              }) => LocalQuotesCompanion.insert(
                assetId: assetId,
                unitPriceMinor: unitPriceMinor,
                previousCloseMinor: previousCloseMinor,
                currency: currency,
                asOf: asOf,
                fetchedAt: fetchedAt,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalQuotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalQuotesTable,
      LocalQuote,
      $$LocalQuotesTableFilterComposer,
      $$LocalQuotesTableOrderingComposer,
      $$LocalQuotesTableAnnotationComposer,
      $$LocalQuotesTableCreateCompanionBuilder,
      $$LocalQuotesTableUpdateCompanionBuilder,
      (
        LocalQuote,
        BaseReferences<_$AppDatabase, $LocalQuotesTable, LocalQuote>,
      ),
      LocalQuote,
      PrefetchHooks Function()
    >;
typedef $$LocalFxRatesTableCreateCompanionBuilder =
    LocalFxRatesCompanion Function({
      required String pair,
      required double rate,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$LocalFxRatesTableUpdateCompanionBuilder =
    LocalFxRatesCompanion Function({
      Value<String> pair,
      Value<double> rate,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$LocalFxRatesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalFxRatesTable> {
  $$LocalFxRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get pair => $composableBuilder(
    column: $table.pair,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalFxRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalFxRatesTable> {
  $$LocalFxRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get pair => $composableBuilder(
    column: $table.pair,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalFxRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalFxRatesTable> {
  $$LocalFxRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get pair =>
      $composableBuilder(column: $table.pair, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$LocalFxRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalFxRatesTable,
          LocalFxRate,
          $$LocalFxRatesTableFilterComposer,
          $$LocalFxRatesTableOrderingComposer,
          $$LocalFxRatesTableAnnotationComposer,
          $$LocalFxRatesTableCreateCompanionBuilder,
          $$LocalFxRatesTableUpdateCompanionBuilder,
          (
            LocalFxRate,
            BaseReferences<_$AppDatabase, $LocalFxRatesTable, LocalFxRate>,
          ),
          LocalFxRate,
          PrefetchHooks Function()
        > {
  $$LocalFxRatesTableTableManager(_$AppDatabase db, $LocalFxRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFxRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFxRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalFxRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> pair = const Value.absent(),
                Value<double> rate = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalFxRatesCompanion(
                pair: pair,
                rate: rate,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pair,
                required double rate,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalFxRatesCompanion.insert(
                pair: pair,
                rate: rate,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalFxRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalFxRatesTable,
      LocalFxRate,
      $$LocalFxRatesTableFilterComposer,
      $$LocalFxRatesTableOrderingComposer,
      $$LocalFxRatesTableAnnotationComposer,
      $$LocalFxRatesTableCreateCompanionBuilder,
      $$LocalFxRatesTableUpdateCompanionBuilder,
      (
        LocalFxRate,
        BaseReferences<_$AppDatabase, $LocalFxRatesTable, LocalFxRate>,
      ),
      LocalFxRate,
      PrefetchHooks Function()
    >;
typedef $$LocalIndexPointsTableCreateCompanionBuilder =
    LocalIndexPointsCompanion Function({
      required String indexName,
      required DateTime date,
      required double rate,
      Value<int> rowid,
    });
typedef $$LocalIndexPointsTableUpdateCompanionBuilder =
    LocalIndexPointsCompanion Function({
      Value<String> indexName,
      Value<DateTime> date,
      Value<double> rate,
      Value<int> rowid,
    });

class $$LocalIndexPointsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalIndexPointsTable> {
  $$LocalIndexPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get indexName => $composableBuilder(
    column: $table.indexName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalIndexPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalIndexPointsTable> {
  $$LocalIndexPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get indexName => $composableBuilder(
    column: $table.indexName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalIndexPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalIndexPointsTable> {
  $$LocalIndexPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get indexName =>
      $composableBuilder(column: $table.indexName, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);
}

class $$LocalIndexPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalIndexPointsTable,
          LocalIndexPoint,
          $$LocalIndexPointsTableFilterComposer,
          $$LocalIndexPointsTableOrderingComposer,
          $$LocalIndexPointsTableAnnotationComposer,
          $$LocalIndexPointsTableCreateCompanionBuilder,
          $$LocalIndexPointsTableUpdateCompanionBuilder,
          (
            LocalIndexPoint,
            BaseReferences<
              _$AppDatabase,
              $LocalIndexPointsTable,
              LocalIndexPoint
            >,
          ),
          LocalIndexPoint,
          PrefetchHooks Function()
        > {
  $$LocalIndexPointsTableTableManager(
    _$AppDatabase db,
    $LocalIndexPointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalIndexPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalIndexPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalIndexPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> indexName = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> rate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalIndexPointsCompanion(
                indexName: indexName,
                date: date,
                rate: rate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String indexName,
                required DateTime date,
                required double rate,
                Value<int> rowid = const Value.absent(),
              }) => LocalIndexPointsCompanion.insert(
                indexName: indexName,
                date: date,
                rate: rate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalIndexPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalIndexPointsTable,
      LocalIndexPoint,
      $$LocalIndexPointsTableFilterComposer,
      $$LocalIndexPointsTableOrderingComposer,
      $$LocalIndexPointsTableAnnotationComposer,
      $$LocalIndexPointsTableCreateCompanionBuilder,
      $$LocalIndexPointsTableUpdateCompanionBuilder,
      (
        LocalIndexPoint,
        BaseReferences<_$AppDatabase, $LocalIndexPointsTable, LocalIndexPoint>,
      ),
      LocalIndexPoint,
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
  $$LocalBudgetsTableTableManager get localBudgets =>
      $$LocalBudgetsTableTableManager(_db, _db.localBudgets);
  $$LocalAssetClassesTableTableManager get localAssetClasses =>
      $$LocalAssetClassesTableTableManager(_db, _db.localAssetClasses);
  $$LocalAssetHoldingsTableTableManager get localAssetHoldings =>
      $$LocalAssetHoldingsTableTableManager(_db, _db.localAssetHoldings);
  $$LocalInstitutionsTableTableManager get localInstitutions =>
      $$LocalInstitutionsTableTableManager(_db, _db.localInstitutions);
  $$LocalInvestmentAssetsTableTableManager get localInvestmentAssets =>
      $$LocalInvestmentAssetsTableTableManager(_db, _db.localInvestmentAssets);
  $$LocalInvestmentTransactionsTableTableManager
  get localInvestmentTransactions =>
      $$LocalInvestmentTransactionsTableTableManager(
        _db,
        _db.localInvestmentTransactions,
      );
  $$LocalInvestmentSnapshotsTableTableManager get localInvestmentSnapshots =>
      $$LocalInvestmentSnapshotsTableTableManager(
        _db,
        _db.localInvestmentSnapshots,
      );
  $$LocalQuotesTableTableManager get localQuotes =>
      $$LocalQuotesTableTableManager(_db, _db.localQuotes);
  $$LocalFxRatesTableTableManager get localFxRates =>
      $$LocalFxRatesTableTableManager(_db, _db.localFxRates);
  $$LocalIndexPointsTableTableManager get localIndexPoints =>
      $$LocalIndexPointsTableTableManager(_db, _db.localIndexPoints);
}
