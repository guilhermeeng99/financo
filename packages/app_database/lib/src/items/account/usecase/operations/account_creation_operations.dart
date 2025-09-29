import '../../../../core/either.dart';
import '../../../../core/failures.dart';
import '../../domain/index.dart';
import '../../presentation/index.dart';
import '../../repository/i_account_repository.dart';
import 'account_companion_builder.dart';

mixin AccountCreationOperations {
  IAccountRepository get accountRepository;

  Future<Either<Failure, AccountData>> createStandardAccount({
    required AccountName name,
    required Balance initialBalance,
    AccountIconType iconType = AccountIconType.none,
    CurrencyType currencyType = CurrencyType.brl,
    DateTime? initDate,
  }) async {
    try {
      final builder = AccountCompanionBuilder.forStandardAccount(
        name: name,
        initialBalance: initialBalance,
        iconType: iconType,
        currencyType: currencyType,
        initDate: initDate,
      );
      final companion = builder.build();

      return await accountRepository.createAccount(companion);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error creating standard account: $e'),
      );
    }
  }

  Future<Either<Failure, AccountData>> createCreditCardAccount({
    required AccountName name,
    required CreditLimit creditLimit,
    required DateTime firstBillDueDate,
    required BillClosingDay billClosingDay,
    required int paymentAccountId,
    AccountIconType iconType = AccountIconType.none,
    CurrencyType currencyType = CurrencyType.brl,
    DateTime? initDate,
  }) async {
    try {
      final builder = AccountCompanionBuilder.forCreditCardAccount(
        name: name,
        creditLimit: creditLimit,
        firstBillDueDate: firstBillDueDate,
        billClosingDay: billClosingDay,
        paymentAccountId: paymentAccountId,
        iconType: iconType,
        currencyType: currencyType,
        initDate: initDate,
      );
      final companion = builder.build();

      return await accountRepository.createAccount(companion);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error creating credit card account: $e'),
      );
    }
  }
}
