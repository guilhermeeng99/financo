import 'package:drift/drift.dart';

import 'account_enums.dart';

@UseRowClass(AccountData)
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 3, max: 15)();
  TextColumn get iconType => textEnum<AccountIconType>()();
  TextColumn get accountType => textEnum<AccountType>()();
  RealColumn get initialBalance => real().nullable()();
  TextColumn get currencyType => textEnum<CurrencyType>()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get initDate => dateTime().withDefault(currentDateAndTime)();
  RealColumn get creditLimit => real().nullable()();
  DateTimeColumn get firstBillDueDate => dateTime().nullable()();
  IntColumn get billClosingDay => integer().nullable().check(
    const CustomExpression('bill_closing_day >= 1 AND bill_closing_day <= 31'),
  )();
  IntColumn get paymentAccountId =>
      integer().nullable().references(Accounts, #id)();
}

class AccountData extends BaseAccount {
  AccountData({
    required super.id,
    required super.name,
    required super.iconType,
    required super.accountType,
    required super.currencyType,
    required super.isActive,
    required super.initDate,
    this.initialBalance,
    this.creditLimit,
    this.firstBillDueDate,
    this.billClosingDay,
    this.paymentAccountId,
  });

  final double? initialBalance;
  final double? creditLimit;
  final DateTime? firstBillDueDate;
  final int? billClosingDay;
  final int? paymentAccountId;
}

abstract class BaseAccount {
  const BaseAccount({
    required this.id,
    required this.name,
    required this.iconType,
    required this.accountType,
    required this.currencyType,
    required this.isActive,
    required this.initDate,
  });

  final int id;
  final String name;
  final AccountIconType iconType;
  final AccountType accountType;
  final CurrencyType currencyType;
  final bool isActive;
  final DateTime initDate;
}

class StandardAccount extends BaseAccount {
  const StandardAccount({
    required super.id,
    required super.name,
    required super.iconType,
    required super.accountType,
    required super.currencyType,
    required super.isActive,
    required super.initDate,
    required this.initialBalance,
  });

  factory StandardAccount.fromAccountData(AccountData data) {
    if (data.initialBalance == null) {
      throw ArgumentError(
        'AccountData must have initialBalance to convert to StandardAccount',
      );
    }

    return StandardAccount(
      id: data.id,
      name: data.name,
      iconType: data.iconType,
      accountType: data.accountType,
      currencyType: data.currencyType,
      isActive: data.isActive,
      initDate: data.initDate,
      initialBalance: data.initialBalance!,
    );
  }

  final double initialBalance;
}

class CreditCardAccount extends BaseAccount {
  const CreditCardAccount({
    required super.id,
    required super.name,
    required super.iconType,
    required super.accountType,
    required super.currencyType,
    required super.isActive,
    required super.initDate,
    required this.creditLimit,
    required this.firstBillDueDate,
    required this.billClosingDay,
    required this.paymentAccountId,
  });

  factory CreditCardAccount.fromAccountData(AccountData data) {
    if (data.creditLimit == null ||
        data.firstBillDueDate == null ||
        data.billClosingDay == null ||
        data.paymentAccountId == null) {
      throw ArgumentError(
        'AccountData must have creditLimit, firstBillDueDate, billClosingDay, and paymentAccountId to convert to CreditCardAccount',
      );
    }

    return CreditCardAccount(
      id: data.id,
      name: data.name,
      iconType: data.iconType,
      accountType: data.accountType,
      currencyType: data.currencyType,
      isActive: data.isActive,
      initDate: data.initDate,
      creditLimit: data.creditLimit!,
      firstBillDueDate: data.firstBillDueDate!,
      billClosingDay: data.billClosingDay!,
      paymentAccountId: data.paymentAccountId!,
    );
  }

  final double creditLimit;
  final DateTime firstBillDueDate;
  final int billClosingDay;
  final int paymentAccountId;
}
