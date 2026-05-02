import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/entities/bill_match_candidate.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

sealed class BillsEvent extends Equatable {
  const BillsEvent();

  @override
  List<Object?> get props => [];
}

final class BillsLoadRequested extends BillsEvent {
  const BillsLoadRequested({
    this.forceRefresh = false,
    this.status,
    this.year,
    this.month,
  });

  final bool forceRefresh;
  final BillStatus? status;

  /// Navigated month — used to project virtual occurrences forward.
  /// When null, the bloc keeps the previous target (or the current
  /// real-calendar month for the very first load).
  final int? year;
  final int? month;

  @override
  List<Object?> get props => [forceRefresh, status, year, month];
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

/// User confirmed "yes, that recorded transaction was this bill" in the
/// match-suggestion sheet. Settles the bill against the existing tx
/// (no new transaction is created).
final class BillMatchAccepted extends BillsEvent {
  const BillMatchAccepted({
    required this.billId,
    required this.transactionId,
  });

  final String billId;
  final String transactionId;

  @override
  List<Object> get props => [billId, transactionId];
}

/// User said "no, that transaction is NOT this bill". Adds the tx id
/// to the bill's `rejectedTransactionIds` so the pair never re-surfaces.
final class BillMatchRejected extends BillsEvent {
  const BillMatchRejected({
    required this.billId,
    required this.transactionId,
  });

  final String billId;
  final String transactionId;

  @override
  List<Object> get props => [billId, transactionId];
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
  const BillsLoaded(
    this.bills, {
    this.transactions = const [],
    this.matchCandidates = const [],
    this.virtualBills = const [],
    this.statusFilter,
    this.targetYear,
    this.targetMonth,
  });

  final List<BillEntity> bills;

  /// Snapshot of transactions used to derive `matchCandidates`. Carried
  /// in state so the UI can show transaction details (description, date,
  /// account) inside the match-suggestion sheet without an extra fetch.
  final List<TransactionEntity> transactions;

  /// Pairs of `(bill, candidate transactions)` produced by
  /// `FindBillMatchCandidatesUseCase`. Empty when there's nothing to
  /// suggest. The BillsPage shows a banner only when this is non-empty.
  final List<BillMatchCandidate> matchCandidates;

  /// Virtual previews of upcoming monthly occurrences — each carries
  /// `id == ''` and is purely informational. See
  /// `specs/bills.md` → "Future Occurrence Preview".
  final List<BillEntity> virtualBills;

  final BillStatus? statusFilter;

  /// Year/month the projection was computed for. Stored so the page can
  /// detect "still up to date" vs "needs reload" when the date filter
  /// changes.
  final int? targetYear;
  final int? targetMonth;

  /// Number of pending bills that need action now — overdue or due today.
  /// Drives the red count badge on the Bills nav entry; kept in sync with
  /// the Cloud Function `notifyBillsDue` query (`pending && dueDate <= today`).
  int get actionablePendingCount =>
      bills.where((b) => b.isPending && (b.isOverdue || b.isDueToday)).length;

  @override
  List<Object?> get props => [
    bills,
    transactions,
    matchCandidates,
    virtualBills,
    statusFilter,
    targetYear,
    targetMonth,
  ];
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
