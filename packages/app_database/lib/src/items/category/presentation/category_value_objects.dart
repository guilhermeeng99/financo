import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

import '../../../core/exceptions.dart';

class CategoryName {
  factory CategoryName.create(String value, BuildContext context) {
    final trimmedValue = value.trim();
    const nameMinLengthNumber = 2;
    const nameMaxLengthNumber = 15;

    if (trimmedValue.isEmpty) {
      throw ValidationException(
        context.t.categories.validation.name_cannot_be_empty,
      );
    }

    if (trimmedValue.length < nameMinLengthNumber) {
      throw ValidationException(
        context.t.categories.validation.name_min_length_number(
          number: nameMinLengthNumber,
        ),
      );
    }
    if (trimmedValue.length > nameMaxLengthNumber) {
      throw ValidationException(
        context.t.categories.validation.name_max_length_number(
          number: nameMaxLengthNumber,
        ),
      );
    }

    return CategoryName._(trimmedValue);
  }

  CategoryName._(this.value);

  final String value;
}

class ParentCategoryId {
  factory ParentCategoryId.create(int? value, BuildContext context) {
    if (value != null && value <= 0) {
      throw ValidationException(
        context.t.categories.validation.parent_id_must_be_positive,
      );
    }

    return ParentCategoryId._(value);
  }

  factory ParentCategoryId.none() => ParentCategoryId._(null);

  ParentCategoryId._(this.value);

  final int? value;

  bool get hasParent => value != null;
}
