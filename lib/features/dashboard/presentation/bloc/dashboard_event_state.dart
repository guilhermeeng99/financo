import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

final class DashboardLoadRequested extends DashboardEvent {
  DashboardLoadRequested({
    this.forceRefresh = false,
    int? year,
    int? month,
  }) : year = year ?? DateTime.now().year,
       month = month ?? DateTime.now().month;

  final bool forceRefresh;
  final int year;
  final int month;

  @override
  List<Object> get props => [forceRefresh, year, month];
}

final class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardLoaded extends DashboardState {
  const DashboardLoaded({
    required this.summary,
    required this.periodTransactions,
    required this.selectedYear,
    required this.selectedMonth,
  });

  final DashboardSummary summary;
  final List<TransactionEntity> periodTransactions;
  final int selectedYear;
  final int selectedMonth;

  @override
  List<Object> get props => [
    summary,
    periodTransactions,
    selectedYear,
    selectedMonth,
  ];
}

final class DashboardError extends DashboardState {
  const DashboardError(this.failure);

  final Failure failure;

  @override
  List<Object> get props => [failure];
}
