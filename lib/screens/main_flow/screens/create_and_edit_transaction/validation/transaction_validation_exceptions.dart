import 'package:app_database/app_database.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class TransactionValidationException {
  static String getMessage(Exception exception, BuildContext context) {
    final t = context.t;

    switch (exception) {
      case InvalidNumberException _:
        return t.transactions.validation.amount_invalid_number;

      case NumberCannotBeZeroException _:
        return t.transactions.validation.amount_cannot_be_zero;

      case final NameTooLongException ex:
        return t.transactions.validation.description_max_length_number(
          number: ex.maxLength,
        );

      case AccountNotSelectedException _:
        return t.transactions.validation.account_must_be_selected;

      case InvalidAccountIdException _:
        return t.transactions.validation.account_id_must_be_positive;

      case CategoryNotSelectedException _:
        return t.transactions.validation.category_must_be_selected;

      case InvalidCategoryIdException _:
        return t.transactions.validation.category_id_must_be_positive;

      case final DateTooFarInPastException ex:
        return t.transactions.validation.date_too_far_past_number(
          number: ex.minimumYear,
        );

      case final DateTooFarInFutureException ex:
        return t.transactions.validation.date_too_far_future_number(
          number: ex.maximumYear,
        );

      case final ValidationException ex:
        return ex.message;

      default:
        return 'Unknown validation error';
    }
  }
}
