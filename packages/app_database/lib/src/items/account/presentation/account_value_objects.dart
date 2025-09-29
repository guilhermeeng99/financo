import '../../../core/exceptions.dart';
import '../domain/account_enums.dart';

class AccountName {
  factory AccountName.create(String value) {
    final trimmedValue = value.trim();
    const nameMinLengthNumber = 3;
    const nameMaxLengthNumber = 15;

    if (trimmedValue.isEmpty) {
      throw const NameEmptyException();
    }

    if (trimmedValue.length < nameMinLengthNumber) {
      throw const NameTooShortException(nameMinLengthNumber);
    }

    if (trimmedValue.length > nameMaxLengthNumber) {
      throw const NameTooLongException(nameMaxLengthNumber);
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
    const currencyCodeLengthNumber = 3;

    if (trimmedValue.length != currencyCodeLengthNumber) {
      throw const CurrencyInvalidLengthException(currencyCodeLengthNumber);
    }

    if (!RegExp(r'^[A-Z]{3}$').hasMatch(trimmedValue)) {
      throw const CurrencyInvalidFormatException();
    }

    return Currency._(trimmedValue);
  }

  Currency._(this.value);
  final String value;
}

class Balance {
  Balance._(this.value);

  factory Balance.create(double value) {
    const number = 999999999.0;

    if (value.isNaN || value.isInfinite) {
      throw const InvalidNumberException();
    }

    if (value < -number) {
      throw const NumberTooLowException(-number);
    }

    if (value > number) {
      throw const NumberTooHighException(number);
    }

    return Balance._(value);
  }

  factory Balance.zero() => Balance._(0);
  final double value;
}

class CreditLimit {
  CreditLimit._(this.value);

  factory CreditLimit.create(double value) {
    const maxLimit = 999999999.0;

    if (value.isNaN || value.isInfinite) {
      throw const InvalidNumberException();
    }

    if (value <= 0) {
      throw const NumberTooLowException(0.01);
    }

    if (value > maxLimit) {
      throw const NumberTooHighException(maxLimit);
    }

    return CreditLimit._(value);
  }

  final double value;
}

class BillClosingDay {
  BillClosingDay._(this.value);

  factory BillClosingDay.create(int day) {
    if (day < 1 || day > 31) {
      throw const BillClosingDayInvalidException();
    }

    return BillClosingDay._(day);
  }

  final int value;
}
