import '../../../core/exceptions.dart';
import 'account_enums.dart';

class AccountName {
  factory AccountName.create(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      throw const ValidationException('Account name cannot be empty');
    }

    if (trimmedValue.length < 3) {
      throw const ValidationException(
        'Account name must be at least 3 characters long',
      );
    }
    if (trimmedValue.length > 15) {
      throw const ValidationException(
        'Account name must be at most 15 characters long',
      );
    }

    return AccountName._(trimmedValue);
  }

  AccountName._(this.value);

  final String value;
}

class Currency {
  factory Currency.fromType(CurrencyType type) => Currency._(type.value);

  factory Currency.create(String value) {
    final trimmedValue = value.trim().toUpperCase();

    if (trimmedValue.length != 3) {
      throw const ValidationException(
        'Currency code must be exactly 3 characters long',
      );
    }

    if (!RegExp(r'^[A-Z]{3}$').hasMatch(trimmedValue)) {
      throw const ValidationException(
        'Currency code must contain only capital letters',
      );
    }

    return Currency._(trimmedValue);
  }

  Currency._(this.value);
  final String value;
}

class Balance {
  Balance._(this.value);

  factory Balance.create(double value) {
    if (value.isNaN || value.isInfinite) {
      throw const ValidationException('Balance must be a valid number');
    }

    return Balance._(value);
  }

  factory Balance.zero() => Balance._(0);
  final double value;
}
