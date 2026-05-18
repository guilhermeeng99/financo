import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_event_state.dart';
import 'package:financo/features/dashboard/presentation/cubit/fifty_thirty_twenty_targets_cubit.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required GetDashboardSummaryUseCase getDashboardSummary,
    required GetTransactionsUseCase getTransactions,
    required FiftyThirtyTwentyTargetsCubit targetsCubit,
    required String userId,
  }) : _getDashboardSummary = getDashboardSummary,
       _getTransactions = getTransactions,
       _targetsCubit = targetsCubit,
       _userId = userId,
       super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
  }

  final GetDashboardSummaryUseCase _getDashboardSummary;
  final GetTransactionsUseCase _getTransactions;
  final FiftyThirtyTwentyTargetsCubit _targetsCubit;
  final String _userId;

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (event.forceRefresh || state is! DashboardLoaded) {
      emit(const DashboardLoading());
    }
    await _loadDashboard(
      emit,
      year: event.year,
      month: event.month,
      forceRefresh: event.forceRefresh,
    );
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    final current = state;
    final year = current is DashboardLoaded
        ? current.selectedYear
        : DateTime.now().year;
    final month = current is DashboardLoaded
        ? current.selectedMonth
        : DateTime.now().month;
    await _loadDashboard(emit, year: year, month: month, forceRefresh: true);
  }

  Future<void> _loadDashboard(
    Emitter<DashboardState> emit, {
    required int year,
    required int month,
    bool forceRefresh = false,
  }) async {
    final target = DateTime(year, month);

    // Summary and period transactions are independent reads — fetching them
    // in parallel roughly halves the first-load latency on cold cache.
    final summaryFuture = _getDashboardSummary(
      userId: _userId,
      month: target,
      forceRefresh: forceRefresh,
      fiftyThirtyTwentyTargets: _targetsCubit.state.targets,
    );
    final transactionsFuture = _getTransactions(
      userId: _userId,
      startDate: startOfMonth(target),
      endDate: endOfMonth(target),
      forceRefresh: forceRefresh,
    );
    final summaryResult = await summaryFuture;
    final transactionsResult = await transactionsFuture;

    summaryResult.fold(
      (failure) => emit(DashboardError(failure)),
      (summary) => transactionsResult.fold(
        (failure) => emit(DashboardError(failure)),
        (transactions) {
          emit(
            DashboardLoaded(
              summary: summary,
              periodTransactions: transactions,
              selectedYear: year,
              selectedMonth: month,
            ),
          );
        },
      ),
    );
  }
}
