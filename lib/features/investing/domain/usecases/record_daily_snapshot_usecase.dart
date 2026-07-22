import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/portfolio_valuation.dart';
import 'package:financo/features/investing/domain/entities/snapshot.dart';
import 'package:financo/features/investing/domain/repositories/snapshot_repository.dart';

/// Records today's net-worth point from an already-priced [PortfolioValuation].
/// Idempotent per day: called at the end of every dashboard refresh, it just
/// overwrites the day's row. A zero-value portfolio is skipped so an empty or
/// still-loading portfolio never writes a misleading flat line.
class RecordDailySnapshotUseCase {
  const RecordDailySnapshotUseCase(this._repo);

  final SnapshotRepository _repo;

  Future<Either<Failure, Unit>> call({
    required String userId,
    required PortfolioValuation portfolio,
    required DateTime today,
  }) {
    if (portfolio.totalValueBase.isZero && portfolio.totalInvestedBase.isZero) {
      return Future.value(const Right(unit));
    }
    final snapshot = Snapshot(
      userId: userId,
      date: DateTime(today.year, today.month, today.day),
      totalValue: portfolio.totalValueBase,
      totalInvested: portfolio.totalInvestedBase,
      unrealizedPL: portfolio.totalUnrealizedPL,
    );
    return _repo.recordSnapshot(snapshot);
  }
}
