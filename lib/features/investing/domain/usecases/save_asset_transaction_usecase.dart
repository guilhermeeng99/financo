import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/repositories/asset_repository.dart';
import 'package:financo/features/investing/domain/repositories/asset_transaction_repository.dart';
import 'package:financo/features/investing/domain/services/oversell_check.dart';
import 'package:financo/features/investing/domain/usecases/sync_investment_cash_flow_usecase.dart';

/// Creates or updates a transaction after enforcing the rules in
/// `investing_transactions.md`: future-date, institution-match with the asset,
/// non-positive quantity for buy/sell, and no oversell across the whole
/// re-validated position timeline. Both the form and the CSV importer go
/// through this use case.
///
/// When the transaction carries a `fundingAccountId`, saving it also reconciles
/// the paired checking-side cash row (F8.4), so an aporte/resgate is a single
/// user action across both ledgers.
class SaveAssetTransactionUseCase {
  const SaveAssetTransactionUseCase({
    required AssetTransactionRepository transactionRepository,
    required AssetRepository assetRepository,
    required SyncInvestmentCashFlowUseCase syncCashFlow,
  }) : _transactions = transactionRepository,
       _assets = assetRepository,
       _syncCashFlow = syncCashFlow;

  final AssetTransactionRepository _transactions;
  final AssetRepository _assets;
  final SyncInvestmentCashFlowUseCase _syncCashFlow;

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

    final savedResult = await _transactions.saveTransaction(tx);
    final saveFailure = savedResult.fold<Failure?>((f) => f, (_) => null);
    if (saveFailure != null) return Left(saveFailure);
    final saved = savedResult.getOrElse(() => tx);

    final syncResult = await _syncCashFlow(saved);
    final syncFailure = syncResult.fold<Failure?>((f) => f, (_) => null);
    if (syncFailure == null) return Right(saved);

    // The cash leg is what makes the money show up on the checking account and
    // in 50/30/20; a half-landed aporte is worse than none. A create can be
    // undone cleanly, so roll it back. An edit cannot (the previous values are
    // gone), so surface the failure and leave the investing row updated — the
    // next save reconciles the cash row again.
    if (tx.id.isEmpty) await _transactions.deleteTransaction(saved.id);
    return Left(syncFailure);
  }

  Asset? _findById(List<Asset> assets, String id) {
    for (final a in assets) {
      if (a.id == id) return a;
    }
    return null;
  }
}
