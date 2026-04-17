import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

sealed class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

final class TransactionsLoadRequested extends TransactionsEvent {
  TransactionsLoadRequested({
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

final class TransactionDeleteRequested extends TransactionsEvent {
  const TransactionDeleteRequested(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

sealed class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

final class TransactionsInitial extends TransactionsState {
  const TransactionsInitial();
}

final class TransactionsLoading extends TransactionsState {
  const TransactionsLoading();
}

final class TransactionsLoaded extends TransactionsState {
  const TransactionsLoaded(
    this.transactions, {
    required this.selectedYear,
    required this.selectedMonth,
  });

  final List<TransactionEntity> transactions;
  final int selectedYear;
  final int selectedMonth;

  @override
  List<Object> get props => [transactions, selectedYear, selectedMonth];
}

final class TransactionsError extends TransactionsState {
  const TransactionsError(this.failure);

  final Failure failure;

  @override
  List<Object> get props => [failure];
}
