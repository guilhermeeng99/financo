import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/transactions/domain/usecases/delete_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/ensure_fixed_recurrences_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc({
    required GetTransactionsUseCase getTransactions,
    required DeleteTransactionUseCase deleteTransaction,
    required ImportTransactionsCsvUseCase importTransactionsCsv,
    required String userId,
    EnsureFixedRecurrencesUseCase? ensureFixedRecurrences,
  }) : _getTransactions = getTransactions,
       _deleteTransaction = deleteTransaction,
       _importTransactionsCsv = importTransactionsCsv,
       _ensureFixedRecurrences = ensureFixedRecurrences,
       _userId = userId,
       super(const TransactionsInitial()) {
    on<TransactionsLoadRequested>(_onLoadRequested);
    on<TransactionDeleteRequested>(_onDeleteRequested);
    on<TransactionsImportCsvRequested>(_onImportCsvRequested);
    on<TransactionsImportRowsConfirmed>(_onImportRowsConfirmed);
  }

  final GetTransactionsUseCase _getTransactions;
  final DeleteTransactionUseCase _deleteTransaction;
  final ImportTransactionsCsvUseCase _importTransactionsCsv;
  final EnsureFixedRecurrencesUseCase? _ensureFixedRecurrences;
  final String _userId;

  Future<Either<Failure, TransactionImportPreview>> previewCsv(
    String csvContent,
  ) {
    return _importTransactionsCsv.preview(
      csvContent: csvContent,
      userId: _userId,
    );
  }

  Future<void> _onLoadRequested(
    TransactionsLoadRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    if (state is TransactionsLoaded && !event.forceRefresh) {
      final loaded = state as TransactionsLoaded;
      if (loaded.selectedYear == event.year &&
          loaded.selectedMonth == event.month) {
        return;
      }
    }
    emit(const TransactionsLoading());

    await _ensureFixedRecurrences?.call(userId: _userId);

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

  Future<void> _onImportCsvRequested(
    TransactionsImportCsvRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(const TransactionsLoading());

    final result = await _importTransactionsCsv(
      csvContent: event.csvContent,
      userId: _userId,
    );

    result.fold(
      (failure) => emit(TransactionsError(failure)),
      (importResult) => emit(
        TransactionsImported(
          importedCount: importResult.importedCount,
          skippedCount: importResult.skippedCount,
        ),
      ),
    );
  }

  Future<void> _onImportRowsConfirmed(
    TransactionsImportRowsConfirmed event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(TransactionsImporting(processed: 0, total: event.rows.length));

    final result = await _importTransactionsCsv.importRows(
      rows: event.rows,
      userId: _userId,
      skippedCount: event.skippedCount,
      onProgress: (processed, total) {
        if (emit.isDone) return;
        emit(TransactionsImporting(processed: processed, total: total));
      },
    );

    result.fold(
      (failure) => emit(TransactionsError(failure)),
      (importResult) => emit(
        TransactionsImported(
          importedCount: importResult.importedCount,
          skippedCount: importResult.skippedCount,
        ),
      ),
    );
  }
}
