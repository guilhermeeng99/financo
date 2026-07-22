import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/investment_transactions_dao.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/repository_guard.dart';
import 'package:financo/features/investing/data/datasources/asset_transaction_remote_datasource.dart';
import 'package:financo/features/investing/data/models/asset_transaction_model.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/repositories/asset_transaction_repository.dart';

class AssetTransactionRepositoryImpl implements AssetTransactionRepository {
  AssetTransactionRepositoryImpl({
    required AssetTransactionRemoteDataSource remoteDataSource,
    required InvestmentTransactionsDao transactionsDao,
  }) : _remote = remoteDataSource,
       _dao = transactionsDao;

  final AssetTransactionRemoteDataSource _remote;
  final InvestmentTransactionsDao _dao;

  @override
  Future<Either<Failure, List<AssetTransaction>>> getTransactions({
    required String userId,
    bool forceRefresh = false,
  }) {
    return guardServer(() async {
      if (forceRefresh) {
        final remote = await _remote.getTransactions(userId: userId);
        await _dao.deleteAllTransactions();
        if (remote.isNotEmpty) {
          await _dao.insertAllTransactions(remote);
        }
      }
      return _dao.getTransactions(userId);
    });
  }

  @override
  Future<Either<Failure, AssetTransaction>> saveTransaction(
    AssetTransaction tx,
  ) {
    return guardServer(() async {
      final model = AssetTransactionModel.fromEntity(tx);
      final result = tx.id.isEmpty
          ? await _remote.createTransaction(model)
          : await _remote.updateTransaction(model);
      await _dao.upsertTransaction(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) {
    return guardServerVoid(() async {
      await _remote.deleteTransaction(id);
      await _dao.deleteTransaction(id);
    });
  }
}
