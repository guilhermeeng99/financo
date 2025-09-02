import '../../../core/exceptions.dart';

class TransactionAmount {
  factory TransactionAmount.create(double value) {
    if (value.isNaN || value.isInfinite) {
      throw const ValidationException(
        'Transaction amount must be a valid number',
      );
    }

    if (value == 0) {
      throw const ValidationException(
        'Transaction amount must be different than zero',
      );
    }

    return TransactionAmount._(value);
  }

  TransactionAmount._(this.value);

  final double value;
}

class TransactionDescription {
  factory TransactionDescription.create(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.length > 255) {
      throw const ValidationException(
        'Transaction description must be at most 255 characters long',
      );
    }

    return TransactionDescription._(trimmedValue);
  }

  TransactionDescription._(this.value);

  final String value;
}

class TransactionAccountId {
  factory TransactionAccountId.create(int value) {
    if (value <= 0) {
      throw const ValidationException('Account ID must be a positive number');
    }

    return TransactionAccountId._(value);
  }

  TransactionAccountId._(this.value);

  final int value;
}

class TransactionCategoryId {
  factory TransactionCategoryId.create(int value) {
    if (value <= 0) {
      throw const ValidationException('Category ID must be a positive number');
    }

    return TransactionCategoryId._(value);
  }

  TransactionCategoryId._(this.value);

  final int value;
}

class TransactionDate {
  factory TransactionDate.create(DateTime value) {
    final minimumDate = DateTime.now().subtract(const Duration(days: 36500));
    if (value.isBefore(minimumDate)) {
      throw const ValidationException(
        'Transaction date cannot be more than 100 years in the past',
      );
    }

    final maximumDate = DateTime.now().add(const Duration(days: 3650));
    if (value.isAfter(maximumDate)) {
      throw const ValidationException(
        'Transaction date cannot be more than 10 years in the future',
      );
    }

    return TransactionDate._(value);
  }

  TransactionDate._(this.value);

  final DateTime value;
}
