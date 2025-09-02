import '../../../core/either.dart';
import '../../../core/exceptions.dart';
import '../../../core/failures.dart';
import '../domain/index.dart';

class AccountValidationHelpers {
  static Either<Failure, AccountName> validateAccountName(String name) {
    try {
      final accountName = AccountName.create(name);
      return Either.right(accountName);
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      return Either.left(
        ValidationFailure('Unexpected error validating account name: $e'),
      );
    }
  }

  static Either<Failure, Balance> validateBalance(double balance) {
    try {
      final balanceObj = Balance.create(balance);
      return Either.right(balanceObj);
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      return Either.left(
        ValidationFailure('Unexpected error validating balance: $e'),
      );
    }
  }

  static bool hasAnyChanges({
    String? name,
    AccountType? accountType,
    double? initialBalance,
    CurrencyType? currencyType,
    bool? isActive,
    AccountIconType? iconType,
    DateTime? initDate,
  }) {
    return name != null ||
        accountType != null ||
        initialBalance != null ||
        currencyType != null ||
        isActive != null ||
        iconType != null ||
        initDate != null;
  }
}
