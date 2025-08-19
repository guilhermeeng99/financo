import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart';

class AccountUsecase {
  AccountUsecase(this._accountRepository);

  final IAccountRepository _accountRepository;

  Future<Either<Failure, AccountData>> createAccount({
    required String name,
    required AccountType accountType,
    AccountIconType iconType = AccountIconType.none,
    double initialBalance = 0.0,
    CurrencyType currencyType = CurrencyType.brl,
    DateTime? initDate,
  }) async {
    try {
      final accountName = AccountName.create(name);
      final balance = Balance.create(initialBalance);

      final accountCompanion = AccountsCompanion(
        name: Value(accountName.value),
        accountType: Value(accountType),
        balance: Value(balance.value),
        currencyType: Value(currencyType),
        isActive: const Value(true),
        iconType: Value(iconType),
        initDate: Value(initDate ?? DateTime.now()),
      );

      return await _accountRepository.createAccount(accountCompanion);
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error creating account: $e'),
      );
    }
  }

  Future<Either<Failure, List<AccountData>>> getAllAccounts() async {
    return _accountRepository.getAllAccounts();
  }

  Future<Either<Failure, List<AccountData>>> getAccountsByType(
    AccountType type,
  ) async {
    return _accountRepository.getAccountsByType(type);
  }

  Future<Either<Failure, AccountData>> updateAccount({
    required int id,
    String? name,
    AccountType? accountType,
    double? balance,
    CurrencyType? currencyType,
    bool? isActive,
    AccountIconType? iconType,
    DateTime? initDate,
  }) async {
    try {
      Value<String>? nameValue;
      Value<AccountType>? accountTypeValue;
      Value<double>? balanceValue;
      Value<CurrencyType>? currencyTypeValue;
      Value<bool>? isActiveValue;
      Value<AccountIconType>? iconTypeValue;
      Value<DateTime>? initDateValue;

      if (name != null) {
        final accountName = AccountName.create(name);
        nameValue = Value(accountName.value);
      }

      if (accountType != null) {
        accountTypeValue = Value(accountType);
      }

      if (balance != null) {
        final accountBalance = Balance.create(balance);
        balanceValue = Value(accountBalance.value);
      }

      if (currencyType != null) {
        currencyTypeValue = Value(currencyType);
      }

      if (isActive != null) {
        isActiveValue = Value(isActive);
      }

      if (iconType != null) {
        iconTypeValue = Value(iconType);
      }

      if (initDate != null) {
        initDateValue = Value(initDate);
      }

      if (nameValue == null &&
          accountTypeValue == null &&
          balanceValue == null &&
          currencyTypeValue == null &&
          isActiveValue == null &&
          iconTypeValue == null &&
          initDateValue == null) {
        return Either.left(const ValidationFailure('No changes were provided'));
      }

      final accountCompanion = AccountsCompanion(
        name: nameValue ?? const Value.absent(),
        accountType: accountTypeValue ?? const Value.absent(),
        balance: balanceValue ?? const Value.absent(),
        currencyType: currencyTypeValue ?? const Value.absent(),
        isActive: isActiveValue ?? const Value.absent(),
        iconType: iconTypeValue ?? const Value.absent(),
        initDate: initDateValue ?? const Value.absent(),
      );

      return await _accountRepository.updateAccount(id, accountCompanion);
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error editing account: $e'),
      );
    }
  }

  Future<Either<Failure, bool>> deleteAccount(int id) async {
    try {
      return await _accountRepository.deleteAccount(id);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error deleting account: $e'),
      );
    }
  }
}
