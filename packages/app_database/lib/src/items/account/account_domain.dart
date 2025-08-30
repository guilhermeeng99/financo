import 'package:drift/drift.dart';
import 'package:financo/gen/assets.gen.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart' as flutter;

import '../../core/exceptions.dart';

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
}

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

  @override
  String toString() {
    return 'AccountData{'
        'id: $id, '
        'name: $name, '
        'iconType: $iconType, '
        'accountType: $accountType, '
        'initialBalance: $initialBalance, '
        'currencyType: $currencyType, '
        'isActive: $isActive, '
        '}';
  }
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

$LibAppAssetsImagesGen get _images => Assets.lib.app.assets.images;

class CurrencyHelper {
  const CurrencyHelper(this._currency);

  final CurrencyType _currency;

  String get iconPath => _currency.iconPath;
  String title(flutter.BuildContext context) => _currency.title(context);
}

extension AccountTypeExtension on AccountType {
  String title(flutter.BuildContext context) {
    switch (this) {
      case AccountType.checking:
        return context.t.accounts.types.checking_account;
      case AccountType.creditCard:
        return context.t.accounts.types.credit_card;
      case AccountType.others:
        return context.t.accounts.types.others;
      case AccountType.cash:
        return context.t.accounts.types.money;
    }
  }
}

extension CurrencyTypeExtension on CurrencyType {
  String get iconPath {
    switch (this) {
      case CurrencyType.brl:
        return _images.flags.brazil.path;
      case CurrencyType.usd:
        return _images.flags.unitedStates.path;
      case CurrencyType.eur:
        return _images.flags.unitedKingdom.path;
    }
  }

  String title(flutter.BuildContext context) {
    switch (this) {
      case CurrencyType.brl:
        return context.t.transactions.currency.types.brl;
      case CurrencyType.usd:
        return context.t.transactions.currency.types.usd;
      case CurrencyType.eur:
        return context.t.transactions.currency.types.eur;
    }
  }
}

extension AccountIconTypeExtension on AccountIconType {
  String get iconPath {
    switch (this) {
      case AccountIconType.none:
        return _images.banks.bank.path;
      case AccountIconType.nubank:
        return _images.banks.nubank.path;
    }
  }
}

extension AccountDataExtension on AccountData {
  String title(flutter.BuildContext context) => accountType.title(context);
  String get iconPath => iconType.iconPath;
  CurrencyHelper get currency => CurrencyHelper(currencyType);
}
