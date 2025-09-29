import '../../../../core/either.dart';
import '../../../../core/failures.dart';
import '../../domain/index.dart';
import '../../presentation/index.dart';
import '../../repository/i_account_repository.dart';
import 'account_companion_builder.dart';
import 'account_validation_helper.dart';

mixin AccountUpdateOperations {
  IAccountRepository get accountRepository;

  Future<Either<Failure, AccountData>> updateStandardAccount({
    required int id,
    AccountName? name,
    Balance? initialBalance,
    CurrencyType? currencyType,
    bool? isActive,
    AccountIconType? iconType,
    DateTime? initDate,
  }) async {
    try {
      return await _performStandardAccountUpdate(
        id: id,
        name: name,
        initialBalance: initialBalance,
        currencyType: currencyType,
        isActive: isActive,
        iconType: iconType,
        initDate: initDate,
      );
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error editing standard account: $e'),
      );
    }
  }

  Future<Either<Failure, AccountData>> updateCreditCardAccount({
    required int id,
    AccountName? name,
    CreditLimit? creditLimit,
    DateTime? firstBillDueDate,
    BillClosingDay? billClosingDay,
    int? paymentAccountId,
    CurrencyType? currencyType,
    bool? isActive,
    AccountIconType? iconType,
    DateTime? initDate,
  }) async {
    try {
      return await _performCreditCardAccountUpdate(
        id: id,
        name: name,
        creditLimit: creditLimit,
        firstBillDueDate: firstBillDueDate,
        billClosingDay: billClosingDay,
        paymentAccountId: paymentAccountId,
        currencyType: currencyType,
        isActive: isActive,
        iconType: iconType,
        initDate: initDate,
      );
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error editing credit card account: $e'),
      );
    }
  }

  Future<Either<Failure, AccountData>> _performStandardAccountUpdate({
    required int id,
    AccountName? name,
    Balance? initialBalance,
    CurrencyType? currencyType,
    bool? isActive,
    AccountIconType? iconType,
    DateTime? initDate,
  }) async {
    final currentAccountResult = await accountRepository.getAccountById(id);

    return await currentAccountResult.fold(Either.left, (
      AccountData? currentAccount,
    ) async {
      if (currentAccount == null) {
        return Either.left(const ValidationFailure('Account not found'));
      }

      if (currentAccount.accountType != AccountType.checking) {
        return Either.left(
          const ValidationFailure('Account is not a standard account'),
        );
      }

      if (AccountValidationHelper.hasNoStandardChanges(
        currentAccount: currentAccount,
        name: name,
        initialBalance: initialBalance,
        currencyType: currencyType,
        isActive: isActive,
        iconType: iconType,
        initDate: initDate,
      )) {
        return Either.left(const NoChangesFailure('No changes were provided'));
      }

      final builder = AccountCompanionBuilder.forUpdate();
      builder.setName(name);
      builder.setInitialBalance(initialBalance);
      builder.setCurrencyType(currencyType);
      builder.setIsActive(isActive);
      builder.setIconType(iconType);
      builder.setInitDate(initDate);
      final companion = builder.build();

      return accountRepository.updateAccount(id, companion);
    });
  }

  Future<Either<Failure, AccountData>> _performCreditCardAccountUpdate({
    required int id,
    AccountName? name,
    CreditLimit? creditLimit,
    DateTime? firstBillDueDate,
    BillClosingDay? billClosingDay,
    int? paymentAccountId,
    CurrencyType? currencyType,
    bool? isActive,
    AccountIconType? iconType,
    DateTime? initDate,
  }) async {
    final currentAccountResult = await accountRepository.getAccountById(id);

    return await currentAccountResult.fold(Either.left, (
      AccountData? currentAccount,
    ) async {
      if (currentAccount == null) {
        return Either.left(const ValidationFailure('Account not found'));
      }

      if (currentAccount.accountType != AccountType.creditCard) {
        return Either.left(
          const ValidationFailure('Account is not a credit card account'),
        );
      }

      if (AccountValidationHelper.hasNoCreditCardChanges(
        currentAccount: currentAccount,
        name: name,
        creditLimit: creditLimit,
        firstBillDueDate: firstBillDueDate,
        billClosingDay: billClosingDay,
        paymentAccountId: paymentAccountId,
        currencyType: currencyType,
        isActive: isActive,
        iconType: iconType,
        initDate: initDate,
      )) {
        return Either.left(const NoChangesFailure('No changes were provided'));
      }

      final builder = AccountCompanionBuilder.forUpdate();
      builder.setName(name);
      builder.setCreditLimit(creditLimit);
      builder.setFirstBillDueDate(firstBillDueDate);
      builder.setBillClosingDay(billClosingDay);
      builder.setPaymentAccountId(paymentAccountId);
      builder.setCurrencyType(currencyType);
      builder.setIsActive(isActive);
      builder.setIconType(iconType);
      builder.setInitDate(initDate);
      final companion = builder.build();

      return accountRepository.updateAccount(id, companion);
    });
  }
}
