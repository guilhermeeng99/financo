import 'package:app_database/src/items/account/presentation/index.dart';
import 'package:drift/drift.dart';

import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../database/database_manager.dart';
import '../domain/index.dart';
import '../repository/i_account_repository.dart';

mixin AccountCrudUsecaseOperations {
  IAccountRepository get accountRepository;

  Future<Either<Failure, AccountData>> createAccount({
    required AccountName name,
    required AccountType accountType,
    required Balance initialBalance,
    AccountIconType iconType = AccountIconType.none,
    CurrencyType currencyType = CurrencyType.brl,
    DateTime? initDate,
  }) async {
    try {
      final accountCompanion = AccountsCompanion(
        name: Value(name.value),
        accountType: Value(accountType),
        initialBalance: Value(initialBalance.value),
        currencyType: Value(currencyType),
        isActive: const Value(true),
        iconType: Value(iconType),
        initDate: Value(initDate ?? DateTime.now()),
      );

      return await accountRepository.createAccount(accountCompanion);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error creating account: $e'),
      );
    }
  }

  Future<Either<Failure, AccountData>> updateAccount({
    required int id,
    AccountName? name,
    AccountType? accountType,
    Balance? initialBalance,
    CurrencyType? currencyType,
    bool? isActive,
    AccountIconType? iconType,
    DateTime? initDate,
  }) async {
    try {
      final currentAccountResult = await accountRepository.getAccountById(id);

      return await currentAccountResult.fold(Either.left, (
        currentAccount,
      ) async {
        if (currentAccount == null) {
          return Either.left(const ValidationFailure('Account not found'));
        }

        if (_hasNoChanges(
          currentAccount: currentAccount,
          name: name,
          accountType: accountType,
          initialBalance: initialBalance,
          currencyType: currencyType,
          isActive: isActive,
          iconType: iconType,
          initDate: initDate,
        )) {
          return Either.left(
            const NoChangesFailure('No changes were provided'),
          );
        }

        final accountCompanion = AccountsCompanion(
          name: name != null ? Value(name.value) : const Value.absent(),
          accountType: accountType != null
              ? Value(accountType)
              : const Value.absent(),
          initialBalance: initialBalance != null
              ? Value(initialBalance.value)
              : const Value.absent(),
          currencyType: currencyType != null
              ? Value(currencyType)
              : const Value.absent(),
          isActive: isActive != null ? Value(isActive) : const Value.absent(),
          iconType: iconType != null ? Value(iconType) : const Value.absent(),
          initDate: initDate != null ? Value(initDate) : const Value.absent(),
        );

        return accountRepository.updateAccount(id, accountCompanion);
      });
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error editing account: $e'),
      );
    }
  }

  Future<Either<Failure, bool>> deleteAccount(int id) async {
    try {
      return await accountRepository.deleteAccount(id);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error deleting account: $e'),
      );
    }
  }

  bool _hasNoChanges({
    required AccountData currentAccount,
    AccountName? name,
    AccountType? accountType,
    Balance? initialBalance,
    CurrencyType? currencyType,
    bool? isActive,
    AccountIconType? iconType,
    DateTime? initDate,
  }) {
    return (name == null || name.value == currentAccount.name) &&
        (accountType == null || accountType == currentAccount.accountType) &&
        (initialBalance == null ||
            initialBalance.value == currentAccount.initialBalance) &&
        (currencyType == null || currencyType == currentAccount.currencyType) &&
        (isActive == null || isActive == currentAccount.isActive) &&
        (iconType == null || iconType == currentAccount.iconType) &&
        (initDate == null || _datesAreEqual(initDate, currentAccount.initDate));
  }

  bool _datesAreEqual(DateTime? date1, DateTime date2) {
    if (date1 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day &&
        date1.hour == date2.hour &&
        date1.minute == date2.minute &&
        date1.second == date2.second;
  }
}
