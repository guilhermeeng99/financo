import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../database/database_manager.dart';
import '../domain/account_enums.dart';
import '../domain/account_table.dart';

abstract class IAccountRepository {
  Future<Either<Failure, AccountData>> createAccount(AccountsCompanion account);

  Future<Either<Failure, AccountData?>> getAccountById(int id);

  Future<Either<Failure, AccountData?>> getAccountByName(String name);

  Future<Either<Failure, List<AccountData>>> getAllAccounts({
    bool onlyActive = true,
  });

  Future<Either<Failure, List<AccountData>>> getAccountsByType(
    AccountType type, {
    bool onlyActive = true,
  });

  Future<Either<Failure, AccountData>> updateAccount(
    int id,
    AccountsCompanion account,
  );

  Future<Either<Failure, bool>> deleteAccount(int id);
}
