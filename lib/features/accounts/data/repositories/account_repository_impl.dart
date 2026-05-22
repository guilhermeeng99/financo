import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/accounts_dao.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/repository_guard.dart';
import 'package:financo/features/accounts/data/datasources/account_remote_datasource.dart';
import 'package:financo/features/accounts/data/models/account_model.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl({
    required AccountRemoteDataSource remoteDataSource,
    required AccountsDao accountsDao,
  }) : _remote = remoteDataSource,
       _dao = accountsDao;

  final AccountRemoteDataSource _remote;
  final AccountsDao _dao;

  @override
  Future<Either<Failure, List<AccountEntity>>> getAccounts({
    required String userId,
    bool forceRefresh = false,
  }) {
    return guardServer(() async {
      if (forceRefresh) {
        final remote = await _remote.getAccounts(userId: userId);
        await _dao.deleteAllAccounts();
        if (remote.isNotEmpty) {
          await _dao.insertAllAccounts(remote);
        }
      }
      return _dao.getAccounts(userId);
    });
  }

  @override
  Future<Either<Failure, AccountEntity>> getAccount(String id) {
    return guardServer(() async {
      final local = await _dao.getAccountById(id);
      if (local != null) return local;
      final result = await _remote.getAccount(id);
      await _dao.upsertAccount(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, AccountEntity>> createAccount(AccountEntity account) {
    return guardServer(() async {
      final result = await _remote.createAccount(
        AccountModel.fromEntity(account),
      );
      await _dao.upsertAccount(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, AccountEntity>> updateAccount(AccountEntity account) {
    return guardServer(() async {
      final result = await _remote.updateAccount(
        AccountModel.fromEntity(account),
      );
      await _dao.upsertAccount(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String id) {
    return guardServerVoid(() async {
      await _remote.deleteAccount(id);
      await _dao.deleteAccount(id);
    });
  }
}
