import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit({
    required GetTransactionsUseCase getTransactions,
    required String userId,
  }) : _getTransactions = getTransactions,
       _userId = userId,
       super(const ReportsInitial());

  final GetTransactionsUseCase _getTransactions;
  final String _userId;

  Future<void> loadReports({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(const ReportsLoading());

    final now = DateTime.now();
    final start = startDate ?? startOfMonth(now);
    final end = endDate ?? endOfMonth(now);

    final result = await _getTransactions(
      userId: _userId,
      startDate: start,
      endDate: end,
      forceRefresh: true,
    );

    result.fold(
      (failure) => emit(ReportsError(failure)),
      (transactions) {
        final income = transactions
            .where((t) => t.type == TransactionType.income)
            .fold<double>(0, (s, t) => s + t.amount);
        final expenses = transactions
            .where((t) => t.type == TransactionType.expense)
            .fold<double>(0, (s, t) => s + t.amount);

        final summary = DashboardSummary(
          totalBalance: 0,
          totalIncome: income,
          totalExpenses: expenses,
          netResult: income - expenses,
          accounts: const [],
          expensesByCategory: const [],
          incomeByCategory: const [],
        );

        final byCategory = <String, double>{};
        for (final t in transactions) {
          if (t.type == TransactionType.expense) {
            byCategory[t.categoryId] =
                (byCategory[t.categoryId] ?? 0) + t.amount;
          }
        }

        emit(
          ReportsLoaded(
            summary: summary,
            transactions: transactions,
            expensesByCategory: byCategory,
            startDate: start,
            endDate: end,
          ),
        );
      },
    );
  }
}

sealed class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

final class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

final class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

final class ReportsLoaded extends ReportsState {
  const ReportsLoaded({
    required this.summary,
    required this.transactions,
    required this.expensesByCategory,
    required this.startDate,
    required this.endDate,
  });

  final DashboardSummary summary;
  final List<TransactionEntity> transactions;
  final Map<String, double> expensesByCategory;
  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object> get props => [
    summary,
    transactions,
    expensesByCategory,
    startDate,
    endDate,
  ];
}

final class ReportsError extends ReportsState {
  const ReportsError(this.failure);

  final Failure failure;

  @override
  List<Object> get props => [failure];
}
