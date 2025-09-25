class ValidationException implements Exception {
  const ValidationException(this.message);
  final String message;

  @override
  String toString() => 'ValidationException: $message';
}

class NameEmptyException implements Exception {
  const NameEmptyException();
  @override
  String toString() => 'NameEmptyException';
}

class NameTooShortException implements Exception {
  const NameTooShortException(this.minLength);
  final int minLength;
  @override
  String toString() => 'NameTooShortException: minimum $minLength characters';
}

class NameTooLongException implements Exception {
  const NameTooLongException(this.maxLength);
  final int maxLength;
  @override
  String toString() => 'NameTooLongException: maximum $maxLength characters';
}

class CurrencyInvalidLengthException implements Exception {
  const CurrencyInvalidLengthException(this.expectedLength);
  final int expectedLength;
  @override
  String toString() =>
      'CurrencyInvalidLengthException: expected $expectedLength characters';
}

class CurrencyInvalidFormatException implements Exception {
  const CurrencyInvalidFormatException();
  @override
  String toString() =>
      'CurrencyInvalidFormatException: must be 3 uppercase letters';
}

class InvalidNumberException implements Exception {
  const InvalidNumberException();
  @override
  String toString() =>
      'InvalidNumberException: value cannot be NaN or Infinite';
}

class NumberTooLowException implements Exception {
  const NumberTooLowException(this.minValue);
  final double minValue;
  @override
  String toString() => 'NumberTooLowException: minimum value is $minValue';
}

class NumberTooHighException implements Exception {
  const NumberTooHighException(this.maxValue);
  final double maxValue;
  @override
  String toString() => 'NumberTooHighException: maximum value is $maxValue';
}

class NumberCannotBeZeroException implements Exception {
  const NumberCannotBeZeroException();
  @override
  String toString() => 'NumberCannotBeZeroException: number cannot be zero';
}

class InvalidParentIdException implements Exception {
  const InvalidParentIdException();
  @override
  String toString() => 'InvalidParentIdException: parent ID must be positive';
}

class AccountNotSelectedException implements Exception {
  const AccountNotSelectedException();
  @override
  String toString() => 'AccountNotSelectedException: account must be selected';
}

class InvalidAccountIdException implements Exception {
  const InvalidAccountIdException();
  @override
  String toString() => 'InvalidAccountIdException: account ID must be positive';
}

class CategoryNotSelectedException implements Exception {
  const CategoryNotSelectedException();
  @override
  String toString() =>
      'CategoryNotSelectedException: category must be selected';
}

class InvalidCategoryIdException implements Exception {
  const InvalidCategoryIdException();
  @override
  String toString() =>
      'InvalidCategoryIdException: category ID must be positive';
}

class DateTooFarInPastException implements Exception {
  const DateTooFarInPastException(this.minimumYear);
  final int minimumYear;
  @override
  String toString() =>
      'DateTooFarInPastException: minimum year is $minimumYear';
}

class DateTooFarInFutureException implements Exception {
  const DateTooFarInFutureException(this.maximumYear);
  final int maximumYear;
  @override
  String toString() =>
      'DateTooFarInFutureException: maximum year is $maximumYear';
}
