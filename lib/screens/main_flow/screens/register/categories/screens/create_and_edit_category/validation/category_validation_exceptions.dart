import 'package:app_database/app_database.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class CategoryValidationException {
  static String getMessage(Exception exception, BuildContext context) {
    final t = context.t;

    switch (exception) {
      case NameEmptyException _:
        return t.categories.validation.name_cannot_be_empty;

      case final NameTooShortException ex:
        return t.categories.validation.name_min_length_number(
          number: ex.minLength,
        );

      case final NameTooLongException ex:
        return t.categories.validation.name_max_length_number(
          number: ex.maxLength,
        );

      case InvalidParentIdException _:
        return t.categories.validation.parent_id_must_be_positive;

      case final ValidationException ex:
        return ex.message;

      default:
        return 'Unknown validation error';
    }
  }
}
