import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/allocation_class.dart';
import 'package:financo/features/investing/domain/entities/allocation_overview.dart';
import 'package:financo/features/investing/domain/services/allocation_service.dart';
import 'package:financo/features/investing/domain/usecases/get_asset_transactions_usecase.dart';
import 'package:financo/features/investing/domain/usecases/get_assets_usecase.dart';
import 'package:financo/features/investing/presentation/portfolio_pricing_engine.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/usecases/get_asset_classes_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Session-scoped allocation view: prices the portfolio (cache-first, then
/// network) and computes current-vs-target weights + rebalance moves over
/// market value. Owns a per-cubit [PortfolioPricingEngine], like the overview.
///
/// The bucket source is the surviving `asset_classes` collection, read through
/// the V1 [GetAssetClassesUseCase] and mapped to the investing-owned
/// [AllocationClass] here — the only place coupled to the V1 feature, so F7 can
/// swap the source without touching the service or UI.
class InvestingAllocationCubit extends Cubit<InvestingAllocationState> {
  InvestingAllocationCubit({
    required PortfolioPricingEngine engine,
    required GetAssetTransactionsUseCase getTransactions,
    required GetAssetsUseCase getAssets,
    required GetAssetClassesUseCase getClasses,
    required AllocationService service,
    required String userId,
  }) : _engine = engine,
       _getTransactions = getTransactions,
       _getAssets = getAssets,
       _getClasses = getClasses,
       _service = service,
       _userId = userId,
       super(const InvestingAllocationLoading());

  final PortfolioPricingEngine _engine;
  final GetAssetTransactionsUseCase _getTransactions;
  final GetAssetsUseCase _getAssets;
  final GetAssetClassesUseCase _getClasses;
  final AllocationService _service;
  final String _userId;

  bool _warmStarted = false;

  Future<void> load({bool force = false}) async {
    if (state is! InvestingAllocationLoaded) {
      emit(const InvestingAllocationLoading());
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
      emit(InvestingAllocationError(txFailure));
      return;
    }
    final assetsResult = await _getAssets(userId: _userId, forceRefresh: force);
    final assetsFailure = assetsResult.fold<Failure?>((f) => f, (_) => null);
    if (assetsFailure != null) {
      emit(InvestingAllocationError(assetsFailure));
      return;
    }
    final classesResult = await _getClasses(
      userId: _userId,
      forceRefresh: force,
    );
    final classesFailure = classesResult.fold<Failure?>((f) => f, (_) => null);
    if (classesFailure != null) {
      emit(InvestingAllocationError(classesFailure));
      return;
    }

    final transactions = txResult.getOrElse(() => const []);
    final assets = assetsResult.getOrElse(() => const []);
    final classes = classesResult
        .getOrElse(() => const [])
        .map(_toAllocationClass)
        .toList();

    Future<AllocationOverview> priceAndCompute() async {
      final priced = await _engine.priceFromCache(transactions, assets);
      return _service.compute(
        classes: classes,
        assets: assets,
        holdings: priced.portfolio.holdings,
        base: priced.portfolio.totalValueBase.currency,
      );
    }

    emit(
      InvestingAllocationLoaded(
        overview: await priceAndCompute(),
        isRefreshing: true,
      ),
    );

    final held = _engine.heldPositions(transactions, assets);
    final skip = !force && await _engine.quotesAreFresh(held.ids);
    if (!skip) {
      try {
        await _engine.refreshNetwork(held.assets, transactions);
      } on Object {
        // Network failure — keep the cached prices on screen.
      }
    }

    if (isClosed) return;
    emit(
      InvestingAllocationLoaded(
        overview: await priceAndCompute(),
        isRefreshing: false,
      ),
    );
  }

  AllocationClass _toAllocationClass(AssetClassEntity e) => AllocationClass(
    id: e.id,
    name: e.name,
    icon: e.icon,
    color: e.color,
    targetPercent: e.targetPercent,
    parentId: e.parentId,
  );
}

sealed class InvestingAllocationState extends Equatable {
  const InvestingAllocationState();

  @override
  List<Object?> get props => [];
}

final class InvestingAllocationLoading extends InvestingAllocationState {
  const InvestingAllocationLoading();
}

final class InvestingAllocationLoaded extends InvestingAllocationState {
  const InvestingAllocationLoaded({
    required this.overview,
    required this.isRefreshing,
  });

  final AllocationOverview overview;
  final bool isRefreshing;

  @override
  List<Object?> get props => [overview, isRefreshing];
}

final class InvestingAllocationError extends InvestingAllocationState {
  const InvestingAllocationError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
