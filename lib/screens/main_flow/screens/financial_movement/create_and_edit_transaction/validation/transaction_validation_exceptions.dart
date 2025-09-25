import 'package:app_database/app_database.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class TransactionValidationException {
  static String getMessage(Exception exception, BuildContext context) {
    final t = context.t;

    switch (exception.runtimeType) {
      case InvalidNumberException:
        return t.transactions.validation.amount_invalid_number;

      case NumberCannotBeZeroException:
        return t.transactions.validation.amount_cannot_be_zero;

      case NameTooLongException:
        final ex = exception as NameTooLongException;
        return t.transactions.validation.description_max_length_number(
          number: ex.maxLength,
        );

      case AccountNotSelectedException:
        return t.transactions.validation.account_must_be_selected;

      case InvalidAccountIdException:
        return t.transactions.validation.account_id_must_be_positive;

      case CategoryNotSelectedException:
        return t.transactions.validation.category_must_be_selected;

      case InvalidCategoryIdException:
        return t.transactions.validation.category_id_must_be_positive;

      case DateTooFarInPastException:
        final ex = exception as DateTooFarInPastException;
        return t.transactions.validation.date_too_far_past_number(
          number: ex.minimumYear,
        );

      case DateTooFarInFutureException:
        final ex = exception as DateTooFarInFutureException;
        return t.transactions.validation.date_too_far_future_number(
          number: ex.maximumYear,
        );

      case ValidationException:
        final ex = exception as ValidationException;
        return ex.message;

      default:
        return 'Unknown validation error';
    }
  }
}
