import 'package:drift/drift.dart';

import '../../../core/either.dart';
import '../../../core/exceptions.dart';
import '../../../core/failures.dart';
import '../../../database/database_manager.dart';
import '../domain/index.dart';
import '../repository/i_account_repository.dart';
import 'account_validation_helpers.dart';

mixin AccountCrudUsecaseOperations {
  IAccountRepository get accountRepository;

  Future<Either<Failure, AccountData>> createAccount({
    required String name,
    required AccountType accountType,
    required double initialBalance,
    AccountIconType iconType = AccountIconType.none,
    CurrencyType currencyType = CurrencyType.brl,
    DateTime? initDate,
  }) async {
    try {
      final nameResult = AccountValidationHelpers.validateAccountName(name);
      if (nameResult.isLeft) {
        return nameResult.fold(
          Either.left,
          (_) => throw StateError('This should never happen'),
        );
      }

      final balanceResult = AccountValidationHelpers.validateBalance(
        initialBalance,
      );
      if (balanceResult.isLeft) {
        return balanceResult.fold(
          Either.left,
          (_) => throw StateError('This should never happen'),
        );
      }

      final accountName = nameResult.fold(
        (_) => throw StateError('This should never happen'),
        (r) => r,
      );
      final initBalance = balanceResult.fold(
        (_) => throw StateError('This should never happen'),
        (r) => r,
      );

      final accountCompanion = AccountsCompanion(
        name: Value(accountName.value),
        accountType: Value(accountType),
        initialBalance: Value(initBalance.value),
        currencyType: Value(currencyType),
        isActive: const Value(true),
        iconType: Value(iconType),
        initDate: Value(initDate ?? DateTime.now()),
      );

      return await accountRepository.createAccount(accountCompanion);
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error creating account: $e'),
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
      if (!AccountValidationHelpers.hasAnyChanges(
        name: name,
        accountType: accountType,
        initialBalance: initialBalance,
        currencyType: currencyType,
        isActive: isActive,
        iconType: iconType,
        initDate: initDate,
      )) {
        return Either.left(const ValidationFailure('No changes were provided'));
      }

      Value<String>? nameValue;
      Value<AccountType>? accountTypeValue;
      Value<double>? initialBalanceValue;
      Value<CurrencyType>? currencyTypeValue;
      Value<bool>? isActiveValue;
      Value<AccountIconType>? iconTypeValue;
      Value<DateTime>? initDateValue;

      if (name != null) {
        final nameResult = AccountValidationHelpers.validateAccountName(name);
        if (nameResult.isLeft) {
          return nameResult.fold(
            Either.left,
            (_) => throw StateError('This should never happen'),
          );
        }
        final accountName = nameResult.fold(
          (_) => throw StateError('This should never happen'),
          (r) => r,
        );
        nameValue = Value(accountName.value);
      }

      if (accountType != null) {
        accountTypeValue = Value(accountType);
      }

      if (initialBalance != null) {
        final balanceResult = AccountValidationHelpers.validateBalance(
          initialBalance,
        );
        if (balanceResult.isLeft) {
          return balanceResult.fold(
            Either.left,
            (_) => throw StateError('This should never happen'),
          );
        }
        final accountInitialBalance = balanceResult.fold(
          (_) => throw StateError('This should never happen'),
          (r) => r,
        );
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

      final accountCompanion = AccountsCompanion(
        name: nameValue ?? const Value.absent(),
        accountType: accountTypeValue ?? const Value.absent(),
        initialBalance: initialBalanceValue ?? const Value.absent(),
        currencyType: currencyTypeValue ?? const Value.absent(),
        isActive: isActiveValue ?? const Value.absent(),
        iconType: iconTypeValue ?? const Value.absent(),
        initDate: initDateValue ?? const Value.absent(),
      );

      return await accountRepository.updateAccount(id, accountCompanion);
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
      return await accountRepository.deleteAccount(id);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error deleting account: $e'),
      );
    }
  }
}
