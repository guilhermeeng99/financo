import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/repositories/asset_transaction_repository.dart';

class GetAssetTransactionsUseCase {
  const GetAssetTransactionsUseCase(this._repo);

  final AssetTransactionRepository _repo;

  Future<Either<Failure, List<AssetTransaction>>> call({
    required String userId,
    bool forceRefresh = false,
  }) {
    return _repo.getTransactions(userId: userId, forceRefresh: forceRefresh);
  }
}
