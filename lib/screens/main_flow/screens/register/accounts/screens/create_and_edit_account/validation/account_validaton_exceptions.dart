import 'package:app_database/app_database.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class AccountValidationException {
  static String getMessage(Exception exception, BuildContext context) {
    final t = context.t;

    switch (exception.runtimeType) {
      case NameEmptyException:
        return t.accounts.validation.name_cannot_be_empty;

      case NameTooShortException:
        final ex = exception as NameTooShortException;
        return t.accounts.validation.name_min_length_number(
          number: ex.minLength,
        );

      case NameTooLongException:
        final ex = exception as NameTooLongException;
        return t.accounts.validation.name_max_length_number(
          number: ex.maxLength,
        );

      case CurrencyInvalidLengthException:
        final ex = exception as CurrencyInvalidLengthException;
        return t.accounts.validation.currency_code_length_number(
          number: ex.expectedLength,
        );

      case CurrencyInvalidFormatException:
        return t.accounts.validation.currency_code_format;

      case InvalidNumberException:
        return t.accounts.validation.balance_invalid_number;

      case NumberTooLowException:
        final ex = exception as NumberTooLowException;
        return t.accounts.validation.balance_min_value_number(
          number: ex.minValue,
        );

      case NumberTooHighException:
        final ex = exception as NumberTooHighException;
        return t.accounts.validation.balance_max_value_number(
          number: ex.maxValue,
        );

      case ValidationException:
        final ex = exception as ValidationException;
        return ex.message;

      default:
        return 'Unknown validation error';
    }
  }
}
