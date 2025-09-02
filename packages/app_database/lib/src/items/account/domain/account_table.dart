import 'package:drift/drift.dart';

import 'account_enums.dart';

@UseRowClass(AccountData)
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 3, max: 15)();
  TextColumn get iconType => textEnum<AccountIconType>()();
  TextColumn get accountType => textEnum<AccountType>()();
  RealColumn get initialBalance => real().withDefault(const Constant(0))();
  TextColumn get currencyType => textEnum<CurrencyType>()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get initDate => dateTime().withDefault(currentDateAndTime)();
}

class AccountData {
  AccountData({
    required this.accountType,
    required this.initialBalance,
    required this.currencyType,
    required this.isActive,
    required this.initDate,
    required this.id,
    required this.name,
    required this.iconType,
  });

  final int id;
  final String name;
  final AccountIconType iconType;
  final AccountType accountType;
  final double initialBalance;
  final CurrencyType currencyType;
  final bool isActive;
  final DateTime initDate;
}
