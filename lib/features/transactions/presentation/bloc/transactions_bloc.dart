import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:financo/features/transactions/domain/usecases/delete_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc({
    required GetTransactionsUseCase getTransactions,
    required DeleteTransactionUseCase deleteTransaction,
    required TransactionRepository transactionRepository,
    required String userId,
  }) : _getTransactions = getTransactions,
       _deleteTransaction = deleteTransaction,
       _transactionRepo = transactionRepository,
       _userId = userId,
       super(const TransactionsInitial()) {
    on<TransactionsLoadRequested>(_onLoadRequested);
    on<TransactionDeleteRequested>(_onDeleteRequested);
    on<TransactionReconcileToggled>(_onReconcileToggled);
  }

  final GetTransactionsUseCase _getTransactions;
  final DeleteTransactionUseCase _deleteTransaction;
  final TransactionRepository _transactionRepo;
  final String _userId;

  Future<void> _onLoadRequested(
    TransactionsLoadRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    if (state is TransactionsLoaded && !event.forceRefresh) return;
    emit(const TransactionsLoading());

    final ref = DateTime(event.year, event.month);
    final result = await _getTransactions(
      userId: _userId,
      startDate: startOfMonth(ref),
      endDate: endOfMonth(ref),
      forceRefresh: event.forceRefresh,
    );

    result.fold(
      (failure) => emit(TransactionsError(failure)),
      (transactions) => emit(
        TransactionsLoaded(
          transactions,
          selectedYear: event.year,
          selectedMonth: event.month,
        ),
      ),
    );
  }

  Future<void> _onDeleteRequested(
    TransactionDeleteRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    final current = state;
    final result = await _deleteTransaction(event.id);
    result.fold(
      (failure) => emit(TransactionsError(failure)),
      (_) {
        if (current is TransactionsLoaded) {
          add(
            TransactionsLoadRequested(
              forceRefresh: true,
              year: current.selectedYear,
              month: current.selectedMonth,
            ),
          );
        } else {
          add(TransactionsLoadRequested(forceRefresh: true));
        }
      },
    );
  }

  Future<void> _onReconcileToggled(
    TransactionReconcileToggled event,
    Emitter<TransactionsState> emit,
  ) async {
    final current = state;
    final result = await _transactionRepo.toggleReconciled(event.id);
    result.fold(
      (failure) => emit(TransactionsError(failure)),
      (_) {
        if (current is TransactionsLoaded) {
          add(
            TransactionsLoadRequested(
              forceRefresh: true,
              year: current.selectedYear,
              month: current.selectedMonth,
            ),
          );
        } else {
          add(TransactionsLoadRequested(forceRefresh: true));
        }
      },
    );
  }
}
