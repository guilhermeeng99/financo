import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';

abstract class AccountRepository {
  Future<Either<Failure, List<AccountEntity>>> getAccounts({
    required String userId,
    bool forceRefresh = false,
  });

  Future<Either<Failure, AccountEntity>> getAccount(String id);

  Future<Either<Failure, AccountEntity>> createAccount(
    AccountEntity account,
  );

  Future<Either<Failure, AccountEntity>> updateAccount(
    AccountEntity account,
  );

  Future<Either<Failure, void>> deleteAccount(String id);
}
