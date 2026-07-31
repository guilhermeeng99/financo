import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/repositories/asset_transaction_repository.dart';
import 'package:financo/features/investing/domain/usecases/sync_investment_cash_flow_usecase.dart';

/// Deletes an investing transaction and the checking-side cash row it
/// generated, so an aporte/resgate never survives the buy/sell it mirrors
/// (F8.4 rule 6 — `docs/specs/investing_account_unification.md`).
///
/// Takes the whole [AssetTransaction] rather than an id because the cascade
/// needs its `userId` to find the paired row.
class DeleteAssetTransactionUseCase {
  const DeleteAssetTransactionUseCase(this._repo, this._syncCashFlow);

  final AssetTransactionRepository _repo;
  final SyncInvestmentCashFlowUseCase _syncCashFlow;

  Future<Either<Failure, void>> call(AssetTransaction transaction) async {
    // Cash row first: if it fails, the investing row is still there and the
    // user can retry, whereas the reverse order would strand an untagged
    // income/expense with no way to reach it from the investing UI.
    final synced = await _syncCashFlow(transaction, investingDeleted: true);
    final syncFailure = synced.fold<Failure?>((f) => f, (_) => null);
    if (syncFailure != null) return Left(syncFailure);
    return _repo.deleteTransaction(transaction.id);
  }
}
