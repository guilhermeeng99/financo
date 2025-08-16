import 'package:drift/drift.dart';

enum AccountType {
  checking('checking'),
  creditCard('creditCard'),
  others('others'),
  cash('cash');

  const AccountType(this.value);
  final String value;
}

@UseRowClass(AccountData)
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get accountType => textEnum<AccountType>()();
  RealColumn get balance => real().withDefault(const Constant(0))();
  TextColumn get currency =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('BRL'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get initDate => dateTime().withDefault(currentDateAndTime)();
}

class AccountData {
  AccountData({
    required this.accountType,
    required this.balance,
    required this.currency,
    required this.isActive,
    required this.initDate,
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
  final AccountType accountType;
  final double balance;
  final String currency;
  final bool isActive;
  final DateTime initDate;

  @override
  String toString() {
    return 'AccountData{'
        'id: $id, '
        'name: $name, '
        'accountType: $accountType, '
        'balance: $balance, '
        'currency: $currency, '
        'isActive: $isActive, '
        '}';
  }
}

class ValidationException implements Exception {
  const ValidationException(this.message);
  final String message;

  @override
  String toString() => 'ValidationException: $message';
}

class AccountName {
  factory AccountName.create(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      throw const ValidationException('Account name cannot be empty');
    }

    if (trimmedValue.length > 15) {
      throw const ValidationException(
        'Account name must be at most 15 characters long',
      );
    }

    return AccountName._(trimmedValue);
  }

  AccountName._(this.value);

  final String value;
}

class Currency {
  factory Currency.eur() => Currency._('EUR');
  factory Currency.usd() => Currency._('USD');
  factory Currency.brl() => Currency._('BRL');

  factory Currency.create(String value) {
    final trimmedValue = value.trim().toUpperCase();

    if (trimmedValue.length != 3) {
      throw const ValidationException(
        'Currency code must be exactly 3 characters long',
      );
    }

    if (!RegExp(r'^[A-Z]{3}$').hasMatch(trimmedValue)) {
      throw const ValidationException(
        'Currency code must contain only capital letters',
      );
    }

    return Currency._(trimmedValue);
  }

  Currency._(this.value);
  final String value;
}

class Balance {
  Balance._(this.value);

  factory Balance.create(double value) {
    if (value.isNaN || value.isInfinite) {
      throw const ValidationException('Balance must be a valid number');
    }

    return Balance._(value);
  }

  factory Balance.zero() => Balance._(0);
  final double value;
}
