import 'package:app_database/app_database.dart';
import 'package:app_database/src/items/account/account_repository.dart';
import 'package:app_database/src/items/transaction/transaction_repository.dart';
import 'package:drift/drift.dart';

class AccountUsecase {
  AccountUsecase(this._accountRepository, this._transactionRepository);

  final IAccountRepository _accountRepository;
  final ITransactionRepository _transactionRepository;

  Future<Either<Failure, AccountData>> createAccount({
    required String name,
    required AccountType accountType,
    required double initialBalance,
    AccountIconType iconType = AccountIconType.none,
    CurrencyType currencyType = CurrencyType.brl,
    DateTime? initDate,
  }) async {
    try {
      final accountName = AccountName.create(name);
      final initBalance = Balance.create(initialBalance);

      final accountCompanion = AccountsCompanion(
        name: Value(accountName.value),
        accountType: Value(accountType),
        initialBalance: Value(initBalance.value),
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

  Future<Either<Failure, List<AccountData>>> getAllAccounts({
    bool onlyActive = true,
  }) async {
    return _accountRepository.getAllAccounts(onlyActive: onlyActive);
  }

  Future<Either<Failure, List<AccountData>>> getCheckingAccounts({
    bool onlyActive = true,
  }) async {
    return _accountRepository.getAccountsByType(
      AccountType.checking,
      onlyActive: onlyActive,
    );
  }

  Future<Either<Failure, AccountData?>> getAccountById(int id) async {
    try {
      return await _accountRepository.getAccountById(id);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error fetching account by id: $e'),
      );
    }
  }

  Future<Either<Failure, AccountData>> updateAccount({
    required int id,
    String? name,
    AccountType? accountType,
    double? initialBalance,
    CurrencyType? currencyType,
    bool? isActive,
    AccountIconType? iconType,
    DateTime? initDate,
  }) async {
    try {
      Value<String>? nameValue;
      Value<AccountType>? accountTypeValue;
      Value<double>? initialBalanceValue;
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

   
      if (initialBalance != null) {
        final accountInitialBalance = Balance.create(initialBalance);
        initialBalanceValue = Value(accountInitialBalance.value);
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
          initialBalanceValue == null &&
          currencyTypeValue == null &&
          isActiveValue == null &&
          iconTypeValue == null &&
          initDateValue == null) {
        return Either.left(const ValidationFailure('No changes were provided'));
      }

      final accountCompanion = AccountsCompanion(
        name: nameValue ?? const Value.absent(),
        accountType: accountTypeValue ?? const Value.absent(),
        initialBalance: initialBalanceValue ?? const Value.absent(),
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

  Future<Either<Failure, Map<AccountType, List<AccountData>>>>
  getGroupedAccounts({bool onlyActive = true}) async {
    try {
      final grouped = <AccountType, List<AccountData>>{};

      for (final type in AccountType.values) {
        final accountsResult = await _accountRepository.getAccountsByType(
          type,
          onlyActive: onlyActive,
        );

        final accounts = accountsResult.fold(
          (failure) => null,
          (accounts) => accounts,
        );

        if (accounts == null) {
          return accountsResult.fold(
            Either.left,
            (_) => throw StateError('This should never happen'),
          );
        }

        if (accounts.isNotEmpty) {
          grouped[type] = accounts;
        }
      }

      return Either.right(grouped);
    } catch (e) {
      return Either.left(DatabaseFailure('Error grouping accounts: $e'));
    }
  }

  Future<Either<Failure, double>> getAccountFinalBalance(int accountId) async {
    try {
      final accountResult = await getAccountById(accountId);

      return accountResult.fold(Either.left, (account) async {
        if (account == null) {
          return Either.left(const DatabaseFailure('Account not found'));
        }

        final transactionBalanceResult = await _transactionRepository
            .getAccountBalanceById(accountId);

        return transactionBalanceResult.fold(Either.left, (
          double transactionBalance,
        ) {
          final finalBalance = account.initialBalance + transactionBalance;
          return Either.right(finalBalance);
        });
      });
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error calculating account final balance: $e'),
      );
    }
  }
}
