import 'package:dartz/dartz.dart';
import 'package:financo/core/cache/app_data_cache.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/data/datasources/account_remote_datasource.dart';
import 'package:financo/features/accounts/data/models/account_model.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl({
    required AccountRemoteDataSource remoteDataSource,
    required AppDataCache cache,
  }) : _remote = remoteDataSource,
       _cache = cache;

  final AccountRemoteDataSource _remote;
  final AppDataCache _cache;

  @override
  Future<Either<Failure, List<AccountEntity>>> getAccounts({
    required String userId,
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _cache.accounts != null) {
        return Right(_cache.accounts!);
      }
      final result = await _remote.getAccounts(userId: userId);
      _cache.accounts = result;
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> getAccount(String id) async {
    try {
      final result = await _remote.getAccount(id);
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
      _cache.accounts = null;
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
      _cache.accounts = null;
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String id) async {
    try {
      await _remote.deleteAccount(id);
      _cache.accounts = null;
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
