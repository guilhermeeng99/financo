import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/entities/budget_overview.dart';
import 'package:financo/features/budgets/domain/usecases/delete_budget_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/get_budgets_overview_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/import_budgets_csv_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// List + delete cubit for the budgets tab. Owns the currently-viewed
/// `BudgetOverview` list and the cascade between delete → re-load.
///
/// The cubit caches the **last requested month** so dependent reloads
/// (post-delete, post-import) keep the user's month context. The page is
/// expected to drive this via `loadBudgets(month: ...)` whenever the
/// global `DateFilterCubit` changes.
class BudgetsCubit extends Cubit<BudgetsState> {
  BudgetsCubit({
    required GetBudgetsOverviewUseCase getOverview,
    required DeleteBudgetUseCase deleteBudget,
    required ImportBudgetsCsvUseCase importBudgetsCsv,
    required String userId,
  }) : _getOverview = getOverview,
       _deleteBudget = deleteBudget,
       _importBudgetsCsv = importBudgetsCsv,
       _userId = userId,
       super(const BudgetsInitial());

  final GetBudgetsOverviewUseCase _getOverview;
  final DeleteBudgetUseCase _deleteBudget;
  final ImportBudgetsCsvUseCase _importBudgetsCsv;
  final String _userId;

  /// Last month the cubit successfully (or attempted to) load for. Used
  /// by `deleteBudget` / `importCsv` to re-fetch the same window without
  /// the caller having to thread the month through.
  DateTime? _lastMonth;

  /// Parses [csvContent], creates each row as a budget and reloads the
  /// overview so the page reflects the new data. Returns the use-case
  /// result so the import dialog can branch on success vs failure.
  Future<Either<Failure, BudgetImportResult>> importCsv(
    String csvContent,
  ) async {
    final result = await _importBudgetsCsv(
      csvContent: csvContent,
      userId: _userId,
    );
    if (result.isRight()) {
      await loadBudgets(forceRefresh: true);
    }
    return result;
  }

  /// Loads the overview for [month] (defaults to the last requested month,
  /// or the current real month on first load). Pass `forceRefresh: true`
  /// when [month] changed externally — the in-state short-circuit only
  /// trusts a same-month reload.
  Future<void> loadBudgets({
    DateTime? month,
    bool forceRefresh = false,
  }) async {
    final target = month ?? _lastMonth ?? DateTime.now();
    final current = state;
    final sameMonth = current is BudgetsLoaded &&
        current.month.year == target.year &&
        current.month.month == target.month;

    if (sameMonth && !forceRefresh) {
      _lastMonth = target;
      return;
    }
    if (forceRefresh || !sameMonth) {
      emit(const BudgetsLoading());
    }
    _lastMonth = target;
    final result = await _getOverview(
      userId: _userId,
      month: target,
      forceRefresh: forceRefresh,
    );
    result.fold(
      (failure) => emit(BudgetsError(failure)),
      (overviews) =>
          emit(BudgetsLoaded(overviews: overviews, month: target)),
    );
  }

  Future<void> deleteBudget(String id) async {
    final previous = state;
    final result = await _deleteBudget(id);
    await result.fold(
      (failure) async {
        emit(BudgetsError(failure));
        // Restore the prior list so the page doesn't get stuck in an
        // error view after a transient failure — the snackbar already
        // surfaced the message.
        if (previous is BudgetsLoaded) emit(previous);
      },
      (_) async => loadBudgets(forceRefresh: true),
    );
  }
}

sealed class BudgetsState extends Equatable {
  const BudgetsState();

  @override
  List<Object?> get props => const [];
}

final class BudgetsInitial extends BudgetsState {
  const BudgetsInitial();
}

final class BudgetsLoading extends BudgetsState {
  const BudgetsLoading();
}

final class BudgetsLoaded extends BudgetsState {
  const BudgetsLoaded({required this.overviews, required this.month});

  final List<BudgetOverview> overviews;
  final DateTime month;

  /// Sum of every budget's cap. Used by the page-header summary card.
  double get totalCap =>
      overviews.fold<double>(0, (sum, o) => sum + o.budget.amount);

  /// Sum of all spend across every tracked category.
  double get totalSpent =>
      overviews.fold<double>(0, (sum, o) => sum + o.spent);

  double get totalRemaining {
    final r = totalCap - totalSpent;
    return r < 0 ? 0 : r;
  }

  @override
  List<Object?> get props => [overviews, month];
}

final class BudgetsError extends BudgetsState {
  const BudgetsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
