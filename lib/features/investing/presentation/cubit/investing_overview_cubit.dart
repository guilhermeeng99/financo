import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/portfolio_valuation.dart';
import 'package:financo/features/investing/domain/entities/snapshot.dart';
import 'package:financo/features/investing/domain/usecases/get_asset_transactions_usecase.dart';
import 'package:financo/features/investing/domain/usecases/get_assets_usecase.dart';
import 'package:financo/features/investing/domain/usecases/get_snapshots_usecase.dart';
import 'package:financo/features/investing/domain/usecases/record_daily_snapshot_usecase.dart';
import 'package:financo/features/investing/presentation/portfolio_pricing_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Session-scoped investing net-worth overview. Prices the portfolio from the
/// local cache first (instant), then refreshes quotes/FX/indices from the
/// network and re-prices. At the end of a refresh it records the day's snapshot
/// (idempotent) so the net-worth history accrues. Owns a per-cubit
/// [PortfolioPricingEngine] (mutable FX/index state). See `docs/specs/quotes.md`
/// and `docs/specs/valuation.md`.
class InvestingOverviewCubit extends Cubit<InvestingOverviewState> {
  InvestingOverviewCubit({
    required PortfolioPricingEngine engine,
    required GetAssetTransactionsUseCase getTransactions,
    required GetAssetsUseCase getAssets,
    required GetSnapshotsUseCase getSnapshots,
    required RecordDailySnapshotUseCase recordSnapshot,
    required String userId,
  }) : _engine = engine,
       _getTransactions = getTransactions,
       _getAssets = getAssets,
       _getSnapshots = getSnapshots,
       _recordSnapshot = recordSnapshot,
       _userId = userId,
       super(const InvestingOverviewLoading());

  final PortfolioPricingEngine _engine;
  final GetAssetTransactionsUseCase _getTransactions;
  final GetAssetsUseCase _getAssets;
  final GetSnapshotsUseCase _getSnapshots;
  final RecordDailySnapshotUseCase _recordSnapshot;
  final String _userId;

  bool _warmStarted = false;

  Future<void> load({bool force = false}) async {
    if (state is! InvestingOverviewLoaded) {
      emit(const InvestingOverviewLoading());
    }

    if (!_warmStarted) {
      await _engine.warmStart();
      _warmStarted = true;
    }

    final txResult = await _getTransactions(
      userId: _userId,
      forceRefresh: force,
    );
    final txFailure = txResult.fold<Failure?>((f) => f, (_) => null);
    if (txFailure != null) {
      emit(InvestingOverviewError(txFailure));
      return;
    }
    final assetsResult = await _getAssets(userId: _userId, forceRefresh: force);
    final assetsFailure = assetsResult.fold<Failure?>((f) => f, (_) => null);
    if (assetsFailure != null) {
      emit(InvestingOverviewError(assetsFailure));
      return;
    }

    final transactions = txResult.getOrElse(() => const []);
    final assets = assetsResult.getOrElse(() => const []);
    var history = await _loadSnapshots(force: force);

    // Instant paint from the local quote cache.
    final cached = await _engine.priceFromCache(transactions, assets);
    emit(
      InvestingOverviewLoaded(
        portfolio: cached.portfolio,
        assetsById: cached.assetsById,
        snapshots: history,
        isRefreshing: true,
      ),
    );

    // Best-effort network refresh, then re-price. A failure keeps the cached
    // values on screen (the catch swallows it).
    final held = _engine.heldPositions(transactions, assets);
    final skip = !force && await _engine.quotesAreFresh(held.ids);
    if (!skip) {
      try {
        await _engine.refreshNetwork(held.assets, transactions);
      } on Object {
        // Network failure — serve the cached prices, flagged stale downstream.
      }
    }

    final repriced = await _engine.priceFromCache(transactions, assets);
    // Record today's point, then re-read so the fresh snapshot shows up.
    await _recordSnapshot(
      userId: _userId,
      portfolio: repriced.portfolio,
      today: DateTime.now(),
    );
    history = await _loadSnapshots(force: false);
    if (isClosed) return;
    emit(
      InvestingOverviewLoaded(
        portfolio: repriced.portfolio,
        assetsById: repriced.assetsById,
        snapshots: history,
        isRefreshing: false,
      ),
    );
  }

  /// Snapshots for the history chart. A read failure is non-fatal — the chart
  /// just stays empty rather than blocking the whole overview.
  Future<List<Snapshot>> _loadSnapshots({required bool force}) async {
    final result = await _getSnapshots(userId: _userId, forceRefresh: force);
    return result.getOrElse(() => const []);
  }
}

sealed class InvestingOverviewState extends Equatable {
  const InvestingOverviewState();

  @override
  List<Object?> get props => [];
}

final class InvestingOverviewLoading extends InvestingOverviewState {
  const InvestingOverviewLoading();
}

final class InvestingOverviewLoaded extends InvestingOverviewState {
  const InvestingOverviewLoaded({
    required this.portfolio,
    required this.assetsById,
    required this.snapshots,
    required this.isRefreshing,
  });

  final PortfolioValuation portfolio;
  final Map<String, Asset> assetsById;
  final List<Snapshot> snapshots;
  final bool isRefreshing;

  @override
  List<Object?> get props => [portfolio, assetsById, snapshots, isRefreshing];
}

final class InvestingOverviewError extends InvestingOverviewState {
  const InvestingOverviewError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
