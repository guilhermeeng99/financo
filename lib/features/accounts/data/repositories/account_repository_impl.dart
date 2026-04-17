import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/accounts_dao.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
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
  }) async {
    try {
      if (forceRefresh) {
        final remote = await _remote.getAccounts(userId: userId);
        await _dao.deleteAllAccounts();
        if (remote.isNotEmpty) {
          await _dao.insertAllAccounts(remote);
        }
      }
      return Right(await _dao.getAccounts(userId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> getAccount(String id) async {
    try {
      final local = await _dao.getAccountById(id);
      if (local != null) return Right(local);
      final result = await _remote.getAccount(id);
      await _dao.upsertAccount(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> createAccount(
    AccountEntity account,
  ) async {
    try {
      final model = AccountModel.fromEntity(account);
      final result = await _remote.createAccount(model);
      await _dao.upsertAccount(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> updateAccount(
    AccountEntity account,
  ) async {
    try {
      final model = AccountModel.fromEntity(account);
      final result = await _remote.updateAccount(model);
      await _dao.upsertAccount(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String id) async {
    try {
      await _remote.deleteAccount(id);
      await _dao.deleteAccount(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
