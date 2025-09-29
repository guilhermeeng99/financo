// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_manager.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 15,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AccountIconType, String>
  iconType = GeneratedColumn<String>(
    'icon_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<AccountIconType>($AccountsTable.$convertericonType);
  @override
  late final GeneratedColumnWithTypeConverter<AccountType, String> accountType =
      GeneratedColumn<String>(
        'account_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AccountType>($AccountsTable.$converteraccountType);
  static const VerificationMeta _initialBalanceMeta = const VerificationMeta(
    'initialBalance',
  );
  @override
  late final GeneratedColumn<double> initialBalance = GeneratedColumn<double>(
    'initial_balance',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CurrencyType, String>
  currencyType = GeneratedColumn<String>(
    'currency_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<CurrencyType>($AccountsTable.$convertercurrencyType);
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
  static const VerificationMeta _initDateMeta = const VerificationMeta(
    'initDate',
  );
  @override
  late final GeneratedColumn<DateTime> initDate = GeneratedColumn<DateTime>(
    'init_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
  static const VerificationMeta _firstBillDueDateMeta = const VerificationMeta(
    'firstBillDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> firstBillDueDate =
      GeneratedColumn<DateTime>(
        'first_bill_due_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _billClosingDayMeta = const VerificationMeta(
    'billClosingDay',
  );
  @override
  late final GeneratedColumn<int> billClosingDay = GeneratedColumn<int>(
    'bill_closing_day',
    aliasedName,
    true,
    check: () => const CustomExpression(
      'bill_closing_day >= 1 AND bill_closing_day <= 31',
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentAccountIdMeta = const VerificationMeta(
    'paymentAccountId',
  );
  @override
  late final GeneratedColumn<int> paymentAccountId = GeneratedColumn<int>(
    'payment_account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconType,
    accountType,
    initialBalance,
    currencyType,
    isActive,
    initDate,
    creditLimit,
    firstBillDueDate,
    billClosingDay,
    paymentAccountId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('initial_balance')) {
      context.handle(
        _initialBalanceMeta,
        initialBalance.isAcceptableOrUnknown(
          data['initial_balance']!,
          _initialBalanceMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('init_date')) {
      context.handle(
        _initDateMeta,
        initDate.isAcceptableOrUnknown(data['init_date']!, _initDateMeta),
      );
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
    if (data.containsKey('first_bill_due_date')) {
      context.handle(
        _firstBillDueDateMeta,
        firstBillDueDate.isAcceptableOrUnknown(
          data['first_bill_due_date']!,
          _firstBillDueDateMeta,
        ),
      );
    }
    if (data.containsKey('bill_closing_day')) {
      context.handle(
        _billClosingDayMeta,
        billClosingDay.isAcceptableOrUnknown(
          data['bill_closing_day']!,
          _billClosingDayMeta,
        ),
      );
    }
    if (data.containsKey('payment_account_id')) {
      context.handle(
        _paymentAccountIdMeta,
        paymentAccountId.isAcceptableOrUnknown(
          data['payment_account_id']!,
          _paymentAccountIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconType: $AccountsTable.$convertericonType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}icon_type'],
        )!,
      ),
      accountType: $AccountsTable.$converteraccountType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}account_type'],
        )!,
      ),
      currencyType: $AccountsTable.$convertercurrencyType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}currency_type'],
        )!,
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      initDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}init_date'],
      )!,
      initialBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}initial_balance'],
      ),
      creditLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit_limit'],
      ),
      firstBillDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_bill_due_date'],
      ),
      billClosingDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bill_closing_day'],
      ),
      paymentAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_account_id'],
      ),
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AccountIconType, String, String>
  $convertericonType = const EnumNameConverter<AccountIconType>(
    AccountIconType.values,
  );
  static JsonTypeConverter2<AccountType, String, String> $converteraccountType =
      const EnumNameConverter<AccountType>(AccountType.values);
  static JsonTypeConverter2<CurrencyType, String, String>
  $convertercurrencyType = const EnumNameConverter<CurrencyType>(
    CurrencyType.values,
  );
}

class AccountsCompanion extends UpdateCompanion<AccountData> {
  final Value<int> id;
  final Value<String> name;
  final Value<AccountIconType> iconType;
  final Value<AccountType> accountType;
  final Value<double?> initialBalance;
  final Value<CurrencyType> currencyType;
  final Value<bool> isActive;
  final Value<DateTime> initDate;
  final Value<double?> creditLimit;
  final Value<DateTime?> firstBillDueDate;
  final Value<int?> billClosingDay;
  final Value<int?> paymentAccountId;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconType = const Value.absent(),
    this.accountType = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.currencyType = const Value.absent(),
    this.isActive = const Value.absent(),
    this.initDate = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.firstBillDueDate = const Value.absent(),
    this.billClosingDay = const Value.absent(),
    this.paymentAccountId = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required AccountIconType iconType,
    required AccountType accountType,
    this.initialBalance = const Value.absent(),
    required CurrencyType currencyType,
    this.isActive = const Value.absent(),
    this.initDate = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.firstBillDueDate = const Value.absent(),
    this.billClosingDay = const Value.absent(),
    this.paymentAccountId = const Value.absent(),
  }) : name = Value(name),
       iconType = Value(iconType),
       accountType = Value(accountType),
       currencyType = Value(currencyType);
  static Insertable<AccountData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? iconType,
    Expression<String>? accountType,
    Expression<double>? initialBalance,
    Expression<String>? currencyType,
    Expression<bool>? isActive,
    Expression<DateTime>? initDate,
    Expression<double>? creditLimit,
    Expression<DateTime>? firstBillDueDate,
    Expression<int>? billClosingDay,
    Expression<int>? paymentAccountId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconType != null) 'icon_type': iconType,
      if (accountType != null) 'account_type': accountType,
      if (initialBalance != null) 'initial_balance': initialBalance,
      if (currencyType != null) 'currency_type': currencyType,
      if (isActive != null) 'is_active': isActive,
      if (initDate != null) 'init_date': initDate,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (firstBillDueDate != null) 'first_bill_due_date': firstBillDueDate,
      if (billClosingDay != null) 'bill_closing_day': billClosingDay,
      if (paymentAccountId != null) 'payment_account_id': paymentAccountId,
    });
  }

  AccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<AccountIconType>? iconType,
    Value<AccountType>? accountType,
    Value<double?>? initialBalance,
    Value<CurrencyType>? currencyType,
    Value<bool>? isActive,
    Value<DateTime>? initDate,
    Value<double?>? creditLimit,
    Value<DateTime?>? firstBillDueDate,
    Value<int?>? billClosingDay,
    Value<int?>? paymentAccountId,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconType: iconType ?? this.iconType,
      accountType: accountType ?? this.accountType,
      initialBalance: initialBalance ?? this.initialBalance,
      currencyType: currencyType ?? this.currencyType,
      isActive: isActive ?? this.isActive,
      initDate: initDate ?? this.initDate,
      creditLimit: creditLimit ?? this.creditLimit,
      firstBillDueDate: firstBillDueDate ?? this.firstBillDueDate,
      billClosingDay: billClosingDay ?? this.billClosingDay,
      paymentAccountId: paymentAccountId ?? this.paymentAccountId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconType.present) {
      map['icon_type'] = Variable<String>(
        $AccountsTable.$convertericonType.toSql(iconType.value),
      );
    }
    if (accountType.present) {
      map['account_type'] = Variable<String>(
        $AccountsTable.$converteraccountType.toSql(accountType.value),
      );
    }
    if (initialBalance.present) {
      map['initial_balance'] = Variable<double>(initialBalance.value);
    }
    if (currencyType.present) {
      map['currency_type'] = Variable<String>(
        $AccountsTable.$convertercurrencyType.toSql(currencyType.value),
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (initDate.present) {
      map['init_date'] = Variable<DateTime>(initDate.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (firstBillDueDate.present) {
      map['first_bill_due_date'] = Variable<DateTime>(firstBillDueDate.value);
    }
    if (billClosingDay.present) {
      map['bill_closing_day'] = Variable<int>(billClosingDay.value);
    }
    if (paymentAccountId.present) {
      map['payment_account_id'] = Variable<int>(paymentAccountId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconType: $iconType, ')
          ..write('accountType: $accountType, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('currencyType: $currencyType, ')
          ..write('isActive: $isActive, ')
          ..write('initDate: $initDate, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('firstBillDueDate: $firstBillDueDate, ')
          ..write('billClosingDay: $billClosingDay, ')
          ..write('paymentAccountId: $paymentAccountId')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FinancialType, String>
  categoryType = GeneratedColumn<String>(
    'category_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<FinancialType>($CategoriesTable.$convertercategoryType);
  static const VerificationMeta _parentCategoryIdMeta = const VerificationMeta(
    'parentCategoryId',
  );
  @override
  late final GeneratedColumn<int> parentCategoryId = GeneratedColumn<int>(
    'parent_category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    categoryType,
    parentCategoryId,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_category_id')) {
      context.handle(
        _parentCategoryIdMeta,
        parentCategoryId.isAcceptableOrUnknown(
          data['parent_category_id']!,
          _parentCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {name, categoryType},
  ];
  @override
  CategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      categoryType: $CategoriesTable.$convertercategoryType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category_type'],
        )!,
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      parentCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_category_id'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FinancialType, String, String>
  $convertercategoryType = const EnumNameConverter<FinancialType>(
    FinancialType.values,
  );
}

class CategoriesCompanion extends UpdateCompanion<CategoryData> {
  final Value<int> id;
  final Value<String> name;
  final Value<FinancialType> categoryType;
  final Value<int?> parentCategoryId;
  final Value<bool> isActive;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryType = const Value.absent(),
    this.parentCategoryId = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required FinancialType categoryType,
    this.parentCategoryId = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : name = Value(name),
       categoryType = Value(categoryType);
  static Insertable<CategoryData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? categoryType,
    Expression<int>? parentCategoryId,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (categoryType != null) 'category_type': categoryType,
      if (parentCategoryId != null) 'parent_category_id': parentCategoryId,
      if (isActive != null) 'is_active': isActive,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<FinancialType>? categoryType,
    Value<int?>? parentCategoryId,
    Value<bool>? isActive,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryType: categoryType ?? this.categoryType,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryType.present) {
      map['category_type'] = Variable<String>(
        $CategoriesTable.$convertercategoryType.toSql(categoryType.value),
      );
    }
    if (parentCategoryId.present) {
      map['parent_category_id'] = Variable<int>(parentCategoryId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryType: $categoryType, ')
          ..write('parentCategoryId: $parentCategoryId, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, DataTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<FinancialType, String>
  transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<FinancialType>($TransactionsTable.$convertertransactionType);
  static const VerificationMeta _actualDateMeta = const VerificationMeta(
    'actualDate',
  );
  @override
  late final GeneratedColumn<DateTime> actualDate = GeneratedColumn<DateTime>(
    'actual_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _competenceDateMeta = const VerificationMeta(
    'competenceDate',
  );
  @override
  late final GeneratedColumn<DateTime> competenceDate =
      GeneratedColumn<DateTime>(
        'competence_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
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
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TransactionPaymentStatus, String>
  paymentStatus =
      GeneratedColumn<String>(
        'payment_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TransactionPaymentStatus>(
        $TransactionsTable.$converterpaymentStatus,
      );
  @override
  late final GeneratedColumnWithTypeConverter<TransactionRecurrenceType, String>
  recurrenceType =
      GeneratedColumn<String>(
        'recurrence_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TransactionRecurrenceType>(
        $TransactionsTable.$converterrecurrenceType,
      );
  @override
  late final GeneratedColumnWithTypeConverter<
    TransactionRecurrenceFrequency?,
    String
  >
  recurrenceFrequency =
      GeneratedColumn<String>(
        'recurrence_frequency',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<TransactionRecurrenceFrequency?>(
        $TransactionsTable.$converterrecurrenceFrequencyn,
      );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _targetAccountIdMeta = const VerificationMeta(
    'targetAccountId',
  );
  @override
  late final GeneratedColumn<int> targetAccountId = GeneratedColumn<int>(
    'target_account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _transferIdMeta = const VerificationMeta(
    'transferId',
  );
  @override
  late final GeneratedColumn<String> transferId = GeneratedColumn<String>(
    'transfer_id',
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
    transactionType,
    actualDate,
    competenceDate,
    amount,
    description,
    paymentStatus,
    recurrenceType,
    recurrenceFrequency,
    accountId,
    categoryId,
    targetAccountId,
    transferId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DataTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('actual_date')) {
      context.handle(
        _actualDateMeta,
        actualDate.isAcceptableOrUnknown(data['actual_date']!, _actualDateMeta),
      );
    } else if (isInserting) {
      context.missing(_actualDateMeta);
    }
    if (data.containsKey('competence_date')) {
      context.handle(
        _competenceDateMeta,
        competenceDate.isAcceptableOrUnknown(
          data['competence_date']!,
          _competenceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_competenceDateMeta);
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
    }
    if (data.containsKey('target_account_id')) {
      context.handle(
        _targetAccountIdMeta,
        targetAccountId.isAcceptableOrUnknown(
          data['target_account_id']!,
          _targetAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('transfer_id')) {
      context.handle(
        _transferIdMeta,
        transferId.isAcceptableOrUnknown(data['transfer_id']!, _transferIdMeta),
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
  DataTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DataTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      transactionType: $TransactionsTable.$convertertransactionType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}transaction_type'],
        )!,
      ),
      actualDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actual_date'],
      )!,
      competenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}competence_date'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      paymentStatus: $TransactionsTable.$converterpaymentStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payment_status'],
        )!,
      ),
      recurrenceType: $TransactionsTable.$converterrecurrenceType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}recurrence_type'],
        )!,
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      recurrenceFrequency: $TransactionsTable.$converterrecurrenceFrequencyn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}recurrence_frequency'],
            ),
          ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      targetAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_account_id'],
      ),
      transferId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_id'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FinancialType, String, String>
  $convertertransactionType = const EnumNameConverter<FinancialType>(
    FinancialType.values,
  );
  static JsonTypeConverter2<TransactionPaymentStatus, String, String>
  $converterpaymentStatus = const EnumNameConverter<TransactionPaymentStatus>(
    TransactionPaymentStatus.values,
  );
  static JsonTypeConverter2<TransactionRecurrenceType, String, String>
  $converterrecurrenceType = const EnumNameConverter<TransactionRecurrenceType>(
    TransactionRecurrenceType.values,
  );
  static JsonTypeConverter2<TransactionRecurrenceFrequency, String, String>
  $converterrecurrenceFrequency =
      const EnumNameConverter<TransactionRecurrenceFrequency>(
        TransactionRecurrenceFrequency.values,
      );
  static JsonTypeConverter2<TransactionRecurrenceFrequency?, String?, String?>
  $converterrecurrenceFrequencyn = JsonTypeConverter2.asNullable(
    $converterrecurrenceFrequency,
  );
}

class TransactionsCompanion extends UpdateCompanion<DataTransaction> {
  final Value<int> id;
  final Value<FinancialType> transactionType;
  final Value<DateTime> actualDate;
  final Value<DateTime> competenceDate;
  final Value<double> amount;
  final Value<String?> description;
  final Value<TransactionPaymentStatus> paymentStatus;
  final Value<TransactionRecurrenceType> recurrenceType;
  final Value<TransactionRecurrenceFrequency?> recurrenceFrequency;
  final Value<int> accountId;
  final Value<int?> categoryId;
  final Value<int?> targetAccountId;
  final Value<String?> transferId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.actualDate = const Value.absent(),
    this.competenceDate = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.recurrenceType = const Value.absent(),
    this.recurrenceFrequency = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.targetAccountId = const Value.absent(),
    this.transferId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required FinancialType transactionType,
    required DateTime actualDate,
    required DateTime competenceDate,
    required double amount,
    this.description = const Value.absent(),
    required TransactionPaymentStatus paymentStatus,
    required TransactionRecurrenceType recurrenceType,
    this.recurrenceFrequency = const Value.absent(),
    required int accountId,
    this.categoryId = const Value.absent(),
    this.targetAccountId = const Value.absent(),
    this.transferId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : transactionType = Value(transactionType),
       actualDate = Value(actualDate),
       competenceDate = Value(competenceDate),
       amount = Value(amount),
       paymentStatus = Value(paymentStatus),
       recurrenceType = Value(recurrenceType),
       accountId = Value(accountId);
  static Insertable<DataTransaction> custom({
    Expression<int>? id,
    Expression<String>? transactionType,
    Expression<DateTime>? actualDate,
    Expression<DateTime>? competenceDate,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<String>? paymentStatus,
    Expression<String>? recurrenceType,
    Expression<String>? recurrenceFrequency,
    Expression<int>? accountId,
    Expression<int>? categoryId,
    Expression<int>? targetAccountId,
    Expression<String>? transferId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionType != null) 'transaction_type': transactionType,
      if (actualDate != null) 'actual_date': actualDate,
      if (competenceDate != null) 'competence_date': competenceDate,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (recurrenceType != null) 'recurrence_type': recurrenceType,
      if (recurrenceFrequency != null)
        'recurrence_frequency': recurrenceFrequency,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (targetAccountId != null) 'target_account_id': targetAccountId,
      if (transferId != null) 'transfer_id': transferId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<FinancialType>? transactionType,
    Value<DateTime>? actualDate,
    Value<DateTime>? competenceDate,
    Value<double>? amount,
    Value<String?>? description,
    Value<TransactionPaymentStatus>? paymentStatus,
    Value<TransactionRecurrenceType>? recurrenceType,
    Value<TransactionRecurrenceFrequency?>? recurrenceFrequency,
    Value<int>? accountId,
    Value<int?>? categoryId,
    Value<int?>? targetAccountId,
    Value<String?>? transferId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      transactionType: transactionType ?? this.transactionType,
      actualDate: actualDate ?? this.actualDate,
      competenceDate: competenceDate ?? this.competenceDate,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceFrequency: recurrenceFrequency ?? this.recurrenceFrequency,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      targetAccountId: targetAccountId ?? this.targetAccountId,
      transferId: transferId ?? this.transferId,
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
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(
        $TransactionsTable.$convertertransactionType.toSql(
          transactionType.value,
        ),
      );
    }
    if (actualDate.present) {
      map['actual_date'] = Variable<DateTime>(actualDate.value);
    }
    if (competenceDate.present) {
      map['competence_date'] = Variable<DateTime>(competenceDate.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(
        $TransactionsTable.$converterpaymentStatus.toSql(paymentStatus.value),
      );
    }
    if (recurrenceType.present) {
      map['recurrence_type'] = Variable<String>(
        $TransactionsTable.$converterrecurrenceType.toSql(recurrenceType.value),
      );
    }
    if (recurrenceFrequency.present) {
      map['recurrence_frequency'] = Variable<String>(
        $TransactionsTable.$converterrecurrenceFrequencyn.toSql(
          recurrenceFrequency.value,
        ),
      );
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (targetAccountId.present) {
      map['target_account_id'] = Variable<int>(targetAccountId.value);
    }
    if (transferId.present) {
      map['transfer_id'] = Variable<String>(transferId.value);
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
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('transactionType: $transactionType, ')
          ..write('actualDate: $actualDate, ')
          ..write('competenceDate: $competenceDate, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('recurrenceType: $recurrenceType, ')
          ..write('recurrenceFrequency: $recurrenceFrequency, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('targetAccountId: $targetAccountId, ')
          ..write('transferId: $transferId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$DatabaseManager extends GeneratedDatabase {
  _$DatabaseManager(QueryExecutor e) : super(e);
  $DatabaseManagerManager get managers => $DatabaseManagerManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    categories,
    transactions,
  ];
}

typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      Value<int> id,
      required String name,
      required AccountIconType iconType,
      required AccountType accountType,
      Value<double?> initialBalance,
      required CurrencyType currencyType,
      Value<bool> isActive,
      Value<DateTime> initDate,
      Value<double?> creditLimit,
      Value<DateTime?> firstBillDueDate,
      Value<int?> billClosingDay,
      Value<int?> paymentAccountId,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<AccountIconType> iconType,
      Value<AccountType> accountType,
      Value<double?> initialBalance,
      Value<CurrencyType> currencyType,
      Value<bool> isActive,
      Value<DateTime> initDate,
      Value<double?> creditLimit,
      Value<DateTime?> firstBillDueDate,
      Value<int?> billClosingDay,
      Value<int?> paymentAccountId,
    });

final class $$AccountsTableReferences
    extends BaseReferences<_$DatabaseManager, $AccountsTable, AccountData> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _paymentAccountIdTable(_$DatabaseManager db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.accounts.paymentAccountId, db.accounts.id),
      );

  $$AccountsTableProcessedTableManager? get paymentAccountId {
    final $_column = $_itemColumn<int>('payment_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$DatabaseManager, $AccountsTable> {
  $$AccountsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AccountIconType, AccountIconType, String>
  get iconType => $composableBuilder(
    column: $table.iconType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<AccountType, AccountType, String>
  get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CurrencyType, CurrencyType, String>
  get currencyType => $composableBuilder(
    column: $table.currencyType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get initDate => $composableBuilder(
    column: $table.initDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstBillDueDate => $composableBuilder(
    column: $table.firstBillDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get billClosingDay => $composableBuilder(
    column: $table.billClosingDay,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get paymentAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$DatabaseManager, $AccountsTable> {
  $$AccountsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconType => $composableBuilder(
    column: $table.iconType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyType => $composableBuilder(
    column: $table.currencyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get initDate => $composableBuilder(
    column: $table.initDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstBillDueDate => $composableBuilder(
    column: $table.firstBillDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billClosingDay => $composableBuilder(
    column: $table.billClosingDay,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get paymentAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$DatabaseManager, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AccountIconType, String> get iconType =>
      $composableBuilder(column: $table.iconType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AccountType, String> get accountType =>
      $composableBuilder(
        column: $table.accountType,
        builder: (column) => column,
      );

  GeneratedColumn<double> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<CurrencyType, String> get currencyType =>
      $composableBuilder(
        column: $table.currencyType,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get initDate =>
      $composableBuilder(column: $table.initDate, builder: (column) => column);

  GeneratedColumn<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstBillDueDate => $composableBuilder(
    column: $table.firstBillDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get billClosingDay => $composableBuilder(
    column: $table.billClosingDay,
    builder: (column) => column,
  );

  $$AccountsTableAnnotationComposer get paymentAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$DatabaseManager,
          $AccountsTable,
          AccountData,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (AccountData, $$AccountsTableReferences),
          AccountData,
          PrefetchHooks Function({bool paymentAccountId})
        > {
  $$AccountsTableTableManager(_$DatabaseManager db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<AccountIconType> iconType = const Value.absent(),
                Value<AccountType> accountType = const Value.absent(),
                Value<double?> initialBalance = const Value.absent(),
                Value<CurrencyType> currencyType = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> initDate = const Value.absent(),
                Value<double?> creditLimit = const Value.absent(),
                Value<DateTime?> firstBillDueDate = const Value.absent(),
                Value<int?> billClosingDay = const Value.absent(),
                Value<int?> paymentAccountId = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                iconType: iconType,
                accountType: accountType,
                initialBalance: initialBalance,
                currencyType: currencyType,
                isActive: isActive,
                initDate: initDate,
                creditLimit: creditLimit,
                firstBillDueDate: firstBillDueDate,
                billClosingDay: billClosingDay,
                paymentAccountId: paymentAccountId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required AccountIconType iconType,
                required AccountType accountType,
                Value<double?> initialBalance = const Value.absent(),
                required CurrencyType currencyType,
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> initDate = const Value.absent(),
                Value<double?> creditLimit = const Value.absent(),
                Value<DateTime?> firstBillDueDate = const Value.absent(),
                Value<int?> billClosingDay = const Value.absent(),
                Value<int?> paymentAccountId = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                iconType: iconType,
                accountType: accountType,
                initialBalance: initialBalance,
                currencyType: currencyType,
                isActive: isActive,
                initDate: initDate,
                creditLimit: creditLimit,
                firstBillDueDate: firstBillDueDate,
                billClosingDay: billClosingDay,
                paymentAccountId: paymentAccountId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({paymentAccountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (paymentAccountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.paymentAccountId,
                                referencedTable: $$AccountsTableReferences
                                    ._paymentAccountIdTable(db),
                                referencedColumn: $$AccountsTableReferences
                                    ._paymentAccountIdTable(db)
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

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$DatabaseManager,
      $AccountsTable,
      AccountData,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (AccountData, $$AccountsTableReferences),
      AccountData,
      PrefetchHooks Function({bool paymentAccountId})
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      required FinancialType categoryType,
      Value<int?> parentCategoryId,
      Value<bool> isActive,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<FinancialType> categoryType,
      Value<int?> parentCategoryId,
      Value<bool> isActive,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$DatabaseManager, $CategoriesTable, CategoryData> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _parentCategoryIdTable(_$DatabaseManager db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.categories.parentCategoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get parentCategoryId {
    final $_column = $_itemColumn<int>('parent_category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<DataTransaction>>
  _transactionsRefsTable(_$DatabaseManager db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.transactions.categoryId,
    ),
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$DatabaseManager, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FinancialType, FinancialType, String>
  get categoryType => $composableBuilder(
    column: $table.categoryType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get parentCategoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentCategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$DatabaseManager, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryType => $composableBuilder(
    column: $table.categoryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get parentCategoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentCategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$DatabaseManager, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FinancialType, String> get categoryType =>
      $composableBuilder(
        column: $table.categoryType,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get parentCategoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentCategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$DatabaseManager,
          $CategoriesTable,
          CategoryData,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryData, $$CategoriesTableReferences),
          CategoryData,
          PrefetchHooks Function({bool parentCategoryId, bool transactionsRefs})
        > {
  $$CategoriesTableTableManager(_$DatabaseManager db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<FinancialType> categoryType = const Value.absent(),
                Value<int?> parentCategoryId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                categoryType: categoryType,
                parentCategoryId: parentCategoryId,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required FinancialType categoryType,
                Value<int?> parentCategoryId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                categoryType: categoryType,
                parentCategoryId: parentCategoryId,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({parentCategoryId = false, transactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                  ],
                  addJoins:
                      <
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
                        if (parentCategoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentCategoryId,
                                    referencedTable: $$CategoriesTableReferences
                                        ._parentCategoryIdTable(db),
                                    referencedColumn:
                                        $$CategoriesTableReferences
                                            ._parentCategoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          CategoryData,
                          $CategoriesTable,
                          DataTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
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

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$DatabaseManager,
      $CategoriesTable,
      CategoryData,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryData, $$CategoriesTableReferences),
      CategoryData,
      PrefetchHooks Function({bool parentCategoryId, bool transactionsRefs})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required FinancialType transactionType,
      required DateTime actualDate,
      required DateTime competenceDate,
      required double amount,
      Value<String?> description,
      required TransactionPaymentStatus paymentStatus,
      required TransactionRecurrenceType recurrenceType,
      Value<TransactionRecurrenceFrequency?> recurrenceFrequency,
      required int accountId,
      Value<int?> categoryId,
      Value<int?> targetAccountId,
      Value<String?> transferId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<FinancialType> transactionType,
      Value<DateTime> actualDate,
      Value<DateTime> competenceDate,
      Value<double> amount,
      Value<String?> description,
      Value<TransactionPaymentStatus> paymentStatus,
      Value<TransactionRecurrenceType> recurrenceType,
      Value<TransactionRecurrenceFrequency?> recurrenceFrequency,
      Value<int> accountId,
      Value<int?> categoryId,
      Value<int?> targetAccountId,
      Value<String?> transferId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TransactionsTableReferences
    extends
        BaseReferences<_$DatabaseManager, $TransactionsTable, DataTransaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$DatabaseManager db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.transactions.accountId, db.accounts.id),
      );

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$DatabaseManager db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.transactions.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _targetAccountIdTable(_$DatabaseManager db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.transactions.targetAccountId, db.accounts.id),
      );

  $$AccountsTableProcessedTableManager? get targetAccountId {
    final $_column = $_itemColumn<int>('target_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_targetAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$DatabaseManager, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<FinancialType, FinancialType, String>
  get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get competenceDate => $composableBuilder(
    column: $table.competenceDate,
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

  ColumnWithTypeConverterFilters<
    TransactionPaymentStatus,
    TransactionPaymentStatus,
    String
  >
  get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    TransactionRecurrenceType,
    TransactionRecurrenceType,
    String
  >
  get recurrenceType => $composableBuilder(
    column: $table.recurrenceType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    TransactionRecurrenceFrequency?,
    TransactionRecurrenceFrequency,
    String
  >
  get recurrenceFrequency => $composableBuilder(
    column: $table.recurrenceFrequency,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get transferId => $composableBuilder(
    column: $table.transferId,
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

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get targetAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$DatabaseManager, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
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

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get competenceDate => $composableBuilder(
    column: $table.competenceDate,
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

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceType => $composableBuilder(
    column: $table.recurrenceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceFrequency => $composableBuilder(
    column: $table.recurrenceFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferId => $composableBuilder(
    column: $table.transferId,
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

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get targetAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$DatabaseManager, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FinancialType, String> get transactionType =>
      $composableBuilder(
        column: $table.transactionType,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get competenceDate => $composableBuilder(
    column: $table.competenceDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TransactionPaymentStatus, String>
  get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TransactionRecurrenceType, String>
  get recurrenceType => $composableBuilder(
    column: $table.recurrenceType,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TransactionRecurrenceFrequency?, String>
  get recurrenceFrequency => $composableBuilder(
    column: $table.recurrenceFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transferId => $composableBuilder(
    column: $table.transferId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get targetAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$DatabaseManager,
          $TransactionsTable,
          DataTransaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (DataTransaction, $$TransactionsTableReferences),
          DataTransaction,
          PrefetchHooks Function({
            bool accountId,
            bool categoryId,
            bool targetAccountId,
          })
        > {
  $$TransactionsTableTableManager(
    _$DatabaseManager db,
    $TransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<FinancialType> transactionType = const Value.absent(),
                Value<DateTime> actualDate = const Value.absent(),
                Value<DateTime> competenceDate = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<TransactionPaymentStatus> paymentStatus =
                    const Value.absent(),
                Value<TransactionRecurrenceType> recurrenceType =
                    const Value.absent(),
                Value<TransactionRecurrenceFrequency?> recurrenceFrequency =
                    const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int?> targetAccountId = const Value.absent(),
                Value<String?> transferId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                transactionType: transactionType,
                actualDate: actualDate,
                competenceDate: competenceDate,
                amount: amount,
                description: description,
                paymentStatus: paymentStatus,
                recurrenceType: recurrenceType,
                recurrenceFrequency: recurrenceFrequency,
                accountId: accountId,
                categoryId: categoryId,
                targetAccountId: targetAccountId,
                transferId: transferId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required FinancialType transactionType,
                required DateTime actualDate,
                required DateTime competenceDate,
                required double amount,
                Value<String?> description = const Value.absent(),
                required TransactionPaymentStatus paymentStatus,
                required TransactionRecurrenceType recurrenceType,
                Value<TransactionRecurrenceFrequency?> recurrenceFrequency =
                    const Value.absent(),
                required int accountId,
                Value<int?> categoryId = const Value.absent(),
                Value<int?> targetAccountId = const Value.absent(),
                Value<String?> transferId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                transactionType: transactionType,
                actualDate: actualDate,
                competenceDate: competenceDate,
                amount: amount,
                description: description,
                paymentStatus: paymentStatus,
                recurrenceType: recurrenceType,
                recurrenceFrequency: recurrenceFrequency,
                accountId: accountId,
                categoryId: categoryId,
                targetAccountId: targetAccountId,
                transferId: transferId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                accountId = false,
                categoryId = false,
                targetAccountId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
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
                        if (accountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.accountId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._accountIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._accountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (targetAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.targetAccountId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._targetAccountIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._targetAccountIdTable(db)
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

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$DatabaseManager,
      $TransactionsTable,
      DataTransaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (DataTransaction, $$TransactionsTableReferences),
      DataTransaction,
      PrefetchHooks Function({
        bool accountId,
        bool categoryId,
        bool targetAccountId,
      })
    >;

class $DatabaseManagerManager {
  final _$DatabaseManager _db;
  $DatabaseManagerManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
}
