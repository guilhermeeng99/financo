import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';

sealed class BillsEvent extends Equatable {
  const BillsEvent();

  @override
  List<Object?> get props => [];
}

final class BillsLoadRequested extends BillsEvent {
  const BillsLoadRequested({this.forceRefresh = false, this.status});

  final bool forceRefresh;
  final BillStatus? status;

  @override
  List<Object?> get props => [forceRefresh, status];
}

final class BillDeleteRequested extends BillsEvent {
  const BillDeleteRequested(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

final class BillPaymentRequested extends BillsEvent {
  const BillPaymentRequested({
    required this.billId,
    required this.accountId,
    required this.categoryId,
  });

  final String billId;
  final String accountId;
  final String categoryId;

  @override
  List<Object> get props => [billId, accountId, categoryId];
}

sealed class BillsState extends Equatable {
  const BillsState();

  @override
  List<Object?> get props => [];
}

final class BillsInitial extends BillsState {
  const BillsInitial();
}

final class BillsLoading extends BillsState {
  const BillsLoading();
}

final class BillsLoaded extends BillsState {
  const BillsLoaded(this.bills, {this.statusFilter});

  final List<BillEntity> bills;
  final BillStatus? statusFilter;

  @override
  List<Object?> get props => [bills, statusFilter];
}

final class BillsError extends BillsState {
  const BillsError(this.failure);

  final Failure failure;

  @override
  List<Object> get props => [failure];
}

/// Transient state emitted right after a successful payment, then immediately
/// followed by a re-load. UI listens to it to refresh dependent blocs
/// (transactions, dashboard) and show a snackbar.
final class BillPaid extends BillsState {
  const BillPaid(this.result);

  final BillPaymentResult result;

  @override
  List<Object> get props => [result];
}
