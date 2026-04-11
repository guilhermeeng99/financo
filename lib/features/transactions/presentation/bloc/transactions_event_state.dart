import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

sealed class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

final class TransactionsLoadRequested extends TransactionsEvent {
  const TransactionsLoadRequested({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object> get props => [forceRefresh];
}

final class TransactionDeleteRequested extends TransactionsEvent {
  const TransactionDeleteRequested(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

final class TransactionReconcileToggled extends TransactionsEvent {
  const TransactionReconcileToggled(this.id);

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
  const TransactionsLoaded(this.transactions);

  final List<TransactionEntity> transactions;

  @override
  List<Object> get props => [transactions];
}

final class TransactionsError extends TransactionsState {
  const TransactionsError(this.failure);

  final Failure failure;

  @override
  List<Object> get props => [failure];
}
