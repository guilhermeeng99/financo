import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/account_balance_calculator.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/import_accounts_csv_usecase.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountsCubit extends Cubit<AccountsState> {
  AccountsCubit({
    required GetAccountsUseCase getAccounts,
    required GetTransactionsUseCase getTransactions,
    required ImportAccountsCsvUseCase importAccountsCsv,
    required String userId,
  }) : _getAccounts = getAccounts,
       _getTransactions = getTransactions,
       _importAccountsCsv = importAccountsCsv,
       _userId = userId,
       super(const AccountsInitial());

  final GetAccountsUseCase _getAccounts;
  final GetTransactionsUseCase _getTransactions;
  final ImportAccountsCsvUseCase _importAccountsCsv;
  final String _userId;

  Future<void> loadAccounts({bool forceRefresh = false}) async {
    if (forceRefresh || state is! AccountsLoaded) {
      emit(const AccountsLoading());
    }
    final result = await _loadEnriched(forceRefresh: forceRefresh);
    result.fold(
      (failure) => emit(AccountsError(failure)),
      (accounts) => emit(AccountsLoaded(accounts)),
    );
  }

  /// Fetches accounts + all-time transactions in parallel and returns
  /// accounts with `currentBalance` populated. The credit-usage bar
  /// reads from this so it reflects actual spending instead of staying
  /// frozen on the seed `initialBalance`. If transactions fail we still
  /// surface the accounts — stale credit usage beats an empty list.
  Future<Either<Failure, List<AccountEntity>>> _loadEnriched({
    bool forceRefresh = false,
  }) async {
    final results = await Future.wait([
      _getAccounts(userId: _userId, forceRefresh: forceRefresh),
      _getTransactions(userId: _userId, forceRefresh: forceRefresh),
    ]);
    final accountsResult =
        results[0] as Either<Failure, List<AccountEntity>>;
    final transactionsResult =
        results[1] as Either<Failure, List<TransactionEntity>>;
    return accountsResult.map((accounts) {
      final transactions = transactionsResult.fold(
        (_) => const <TransactionEntity>[],
        (txs) => txs,
      );
      return applyTransactionsToAccounts(accounts, transactions);
    });
  }

  Future<Either<Failure, AccountImportPreview>> previewCsv(
    String csvContent,
  ) {
    return _importAccountsCsv.preview(
      csvContent: csvContent,
      userId: _userId,
    );
  }

  /// Confirms the import for the (possibly user-edited) preview items.
  /// Used by the import-accounts page after the user reviews/edits the
  /// parsed CSV preview.
  ///
  /// Emits [AccountsImporting] for each item processed so the UI can show
  /// a determinate progress bar; on completion transitions to
  /// [AccountsImported] (or [AccountsError] on failure).
  Future<void> confirmImport({
    required List<AccountImportPreviewItem> items,
    int duplicateCount = 0,
  }) async {
    emit(AccountsImporting(processed: 0, total: items.length));

    final result = await _importAccountsCsv.importItems(
      items: items,
      userId: _userId,
      duplicateCount: duplicateCount,
      onProgress: (processed, total) {
        if (isClosed) return;
        emit(AccountsImporting(processed: processed, total: total));
      },
    );

    await result.fold(
      (failure) async => emit(AccountsError(failure)),
      (importResult) async {
        final refreshResult = await _loadEnriched(forceRefresh: true);
        refreshResult.fold(
          (failure) => emit(AccountsError(failure)),
          (accounts) => emit(
            AccountsImported(
              accounts: accounts,
              importedCount: importResult.importedCount,
              duplicateCount: importResult.duplicateCount,
            ),
          ),
        );
      },
    );
  }
}

sealed class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object?> get props => [];
}

final class AccountsInitial extends AccountsState {
  const AccountsInitial();
}

final class AccountsLoading extends AccountsState {
  const AccountsLoading();
}

/// Active state during a confirmed CSV import. Carries the number of items
/// already processed and the total so the UI can render a determinate
/// progress bar instead of a plain spinner.
final class AccountsImporting extends AccountsState {
  const AccountsImporting({required this.processed, required this.total});

  final int processed;
  final int total;

  double get progress => total == 0 ? 1 : processed / total;

  @override
  List<Object> get props => [processed, total];
}

final class AccountsLoaded extends AccountsState {
  const AccountsLoaded(this.accounts);

  final List<AccountEntity> accounts;

  @override
  List<Object> get props => [accounts];
}

final class AccountsError extends AccountsState {
  const AccountsError(this.failure);

  final Failure failure;

  @override
  List<Object> get props => [failure];
}

final class AccountsImported extends AccountsState {
  const AccountsImported({
    required this.accounts,
    required this.importedCount,
    required this.duplicateCount,
  });

  final List<AccountEntity> accounts;
  final int importedCount;
  final int duplicateCount;

  @override
  List<Object> get props => [accounts, importedCount, duplicateCount];
}

extension AccountsStateData on AccountsState {
  /// Returns the accounts carried by states that have a list (Loaded and
  /// Imported), or an empty list otherwise. Use this everywhere the
  /// caller "just wants the accounts" — `is AccountsLoaded` alone drops
  /// the post-import list and silently breaks lookups.
  List<AccountEntity> get accountsOrEmpty => switch (this) {
        AccountsLoaded(:final accounts) => accounts,
        AccountsImported(:final accounts) => accounts,
        _ => const <AccountEntity>[],
      };
}
