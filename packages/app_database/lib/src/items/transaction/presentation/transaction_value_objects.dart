import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

import '../../../core/exceptions.dart';
import '../../../core/financial_type.dart';

class TransactionAmount {
  factory TransactionAmount.create(
    double value,
    BuildContext context, {
    FinancialType? transactionType,
  }) {
    if (value.isNaN || value.isInfinite) {
      throw ValidationException(
        context.t.transactions.validation.amount_invalid_number,
      );
    }

    if (value == 0) {
      throw ValidationException(
        context.t.transactions.validation.amount_cannot_be_zero,
      );
    }

    final signedValue = switch (transactionType) {
      FinancialType.income => value.abs(),
      FinancialType.expense => -value.abs(),
      null => value,
    };

    return TransactionAmount._(signedValue);
  }

  TransactionAmount._(this.value);

  final double value;
}

class TransactionDescription {
  factory TransactionDescription.create(String? value, BuildContext context) {
    if (value == null) {
      return TransactionDescription._(null);
    }

    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return TransactionDescription._(null);
    }

    const descriptionMaxLengthNumber = 255;
    if (trimmedValue.length > descriptionMaxLengthNumber) {
      throw ValidationException(
        context.t.transactions.validation.description_max_length_number(
          number: descriptionMaxLengthNumber,
        ),
      );
    }

    return TransactionDescription._(trimmedValue);
  }

  TransactionDescription._(this.value);

  final String? value;
}

class TransactionAccountId {
  factory TransactionAccountId.create(int? value, BuildContext context) {
    if (value == null) {
      throw ValidationException(
        context.t.transactions.validation.account_must_be_selected,
      );
    }

    if (value <= 0) {
      throw ValidationException(
        context.t.transactions.validation.account_id_must_be_positive,
      );
    }

    return TransactionAccountId._(value);
  }

  TransactionAccountId._(this.value);

  final int value;
}

class TransactionCategoryId {
  factory TransactionCategoryId.create(int? value, BuildContext context) {
    if (value == null) {
      throw ValidationException(
        context.t.transactions.validation.category_must_be_selected,
      );
    }

    if (value <= 0) {
      throw ValidationException(
        context.t.transactions.validation.category_id_must_be_positive,
      );
    }

    return TransactionCategoryId._(value);
  }

  TransactionCategoryId._(this.value);

  final int value;
}

class TransactionDate {
  factory TransactionDate.create(DateTime value, BuildContext context) {
    final minimumDate = DateTime.now().subtract(const Duration(days: 36500));
    if (value.isBefore(minimumDate)) {
      throw ValidationException(
        context.t.transactions.validation.date_too_far_past_number(
          number: minimumDate.year,
        ),
      );
    }

    final maximumDate = DateTime.now().add(const Duration(days: 3650));
    if (value.isAfter(maximumDate)) {
      throw ValidationException(
        context.t.transactions.validation.date_too_far_future_number(
          number: maximumDate.year,
        ),
      );
    }

    return TransactionDate._(value);
  }

  TransactionDate._(this.value);

  final DateTime value;
}
