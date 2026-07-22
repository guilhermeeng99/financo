import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/usecases/get_asset_transactions_usecase.dart';
import 'package:financo/features/investing/domain/usecases/get_assets_usecase.dart';
import 'package:financo/features/investing/domain/usecases/get_institutions_usecase.dart';
import 'package:financo/features/investing/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Session-scoped investing-transactions list. Loads transactions plus assets
/// and institutions so the list can render ticker/institution labels. Created
/// by the shell route; the transactions page refreshes on mount and after a
/// buy/sell/dividend save. Also drives CSV import (`previewCsv` /
/// `confirmImport`). See `docs/specs/investing_transactions.md` and
/// `docs/specs/investing_csv_import.md`.
class InvestingTransactionsCubit extends Cubit<InvestingTransactionsState> {
  InvestingTransactionsCubit({
    required GetAssetTransactionsUseCase getTransactions,
    required GetAssetsUseCase getAssets,
    required GetInstitutionsUseCase getInstitutions,
    required ImportInvestingTransactionsCsvUseCase importTransactionsCsv,
    required String userId,
  }) : _getTransactions = getTransactions,
       _getAssets = getAssets,
       _getInstitutions = getInstitutions,
       _importTransactionsCsv = importTransactionsCsv,
       _userId = userId,
       super(const InvestingTransactionsLoading());

  final GetAssetTransactionsUseCase _getTransactions;
  final GetAssetsUseCase _getAssets;
  final GetInstitutionsUseCase _getInstitutions;
  final ImportInvestingTransactionsCsvUseCase _importTransactionsCsv;
  final String _userId;

  Future<void> load({bool forceRefresh = false}) async {
    if (forceRefresh || state is! InvestingTransactionsLoaded) {
      emit(const InvestingTransactionsLoading());
    }

    final txResult = await _getTransactions(
      userId: _userId,
      forceRefresh: forceRefresh,
    );
    final txFailure = txResult.fold<Failure?>((f) => f, (_) => null);
    if (txFailure != null) {
      emit(InvestingTransactionsError(txFailure));
      return;
    }

    final assetsResult = await _getAssets(
      userId: _userId,
      forceRefresh: forceRefresh,
    );
    final assetsFailure = assetsResult.fold<Failure?>((f) => f, (_) => null);
    if (assetsFailure != null) {
      emit(InvestingTransactionsError(assetsFailure));
      return;
    }

    final instResult = await _getInstitutions(
      userId: _userId,
      forceRefresh: forceRefresh,
    );
    final instFailure = instResult.fold<Failure?>((f) => f, (_) => null);
    if (instFailure != null) {
      emit(InvestingTransactionsError(instFailure));
      return;
    }

    emit(
      InvestingTransactionsLoaded(
        transactions: txResult.getOrElse(() => const []),
        assets: assetsResult.getOrElse(() => const []),
        institutions: instResult.getOrElse(() => const []),
      ),
    );
  }

  Future<Either<Failure, InvestingTransactionImportPreview>> previewCsv(
    String csvContent,
  ) {
    return _importTransactionsCsv.preview(
      csvContent: csvContent,
      userId: _userId,
    );
  }

  /// Confirms the import for the importable [items]. Emits
  /// [InvestingTransactionsImporting] per item for the progress UI, then
  /// refreshes to [InvestingTransactionsLoaded], and **returns** the report so
  /// the preview page can pop with a summary. A failure emits an error state
  /// and returns a `Left`.
  Future<Either<Failure, InvestingTransactionImportResult>> confirmImport({
    required List<InvestingTransactionImportPreviewItem> items,
    int skippedCount = 0,
  }) async {
    final importable = items.where((i) => i.canImport).toList();
    emit(
      InvestingTransactionsImporting(processed: 0, total: importable.length),
    );

    final result = await _importTransactionsCsv.importItems(
      items: importable,
      userId: _userId,
      skippedCount: skippedCount,
      onProgress: (processed, total) {
        if (isClosed) return;
        emit(
          InvestingTransactionsImporting(processed: processed, total: total),
        );
      },
    );

    final failure = result.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) {
      emit(InvestingTransactionsError(failure));
      return Left(failure);
    }
    await load(forceRefresh: true);
    return result;
  }
}

sealed class InvestingTransactionsState extends Equatable {
  const InvestingTransactionsState();

  @override
  List<Object?> get props => [];
}

final class InvestingTransactionsLoading extends InvestingTransactionsState {
  const InvestingTransactionsLoading();
}

/// Active state during a confirmed CSV import — carries progress.
final class InvestingTransactionsImporting extends InvestingTransactionsState {
  const InvestingTransactionsImporting({
    required this.processed,
    required this.total,
  });

  final int processed;
  final int total;

  double get progress => total == 0 ? 1 : processed / total;

  @override
  List<Object?> get props => [processed, total];
}

final class InvestingTransactionsLoaded extends InvestingTransactionsState {
  const InvestingTransactionsLoaded({
    required this.transactions,
    required this.assets,
    required this.institutions,
  });

  final List<AssetTransaction> transactions;
  final List<Asset> assets;
  final List<Institution> institutions;

  @override
  List<Object?> get props => [transactions, assets, institutions];
}

final class InvestingTransactionsError extends InvestingTransactionsState {
  const InvestingTransactionsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
