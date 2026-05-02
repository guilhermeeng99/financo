import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/usecases/delete_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/find_bill_match_candidates_usecase.dart';
import 'package:financo/features/bills/domain/usecases/get_bills_usecase.dart';
import 'package:financo/features/bills/domain/usecases/link_bill_to_transaction_usecase.dart';
import 'package:financo/features/bills/domain/usecases/pay_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/project_virtual_monthly_bills_usecase.dart';
import 'package:financo/features/bills/domain/usecases/reject_bill_match_usecase.dart';
import 'package:financo/features/bills/presentation/bloc/bills_event_state.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BillsBloc extends Bloc<BillsEvent, BillsState> {
  BillsBloc({
    required GetBillsUseCase getBills,
    required DeleteBillUseCase deleteBill,
    required PayBillUseCase payBill,
    required GetTransactionsUseCase getTransactions,
    required LinkBillToTransactionUseCase linkBillToTransaction,
    required RejectBillMatchUseCase rejectBillMatch,
    required String userId,
    FindBillMatchCandidatesUseCase findMatches =
        const FindBillMatchCandidatesUseCase(),
    ProjectVirtualMonthlyBillsUseCase projectVirtuals =
        const ProjectVirtualMonthlyBillsUseCase(),
  }) : _getBills = getBills,
       _deleteBill = deleteBill,
       _payBill = payBill,
       _getTransactions = getTransactions,
       _linkBillToTransaction = linkBillToTransaction,
       _rejectBillMatch = rejectBillMatch,
       _findMatches = findMatches,
       _projectVirtuals = projectVirtuals,
       _userId = userId,
       super(const BillsInitial()) {
    on<BillsLoadRequested>(_onLoadRequested);
    on<BillDeleteRequested>(_onDeleteRequested);
    on<BillPaymentRequested>(_onPaymentRequested);
    on<BillMatchAccepted>(_onMatchAccepted);
    on<BillMatchRejected>(_onMatchRejected);
  }

  final GetBillsUseCase _getBills;
  final DeleteBillUseCase _deleteBill;
  final PayBillUseCase _payBill;
  final GetTransactionsUseCase _getTransactions;
  final LinkBillToTransactionUseCase _linkBillToTransaction;
  final RejectBillMatchUseCase _rejectBillMatch;
  final FindBillMatchCandidatesUseCase _findMatches;
  final ProjectVirtualMonthlyBillsUseCase _projectVirtuals;
  final String _userId;

  /// Most recent month the bloc projected for. Persisted across loads
  /// so events triggered without an explicit (year, month) — like the
  /// re-load after pay/delete — keep the projection current.
  int? _lastTargetYear;
  int? _lastTargetMonth;

  Future<void> _onLoadRequested(
    BillsLoadRequested event,
    Emitter<BillsState> emit,
  ) async {
    final targetYear = event.year ?? _lastTargetYear ?? DateTime.now().year;
    final targetMonth =
        event.month ?? _lastTargetMonth ?? DateTime.now().month;

    if (state is BillsLoaded && !event.forceRefresh) {
      final loaded = state as BillsLoaded;
      // Short-circuit only when the requested status filter and the
      // navigated month both match what's already in state. Otherwise
      // we have to re-project virtuals (and possibly re-fetch bills).
      final sameMonth = loaded.targetYear == targetYear &&
          loaded.targetMonth == targetMonth;
      if (loaded.statusFilter == event.status && sameMonth) return;
    }
    emit(const BillsLoading());
    _lastTargetYear = targetYear;
    _lastTargetMonth = targetMonth;

    final billsResult = await _getBills(
      userId: _userId,
      status: event.status,
      forceRefresh: event.forceRefresh,
    );

    await billsResult.fold(
      (failure) async => emit(BillsError(failure)),
      (bills) async {
        // Load transactions in parallel-ish so the candidate scan has full
        // data on first paint. Cache-only (no date filter) — the scan
        // needs anything that could match a bill regardless of month.
        final txs = await _loadTransactions();
        final candidates = _findMatches(bills: bills, transactions: txs);
        // Virtual previews are derived purely from the loaded set — they
        // don't hit IO, never persist. The bloc owns this projection so
        // every consumer (banner, list, summary) sees the same set.
        final virtuals = _projectVirtuals(
          bills: bills,
          targetYear: targetYear,
          targetMonth: targetMonth,
        );
        emit(
          BillsLoaded(
            bills,
            transactions: txs,
            matchCandidates: candidates,
            virtualBills: virtuals,
            statusFilter: event.status,
            targetYear: targetYear,
            targetMonth: targetMonth,
          ),
        );
      },
    );
  }

  Future<List<TransactionEntity>> _loadTransactions() async {
    final result = await _getTransactions(userId: _userId);
    return result.fold((_) => const <TransactionEntity>[], (txs) => txs);
  }

  Future<void> _onDeleteRequested(
    BillDeleteRequested event,
    Emitter<BillsState> emit,
  ) async {
    final current = state;
    final result = await _deleteBill(event.id);
    result.fold(
      (failure) => emit(BillsError(failure)),
      (_) {
        final filter = current is BillsLoaded ? current.statusFilter : null;
        add(
          BillsLoadRequested(
            forceRefresh: true,
            status: filter,
            year: _lastTargetYear,
            month: _lastTargetMonth,
          ),
        );
      },
    );
  }

  Future<void> _onPaymentRequested(
    BillPaymentRequested event,
    Emitter<BillsState> emit,
  ) async {
    final current = state;
    final result = await _payBill(
      billId: event.billId,
      accountId: event.accountId,
      categoryId: event.categoryId,
    );
    _emitPaymentOutcome(result, current, emit);
  }

  Future<void> _onMatchAccepted(
    BillMatchAccepted event,
    Emitter<BillsState> emit,
  ) async {
    final current = state;
    final result = await _linkBillToTransaction(
      billId: event.billId,
      transactionId: event.transactionId,
    );
    _emitPaymentOutcome(result, current, emit);
  }

  Future<void> _onMatchRejected(
    BillMatchRejected event,
    Emitter<BillsState> emit,
  ) async {
    final current = state;
    final result = await _rejectBillMatch(
      billId: event.billId,
      transactionId: event.transactionId,
    );
    result.fold(
      (failure) => emit(BillsError(failure)),
      (_) {
        // Re-load so the rejected pair drops out of `matchCandidates`.
        final filter = current is BillsLoaded ? current.statusFilter : null;
        add(
          BillsLoadRequested(
            forceRefresh: true,
            status: filter,
            year: _lastTargetYear,
            month: _lastTargetMonth,
          ),
        );
      },
    );
  }

  /// Shared tail for both `BillPaymentRequested` (creates a fresh tx) and
  /// `BillMatchAccepted` (settles against an existing tx). Both paths
  /// emit the same transient `BillPaid` state so the page can refresh
  /// dependent blocs (transactions, dashboard) and show a snackbar.
  void _emitPaymentOutcome(
    Either<Failure, BillPaymentResult> result,
    BillsState previous,
    Emitter<BillsState> emit,
  ) {
    result.fold(
      (failure) => emit(BillsError(failure)),
      (paymentResult) {
        emit(BillPaid(paymentResult));
        final filter = previous is BillsLoaded ? previous.statusFilter : null;
        add(
          BillsLoadRequested(
            forceRefresh: true,
            status: filter,
            year: _lastTargetYear,
            month: _lastTargetMonth,
          ),
        );
      },
    );
  }
}
