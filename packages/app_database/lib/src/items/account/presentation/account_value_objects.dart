import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

import '../../../core/exceptions.dart';
import '../domain/account_enums.dart';

class AccountName {
  factory AccountName.create(String value, BuildContext context) {
    final trimmedValue = value.trim();
    const nameMinLengthNumber = 3;
    const nameMaxLengthNumber = 15;

    if (trimmedValue.isEmpty) {
      throw ValidationException(
        context.t.accounts.validation.name_cannot_be_empty,
      );
    }

    if (trimmedValue.length < nameMinLengthNumber) {
      throw ValidationException(
        context.t.accounts.validation.name_min_length_number(
          number: nameMinLengthNumber,
        ),
      );
    }
    if (trimmedValue.length > nameMaxLengthNumber) {
      throw ValidationException(
        context.t.accounts.validation.name_max_length_number(
          number: nameMaxLengthNumber,
        ),
      );
    }

    return AccountName._(trimmedValue);
  }

  AccountName._(this.value);

  final String value;
}

class Currency {
  factory Currency.fromType(CurrencyType type) => Currency._(type.value);

  factory Currency.create(String value, BuildContext context) {
    final trimmedValue = value.trim().toUpperCase();
    const currencyCodeLengthNumber = 3;

    if (trimmedValue.length != currencyCodeLengthNumber) {
      throw ValidationException(
        context.t.accounts.validation.currency_code_length_number(
          number: currencyCodeLengthNumber,
        ),
      );
    }

    if (!RegExp(r'^[A-Z]{3}$').hasMatch(trimmedValue)) {
      throw ValidationException(
        context.t.accounts.validation.currency_code_format,
      );
    }

    return Currency._(trimmedValue);
  }

  Currency._(this.value);
  final String value;
}

class Balance {
  Balance._(this.value);

  factory Balance.create(double value, BuildContext context) {
    const number = 999999999;

    if (value.isNaN || value.isInfinite) {
      throw ValidationException(
        context.t.accounts.validation.balance_invalid_number,
      );
    }

    if (value < -number) {
      throw ValidationException(
        context.t.accounts.validation.balance_min_value_number(number: number),
      );
    }

    if (value > number) {
      throw ValidationException(
        context.t.accounts.validation.balance_max_value_number(number: number),
      );
    }

    return Balance._(value);
  }

  factory Balance.zero() => Balance._(0);
  final double value;
}
