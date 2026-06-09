import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_history_entry.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_overview.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';
import 'package:financo/features/dashboard/domain/services/compute_fifty_thirty_twenty.dart';
import 'package:financo/features/dashboard/domain/services/compute_fifty_thirty_twenty_breakdown.dart';
import 'package:financo/features/dashboard/domain/usecases/get_fifty_thirty_twenty_history_usecase.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Owns the data behind `FiftyThirtyTwentyPage`. Coordinates four reads —
/// accounts, categories, period transactions, and a 3-month history —
/// then composes the overview + per-bucket breakdown for the selected
/// month. Distinct from the dashboard pipeline so the detail page can
/// evolve (different filters, larger windows) without dragging the
/// dashboard along.
class FiftyThirtyTwentyDetailCubit extends Cubit<FiftyThirtyTwentyDetailState> {
  FiftyThirtyTwentyDetailCubit({
    required GetAccountsUseCase getAccounts,
    required GetCategoriesUseCase getCategories,
    required GetTransactionsUseCase getTransactions,
    required GetFiftyThirtyTwentyHistoryUseCase getHistory,
    required String userId,
  }) : _getAccounts = getAccounts,
       _getCategories = getCategories,
       _getTransactions = getTransactions,
       _getHistory = getHistory,
       _userId = userId,
       super(const FiftyThirtyTwentyDetailState.initial());

  final GetAccountsUseCase _getAccounts;
  final GetCategoriesUseCase _getCategories;
  final GetTransactionsUseCase _getTransactions;
  final GetFiftyThirtyTwentyHistoryUseCase _getHistory;
  final String _userId;

  /// Loads the overview, breakdown and history for [month] using
  /// [targets] as the user's active split. Always force-refreshes the
  /// page on user action — caching here would only delay the next
  /// classification change visibly reflecting on the page.
  Future<void> load({
    required DateTime month,
    required FiftyThirtyTwentyTargets targets,
  }) async {
    emit(state.copyWith(status: FiftyThirtyTwentyDetailStatus.loading));

    final accountsResult = await _getAccounts(userId: _userId);
    final categoriesResult = await _getCategories(userId: _userId);
    final txResult = await _getTransactions(
      userId: _userId,
      startDate: startOfMonth(month),
      endDate: endOfMonth(month),
    );
    final historyResult = await _getHistory(
      userId: _userId,
      referenceMonth: month,
      targets: targets,
    );

    final accounts = accountsResult.fold((_) => null, (a) => a);
    final categories = categoriesResult.fold((_) => null, (c) => c);
    final txs = txResult.fold(
      (_) => null,
      (t) => t.where((transaction) => transaction.isPaid).toList(),
    );
    final history = historyResult.fold((_) => null, (h) => h);

    if (accounts == null ||
        categories == null ||
        txs == null ||
        history == null) {
      // Surface the first failure that fired — folds short-circuit, so
      // grabbing them in turn is enough.
      final failure = _firstFailure([
        accountsResult.fold((f) => f, (_) => null),
        categoriesResult.fold((f) => f, (_) => null),
        txResult.fold((f) => f, (_) => null),
        historyResult.fold((f) => f, (_) => null),
      ]);
      emit(
        state.copyWith(
          status: FiftyThirtyTwentyDetailStatus.error,
          failure: failure,
        ),
      );
      return;
    }

    final overview = compute50_30_20Overview(
      periodTransactions: txs,
      categories: categories,
      accounts: accounts,
      targets: targets,
    );
    final breakdown = compute50_30_20Breakdown(
      periodTransactions: txs,
      categories: categories,
    );

    emit(
      FiftyThirtyTwentyDetailState(
        status: FiftyThirtyTwentyDetailStatus.ready,
        month: month,
        overview: overview,
        breakdown: breakdown,
        history: history,
        periodTransactions: txs,
      ),
    );
  }

  Failure? _firstFailure(List<Failure?> failures) =>
      failures.firstWhere((f) => f != null, orElse: () => null);
}

enum FiftyThirtyTwentyDetailStatus { initial, loading, ready, error }

class FiftyThirtyTwentyDetailState extends Equatable {
  const FiftyThirtyTwentyDetailState({
    required this.status,
    required this.month,
    required this.overview,
    required this.breakdown,
    required this.history,
    required this.periodTransactions,
    this.failure,
  });

  const FiftyThirtyTwentyDetailState.initial()
    : status = FiftyThirtyTwentyDetailStatus.initial,
      month = null,
      overview = FiftyThirtyTwentyOverview.empty,
      breakdown = FiftyThirtyTwentyBreakdown.empty,
      history = const [],
      periodTransactions = const [],
      failure = null;

  final FiftyThirtyTwentyDetailStatus status;
  final DateTime? month;
  final FiftyThirtyTwentyOverview overview;
  final FiftyThirtyTwentyBreakdown breakdown;
  final List<FiftyThirtyTwentyHistoryEntry> history;

  /// Raw period transactions kept on state so the breakdown drill-down
  /// dialog can show the sub-categories that contributed to a given
  /// root row without a second fetch.
  final List<TransactionEntity> periodTransactions;
  final Failure? failure;

  FiftyThirtyTwentyDetailState copyWith({
    FiftyThirtyTwentyDetailStatus? status,
    DateTime? month,
    FiftyThirtyTwentyOverview? overview,
    FiftyThirtyTwentyBreakdown? breakdown,
    List<FiftyThirtyTwentyHistoryEntry>? history,
    List<TransactionEntity>? periodTransactions,
    Failure? failure,
  }) {
    return FiftyThirtyTwentyDetailState(
      status: status ?? this.status,
      month: month ?? this.month,
      overview: overview ?? this.overview,
      breakdown: breakdown ?? this.breakdown,
      history: history ?? this.history,
      periodTransactions: periodTransactions ?? this.periodTransactions,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    month,
    overview,
    breakdown,
    history,
    periodTransactions,
    failure,
  ];
}
