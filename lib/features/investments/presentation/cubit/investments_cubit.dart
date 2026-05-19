import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';
import 'package:financo/features/investments/domain/entities/investment_overview.dart';
import 'package:financo/features/investments/domain/repositories/asset_holding_repository.dart';
import 'package:financo/features/investments/domain/usecases/get_investment_overview_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shell-scoped cubit that owns the investments snapshot. Lives for
/// the whole session so the dashboard banner (V1.1 follow-up) can
/// observe `totalPending` without waiting for the user to open the
/// page. The page calls `refresh(forceRefresh: true)` on mount.
class InvestmentsCubit extends Cubit<InvestmentsState> {
  InvestmentsCubit({
    required GetInvestmentOverviewUseCase getOverview,
    required AssetHoldingRepository assetHoldingRepository,
    required String userId,
  }) : _getOverview = getOverview,
       _holdingRepository = assetHoldingRepository,
       _userId = userId,
       super(const InvestmentsInitial());

  final GetInvestmentOverviewUseCase _getOverview;
  final AssetHoldingRepository _holdingRepository;
  final String _userId;

  Future<void> refresh({bool forceRefresh = false}) async {
    // Show the shimmer whenever the caller explicitly asked for fresh
    // data (`forceRefresh: true`) or there is nothing to show yet.
    // Passive background refreshes (e.g. the shell preload on session
    // start) keep the previous snapshot visible to avoid flicker.
    if (forceRefresh || state is! InvestmentsLoaded) {
      emit(const InvestmentsLoading());
    }
    final result = await _getOverview(
      userId: _userId,
      forceRefresh: forceRefresh,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(InvestmentsError(failure)),
      (snapshot) => emit(InvestmentsLoaded(snapshot)),
    );
  }

  /// Cascade-delete called by AccountsCubit after a successful account
  /// delete. Best-effort: errors are emitted only as a state so the
  /// caller never blocks an account delete on holding cleanup. Returns
  /// once the local + remote cleanup attempt completes so the caller
  /// can chain its own refresh.
  Future<void> removeHoldingsForAccount(String accountId) async {
    await _holdingRepository.deleteHoldingsForAccount(accountId);
    await refresh(forceRefresh: true);
  }
}

sealed class InvestmentsState extends Equatable {
  const InvestmentsState();

  @override
  List<Object?> get props => const [];
}

final class InvestmentsInitial extends InvestmentsState {
  const InvestmentsInitial();
}

final class InvestmentsLoading extends InvestmentsState {
  const InvestmentsLoading();
}

final class InvestmentsLoaded extends InvestmentsState {
  const InvestmentsLoaded(this.snapshot);

  final InvestmentSnapshot snapshot;

  InvestmentOverview get overview => snapshot.overview;
  List<AccountEntity> get accounts => snapshot.accounts;
  List<AssetClassEntity> get classes => snapshot.classes;
  List<AssetHoldingEntity> get holdings => snapshot.holdings;

  @override
  List<Object?> get props => [snapshot];
}

final class InvestmentsError extends InvestmentsState {
  const InvestmentsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
