import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../domain/index.dart';
import '../presentation/index.dart';

abstract class IAccountUsecase {
  Future<Either<Failure, AccountData>> createStandardAccount({
    required AccountName name,
    required Balance initialBalance,
    AccountIconType iconType = AccountIconType.none,
    CurrencyType currencyType = CurrencyType.brl,
    DateTime? initDate,
  });

  Future<Either<Failure, AccountData>> createCreditCardAccount({
    required AccountName name,
    required CreditLimit creditLimit,
    required DateTime firstBillDueDate,
    required BillClosingDay billClosingDay,
    required int paymentAccountId,
    AccountIconType iconType = AccountIconType.none,
    CurrencyType currencyType = CurrencyType.brl,
    DateTime? initDate,
  });

  Future<Either<Failure, List<AccountData>>> getAllAccounts({
    bool onlyActive = true,
  });

  Future<Either<Failure, List<AccountData>>> getCheckingAccounts({
    bool onlyActive = true,
  });

  Future<Either<Failure, List<AccountData>>> getCreditCardAccounts({
    bool onlyActive = true,
  });

  Future<Either<Failure, AccountData?>> getAccountById(int id);

  Future<Either<Failure, AccountData>> updateStandardAccount({
    required int id,
    AccountName? name,
    Balance? initialBalance,
    CurrencyType? currencyType,
    bool? isActive,
    AccountIconType? iconType,
    DateTime? initDate,
  });

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
  });

  Future<Either<Failure, bool>> deleteAccount(int id);

  Future<Either<Failure, Map<AccountType, List<AccountData>>>>
  getGroupedAccounts({bool onlyActive = true});

  Future<Either<Failure, double>> getAccountFinalBalance(int accountId);
}
