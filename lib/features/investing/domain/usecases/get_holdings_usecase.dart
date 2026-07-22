import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/holding.dart';
import 'package:financo/features/investing/domain/repositories/asset_transaction_repository.dart';
import 'package:financo/features/investing/domain/services/holding_calculator.dart';

/// Derives current holdings from all of the user's transactions
/// (holdings are never persisted — see `docs/specs/holdings.md`).
class GetHoldingsUseCase {
  const GetHoldingsUseCase(this._repo);

  final AssetTransactionRepository _repo;

  static const _calculator = HoldingCalculator();

  Future<Either<Failure, List<Holding>>> call({
    required String userId,
    bool forceRefresh = false,
  }) async {
    final result = await _repo.getTransactions(
      userId: userId,
      forceRefresh: forceRefresh,
    );
    return result.map(_calculator.derive);
  }
}
