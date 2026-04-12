import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/transactions_dao.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:financo/features/transactions/data/models/transaction_model.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({
    required TransactionRemoteDataSource remoteDataSource,
    required TransactionsDao transactionsDao,
  }) : _remote = remoteDataSource,
       _dao = transactionsDao;

  final TransactionRemoteDataSource _remote;
  final TransactionsDao _dao;

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
      if (forceRefresh) {
        final remote = await _remote.getTransactions(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
          categoryId: categoryId,
          accountId: accountId,
        );
        await _dao.insertAllTransactions(remote);
      }
      final local = await _dao.getTransactions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
        categoryId: categoryId,
      );
      return Right(local);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(
    String id,
  ) async {
    try {
      final local = await _dao.getTransactionById(id);
      if (local != null) return Right(local);
      final result = await _remote.getTransaction(id);
      await _dao.upsertTransaction(result);
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
      await _dao.upsertTransaction(result);
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
      await _dao.upsertTransaction(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await _remote.deleteTransaction(id);
      await _dao.deleteTransaction(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> toggleReconciled(String id) async {
    try {
      final local = await _dao.getTransactionById(id);
      if (local == null) {
        return const Left(
          ServerFailure('Transaction not found.'),
        );
      }
      final toggled = local.copyWith(
        isReconciled: !local.isReconciled,
      );
      final model = TransactionModel.fromEntity(toggled);
      await _remote.updateTransaction(model);
      await _dao.upsertTransaction(toggled);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> reassignTransactions({
    required String fromCategoryId,
    required String toCategoryId,
  }) async {
    try {
      await _remote.reassignTransactions(
        fromCategoryId: fromCategoryId,
        toCategoryId: toCategoryId,
      );
      // Drift data is now stale for reassigned transactions.
      // Caller should trigger a forceRefresh to re-sync.
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
