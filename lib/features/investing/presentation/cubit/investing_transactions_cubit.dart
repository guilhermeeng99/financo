import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/usecases/get_asset_transactions_usecase.dart';
import 'package:financo/features/investing/domain/usecases/get_assets_usecase.dart';
import 'package:financo/features/investing/domain/usecases/get_institutions_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Session-scoped investing-transactions list. Loads transactions plus assets
/// and institutions so the list can render ticker/institution labels. Created
/// by the shell route; the transactions page refreshes on mount and after a
/// buy/sell/dividend save. See `docs/specs/investing_transactions.md`.
class InvestingTransactionsCubit extends Cubit<InvestingTransactionsState> {
  InvestingTransactionsCubit({
    required GetAssetTransactionsUseCase getTransactions,
    required GetAssetsUseCase getAssets,
    required GetInstitutionsUseCase getInstitutions,
    required String userId,
  }) : _getTransactions = getTransactions,
       _getAssets = getAssets,
       _getInstitutions = getInstitutions,
       _userId = userId,
       super(const InvestingTransactionsLoading());

  final GetAssetTransactionsUseCase _getTransactions;
  final GetAssetsUseCase _getAssets;
  final GetInstitutionsUseCase _getInstitutions;
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
}

sealed class InvestingTransactionsState extends Equatable {
  const InvestingTransactionsState();

  @override
  List<Object?> get props => [];
}

final class InvestingTransactionsLoading extends InvestingTransactionsState {
  const InvestingTransactionsLoading();
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
