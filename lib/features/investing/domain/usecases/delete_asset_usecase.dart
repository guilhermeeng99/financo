import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/repositories/asset_repository.dart';
import 'package:financo/features/investing/domain/repositories/asset_transaction_repository.dart';

/// Deletes an asset, blocked while it still has transactions
/// (investing_assets.md rule 5).
class DeleteAssetUseCase {
  const DeleteAssetUseCase({
    required AssetRepository assetRepository,
    required AssetTransactionRepository transactionRepository,
  }) : _assets = assetRepository,
       _transactions = transactionRepository;

  final AssetRepository _assets;
  final AssetTransactionRepository _transactions;

  Future<Either<Failure, void>> call(Asset asset) async {
    final txsResult = await _transactions.getTransactions(
      userId: asset.userId,
    );
    final failure = txsResult.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) return Left(failure);

    final referenced = txsResult
        .getOrElse(() => const [])
        .any((t) => t.assetId == asset.id);
    if (referenced) return const Left(AssetInUseFailure());

    return _assets.deleteAsset(asset.id);
  }
}
