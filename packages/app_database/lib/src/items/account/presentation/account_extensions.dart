import 'package:financo/gen/assets.gen.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart' as flutter;

import '../domain/account_enums.dart';
import '../domain/account_table.dart';

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
