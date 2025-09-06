import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../domain/index.dart';
import '../presentation/index.dart';

abstract class IAccountUsecase {
  Future<Either<Failure, AccountData>> createAccount({
    required AccountName name,
    required AccountType accountType,
    required Balance initialBalance,
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

  Future<Either<Failure, AccountData?>> getAccountById(int id);

  Future<Either<Failure, AccountData>> updateAccount({
    required int id,
    AccountName? name,
    AccountType? accountType,
    Balance? initialBalance,
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
