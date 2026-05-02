import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/entities/budget_overview.dart';
import 'package:financo/features/budgets/domain/usecases/delete_budget_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/get_budgets_overview_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// List + delete cubit for the budgets tab. Owns the current-month
/// `BudgetOverview` list and the cascade between delete → re-load.
///
/// MVP shows the **current real month only** — no month navigation. When
/// month navigation lands later, expose a `selectMonth(DateTime)` action
/// and re-run the overview pipeline.
class BudgetsCubit extends Cubit<BudgetsState> {
  BudgetsCubit({
    required GetBudgetsOverviewUseCase getOverview,
    required DeleteBudgetUseCase deleteBudget,
    required String userId,
  }) : _getOverview = getOverview,
       _deleteBudget = deleteBudget,
       _userId = userId,
       super(const BudgetsInitial());

  final GetBudgetsOverviewUseCase _getOverview;
  final DeleteBudgetUseCase _deleteBudget;
  final String _userId;

  Future<void> loadBudgets({bool forceRefresh = false}) async {
    if (state is BudgetsLoaded && !forceRefresh) return;
    if (forceRefresh || state is! BudgetsLoaded) {
      emit(const BudgetsLoading());
    }
    final now = DateTime.now();
    final result = await _getOverview(
      userId: _userId,
      month: now,
      forceRefresh: forceRefresh,
    );
    result.fold(
      (failure) => emit(BudgetsError(failure)),
      (overviews) => emit(BudgetsLoaded(overviews: overviews, month: now)),
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
