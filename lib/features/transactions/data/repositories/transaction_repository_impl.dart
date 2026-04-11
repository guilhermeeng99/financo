import 'package:dartz/dartz.dart';
import 'package:financo/core/cache/app_data_cache.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:financo/features/transactions/data/models/transaction_model.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({
    required TransactionRemoteDataSource remoteDataSource,
    required AppDataCache cache,
  }) : _remote = remoteDataSource,
       _cache = cache;

  final TransactionRemoteDataSource _remote;
  final AppDataCache _cache;

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? accountId,
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _cache.transactions != null) {
        return Right(_cache.transactions!);
      }
      final result = await _remote.getTransactions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
        accountId: accountId,
      );
      _cache.transactions = result;
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(String id) async {
    try {
      final result = await _remote.getTransaction(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final result = await _remote.createTransaction(model);
      _cache.transactions = null;
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final result = await _remote.updateTransaction(model);
      _cache.transactions = null;
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await _remote.deleteTransaction(id);
      _cache.transactions = null;
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> toggleReconciled(String id) async {
    try {
      final result = await _remote.getTransaction(id);
      final updated = TransactionModel.fromEntity(
        result.copyWith(isReconciled: !result.isReconciled),
      );
      await _remote.updateTransaction(updated);
      _cache.transactions = null;
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
