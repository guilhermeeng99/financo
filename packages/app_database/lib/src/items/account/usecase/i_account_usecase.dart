import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../domain/index.dart';

abstract class IAccountUsecase {
  Future<Either<Failure, AccountData>> createAccount({
    required String name,
    required AccountType accountType,
    required double initialBalance,
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
    String? name,
    AccountType? accountType,
    double? initialBalance,
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
