import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/repositories/asset_repository.dart';
import 'package:financo/features/investing/domain/repositories/asset_transaction_repository.dart';
import 'package:financo/features/investing/domain/services/oversell_check.dart';

/// Creates or updates a transaction after enforcing the rules in
/// `investing_transactions.md`: future-date, institution-match with the asset,
/// non-positive quantity for buy/sell, and no oversell across the whole
/// re-validated position timeline. Both the form and the CSV importer go
/// through this use case.
class SaveAssetTransactionUseCase {
  const SaveAssetTransactionUseCase({
    required AssetTransactionRepository transactionRepository,
    required AssetRepository assetRepository,
  }) : _transactions = transactionRepository,
       _assets = assetRepository;

  final AssetTransactionRepository _transactions;
  final AssetRepository _assets;

  Future<Either<Failure, AssetTransaction>> call(AssetTransaction tx) async {
    if (tx.date.isAfter(DateTime.now())) {
      return const Left(FutureTransactionDateFailure());
    }

    final assetsResult = await _assets.getAssets(userId: tx.userId);
    final assetsFailure = assetsResult.fold<Failure?>((f) => f, (_) => null);
    if (assetsFailure != null) return Left(assetsFailure);

    final asset = _findById(assetsResult.getOrElse(() => const []), tx.assetId);
    // A missing asset cannot have its institution matched — block rather than
    // persist a dangling transaction (unreachable from the form/CSV, which
    // resolve the asset first).
    if (asset == null) {
      return const Left(TransactionInstitutionMismatchFailure());
    }
    if (asset.institutionId == null || asset.institutionId!.isEmpty) {
      return const Left(AssetInstitutionRequiredFailure());
    }
    if (tx.institutionId != asset.institutionId) {
      return const Left(TransactionInstitutionMismatchFailure());
    }

    if (tx.kind != TransactionKind.dividend && tx.quantity <= 0) {
      return const Left(NonPositiveQuantityFailure());
    }

    final txsResult = await _transactions.getTransactions(userId: tx.userId);
    final txsFailure = txsResult.fold<Failure?>((f) => f, (_) => null);
    if (txsFailure != null) return Left(txsFailure);

    // Re-validate the full (asset, institution) timeline with this transaction
    // applied, so a backdated buy/edit that strands a later sell is caught too.
    final position = <AssetTransaction>[
      for (final t in txsResult.getOrElse(() => const []))
        if (t.assetId == tx.assetId &&
            t.institutionId == tx.institutionId &&
            t.id != tx.id)
          t,
      tx,
    ];
    if (oversellsTimeline(position)) return const Left(OversellFailure());

    return _transactions.saveTransaction(tx);
  }

  Asset? _findById(List<Asset> assets, String id) {
    for (final a in assets) {
      if (a.id == id) return a;
    }
    return null;
  }
}
