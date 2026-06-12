import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/transactions_dao.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/repository_guard.dart';
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
    DateTime? dueStartDate,
    DateTime? dueEndDate,
    String? categoryId,
    String? accountId,
    TransactionSettlementStatus? settlementStatus,
    TransactionRecurrence? recurrence,
    String? recurrenceGroupId,
    bool forceRefresh = false,
  }) {
    return guardServer(() async {
      if (forceRefresh) {
        final remote = await _remote.getTransactions(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
          dueStartDate: dueStartDate,
          dueEndDate: dueEndDate,
          categoryId: categoryId,
          accountId: accountId,
          settlementStatus: settlementStatus,
          recurrence: recurrence,
          recurrenceGroupId: recurrenceGroupId,
        );
        // Upsert (not replace-all): transactions are paged by date range,
        // so wiping the local table here would discard rows outside the
        // current window. Diverges from accounts/categories on purpose —
        // see docs/specs/transactions.md cache strategy.
        await _dao.insertAllTransactions(remote);
      }
      return _dao.getTransactions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        dueStartDate: dueStartDate,
        dueEndDate: dueEndDate,
        accountId: accountId,
        categoryId: categoryId,
        settlementStatus: settlementStatus,
        recurrence: recurrence,
        recurrenceGroupId: recurrenceGroupId,
      );
    });
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(String id) {
    return guardServer(() async {
      final local = await _dao.getTransactionById(id);
      if (local != null) return local;
      final result = await _remote.getTransaction(id);
      await _dao.upsertTransaction(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity transaction,
  ) {
    return guardServer(() async {
      final model = TransactionModel.fromEntity(transaction);
      final result = await _remote.createTransaction(model);
      await _dao.upsertTransaction(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> createTransactions(
    List<TransactionEntity> transactions,
  ) {
    return guardServer(() async {
      final models = transactions.map(TransactionModel.fromEntity).toList();
      final results = await _remote.createTransactions(models);
      if (results.isNotEmpty) {
        await _dao.insertAllTransactions(results);
      }
      return results;
    });
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  ) {
    return guardServer(() async {
      final model = TransactionModel.fromEntity(transaction);
      final result = await _remote.updateTransaction(model);
      await _dao.upsertTransaction(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> updateTransactions(
    List<TransactionEntity> transactions,
  ) {
    return guardServer(() async {
      final models = transactions.map(TransactionModel.fromEntity).toList();
      final results = await _remote.updateTransactions(models);
      if (results.isNotEmpty) {
        await _dao.insertAllTransactions(results);
      }
      return results;
    });
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) {
    return guardServerVoid(() async {
      // Transfers are two linked docs — delete both legs atomically so a
      // mid-delete failure can't leave a dangling half-transfer.
      final local = await _dao.getTransactionById(id);
      final linkedId = local?.linkedTransactionId;
      if (linkedId != null) {
        await _remote.deleteTransfer(id, linkedId);
        await _dao.deleteTransaction(linkedId);
      } else {
        await _remote.deleteTransaction(id);
      }
      await _dao.deleteTransaction(id);
    });
  }

  @override
  Future<Either<Failure, void>> deleteTransactions(List<String> ids) {
    return guardServerVoid(() async {
      await _remote.deleteTransactions(ids);
      await _dao.deleteTransactions(ids);
    });
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> createTransfer({
    required TransactionEntity expense,
    required TransactionEntity income,
  }) {
    return guardServer(() async {
      final expenseModel = TransactionModel.fromEntity(expense);
      final incomeModel = TransactionModel.fromEntity(income);
      final results = await _remote.createTransfer(
        expense: expenseModel,
        income: incomeModel,
      );
      await _dao.upsertTransaction(results[0]);
      await _dao.upsertTransaction(results[1]);
      return results;
    });
  }

  /// Batch reassignment runs Firestore-only; the local Drift cache is
  /// left stale on purpose because rewriting hundreds of rows locally
  /// would block the UI thread. Callers (e.g. `delete_category_cubit`)
  /// MUST follow this up with `getTransactions(forceRefresh: true)` so
  /// the cache catches up. See docs/specs/transactions.md.
  @override
  Future<Either<Failure, void>> reassignTransactions({
    required String fromCategoryId,
    required String toCategoryId,
  }) {
    return guardServerVoid(() {
      return _remote.reassignTransactions(
        fromCategoryId: fromCategoryId,
        toCategoryId: toCategoryId,
      );
    });
  }
}
