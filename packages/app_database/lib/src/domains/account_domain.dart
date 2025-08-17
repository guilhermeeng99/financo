import 'package:drift/drift.dart';

enum AccountType {
  checking('checking'),
  creditCard('creditCard'),
  others('others'),
  cash('cash');

  const AccountType(this.value);
  final String value;
}

enum AccountIconType {
  none('none'),
  nubank('nubank');

  const AccountIconType(this.value);
  final String value;
}

enum CurrencyType {
  brl('BRL'),
  usd('USD'),
  eur('EUR');

  const CurrencyType(this.value);
  final String value;

  static CurrencyType fromString(String value) {
    return CurrencyType.values.firstWhere(
      (currency) => currency.value == value.toUpperCase(),
      orElse: () => CurrencyType.brl,
    );
  }
}

@UseRowClass(AccountData)
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 3, max: 15)();
  TextColumn get icon => textEnum<AccountIconType>()();
  TextColumn get accountType => textEnum<AccountType>()();
  RealColumn get balance => real().withDefault(const Constant(0))();
  TextColumn get currency => textEnum<CurrencyType>()();
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
    required this.icon,
  });

  final int id;
  final String name;
  final AccountIconType icon;
  final AccountType accountType;
  final double balance;
  final CurrencyType currency;
  final bool isActive;
  final DateTime initDate;

  @override
  String toString() {
    return 'AccountData{'
        'id: $id, '
        'name: $name, '
        'icon: $icon, '
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

    if (trimmedValue.length < 3) {
      throw const ValidationException(
        'Account name must be at least 3 characters long',
      );
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
  factory Currency.fromType(CurrencyType type) => Currency._(type.value);

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
