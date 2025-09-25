import 'package:app_database/app_database.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class AccountValidationException {
  static String getMessage(Exception exception, BuildContext context) {
    final t = context.t;

    switch (exception) {
      case NameEmptyException _:
        return t.accounts.validation.name_cannot_be_empty;

      case final NameTooShortException ex:
        return t.accounts.validation.name_min_length_number(
          number: ex.minLength,
        );

      case final NameTooLongException ex:
        return t.accounts.validation.name_max_length_number(
          number: ex.maxLength,
        );

      case final CurrencyInvalidLengthException ex:
        return t.accounts.validation.currency_code_length_number(
          number: ex.expectedLength,
        );

      case CurrencyInvalidFormatException _:
        return t.accounts.validation.currency_code_format;

      case InvalidNumberException _:
        return t.accounts.validation.balance_invalid_number;

      case final NumberTooLowException ex:
        return t.accounts.validation.balance_min_value_number(
          number: ex.minValue,
        );

      case final NumberTooHighException ex:
        return t.accounts.validation.balance_max_value_number(
          number: ex.maxValue,
        );

      case final ValidationException ex:
        return ex.message;

      default:
        return 'Unknown validation error';
    }
  }
}
