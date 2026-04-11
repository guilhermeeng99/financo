import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_event_state.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required GetDashboardSummaryUseCase getDashboardSummary,
    required GetTransactionsUseCase getTransactions,
    required String userId,
  }) : _getDashboardSummary = getDashboardSummary,
       _getTransactions = getTransactions,
       _userId = userId,
       super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
  }

  final GetDashboardSummaryUseCase _getDashboardSummary;
  final GetTransactionsUseCase _getTransactions;
  final String _userId;

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded && !event.forceRefresh) return;
    emit(const DashboardLoading());
    await _loadDashboard(emit, forceRefresh: event.forceRefresh);
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadDashboard(emit, forceRefresh: true);
  }

  Future<void> _loadDashboard(
    Emitter<DashboardState> emit, {
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();

    final summaryResult = await _getDashboardSummary(
      userId: _userId,
      month: now,
      forceRefresh: forceRefresh,
    );

    final transactionsResult = await _getTransactions(
      userId: _userId,
      startDate: startOfMonth(now),
      endDate: endOfMonth(now),
      forceRefresh: forceRefresh,
    );

    summaryResult.fold(
      (failure) => emit(DashboardError(failure)),
      (summary) => transactionsResult.fold(
        (failure) => emit(DashboardError(failure)),
        (transactions) {
          final recent = transactions.take(5).toList();
          emit(
            DashboardLoaded(
              summary: summary,
              recentTransactions: recent,
            ),
          );
        },
      ),
    );
  }
}
