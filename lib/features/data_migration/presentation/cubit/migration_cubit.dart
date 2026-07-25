import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/data_migration/domain/account_migration_executor.dart';
import 'package:financo/features/data_migration/domain/account_migration_planner.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/repositories/asset_repository.dart';
import 'package:financo/features/investing/domain/repositories/institution_repository.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Drives the guided account/investing migration screen (F8.5 + F9.6): loads
/// the data, builds a reviewable [AccountMigrationPlan] from the user's mapping
/// choices, and applies it on explicit confirmation. Nothing is written until
/// [apply]. See `docs/specs/investing_account_unification.md` §6.
class MigrationCubit extends Cubit<MigrationState> {
  MigrationCubit({
    required AccountRepository accountRepository,
    required InstitutionRepository institutionRepository,
    required TransactionRepository transactionRepository,
    required AssetRepository assetRepository,
    required AccountMigrationExecutor executor,
    required String userId,
    AccountMigrationPlanner planner = const AccountMigrationPlanner(),
  }) : _accounts = accountRepository,
       _institutions = institutionRepository,
       _transactions = transactionRepository,
       _assets = assetRepository,
       _executor = executor,
       _planner = planner,
       _userId = userId,
       super(const MigrationLoading());

  final AccountRepository _accounts;
  final InstitutionRepository _institutions;
  final TransactionRepository _transactions;
  final AssetRepository _assets;
  final AccountMigrationExecutor _executor;
  final AccountMigrationPlanner _planner;
  final String _userId;

  List<AccountEntity> _investmentAccounts = const [];
  List<Institution> _institutionList = const [];
  List<TransactionEntity> _transactionList = const [];
  Map<String, int> _assetCounts = const {};
  // account id → chosen institution id (null = not yet chosen).
  final Map<String, String?> _mapping = {};
  // institution ids the user opted to convert to a foreign cash account.
  final Set<String> _toConvert = {};

  Future<void> load() async {
    emit(const MigrationLoading());
    final accountsResult = await _accounts.getAccounts(userId: _userId);
    final institutionsResult = await _institutions.getInstitutions(
      userId: _userId,
    );
    final transactionsResult = await _transactions.getTransactions(
      userId: _userId,
    );
    final assetsResult = await _assets.getAssets(userId: _userId);

    final failure =
        accountsResult.fold<Failure?>((f) => f, (_) => null) ??
        institutionsResult.fold<Failure?>((f) => f, (_) => null) ??
        transactionsResult.fold<Failure?>((f) => f, (_) => null) ??
        assetsResult.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) {
      emit(MigrationError(failure));
      return;
    }

    final accounts = accountsResult.getOrElse(() => const []);
    _investmentAccounts = accounts
        .where((a) => a.type == AccountType.investment)
        .toList();
    _institutionList = institutionsResult.getOrElse(() => const []);
    _transactionList = transactionsResult.getOrElse(() => const []);
    final assets = assetsResult.getOrElse(() => const []);
    _assetCounts = <String, int>{};
    for (final asset in assets) {
      final id = asset.institutionId;
      if (id == null) continue;
      _assetCounts[id] = (_assetCounts[id] ?? 0) + 1;
    }

    // Pre-fill each investment account with an exact-name institution match.
    for (final account in _investmentAccounts) {
      _mapping[account.id] ??= _exactNameMatch(account.name)?.id;
    }
    _emitReady();
  }

  /// Sets (or clears) the institution an investment account folds into.
  void chooseInstitution(String accountId, String? institutionId) {
    _mapping[accountId] = institutionId;
    _emitReady();
  }

  /// Toggles whether a (holding-free) institution converts to a EUR account.
  void toggleConvert(String institutionId, {required bool convert}) {
    if (convert) {
      _toConvert.add(institutionId);
    } else {
      _toConvert.remove(institutionId);
    }
    _emitReady();
  }

  Future<void> apply() async {
    final ready = state;
    if (ready is! MigrationReady) return;
    emit(const MigrationApplying());
    final result = await _executor.apply(ready.plan);
    result.fold(
      (failure) => emit(MigrationError(failure)),
      (summary) => emit(MigrationDone(summary)),
    );
  }

  void _emitReady() {
    final plan = _planner.plan(
      accounts: _investmentAccounts,
      institutions: _institutionList,
      transactions: _transactionList,
      accountToInstitutionId: {
        for (final entry in _mapping.entries)
          if (entry.value != null) entry.key: entry.value!,
      },
      institutionIdsToConvert: _toConvert,
      institutionAssetCounts: _assetCounts,
    );
    emit(
      MigrationReady(
        plan: plan,
        investmentAccounts: _investmentAccounts,
        institutions: _institutionList,
        mapping: Map.unmodifiable(_mapping),
        toConvert: Set.unmodifiable(_toConvert),
        assetCounts: Map.unmodifiable(_assetCounts),
      ),
    );
  }

  Institution? _exactNameMatch(String accountName) {
    final target = accountName.trim().toLowerCase();
    for (final institution in _institutionList) {
      if (institution.name.trim().toLowerCase() == target) return institution;
    }
    return null;
  }
}

sealed class MigrationState extends Equatable {
  const MigrationState();
  @override
  List<Object?> get props => [];
}

class MigrationLoading extends MigrationState {
  const MigrationLoading();
}

class MigrationReady extends MigrationState {
  const MigrationReady({
    required this.plan,
    required this.investmentAccounts,
    required this.institutions,
    required this.mapping,
    required this.toConvert,
    required this.assetCounts,
  });

  final AccountMigrationPlan plan;
  final List<AccountEntity> investmentAccounts;
  final List<Institution> institutions;
  final Map<String, String?> mapping;
  final Set<String> toConvert;
  final Map<String, int> assetCounts;

  @override
  List<Object?> get props => [
    plan,
    investmentAccounts,
    institutions,
    mapping,
    toConvert,
    assetCounts,
  ];
}

class MigrationApplying extends MigrationState {
  const MigrationApplying();
}

class MigrationDone extends MigrationState {
  const MigrationDone(this.result);
  final MigrationResult result;
  @override
  List<Object?> get props => [result];
}

class MigrationError extends MigrationState {
  const MigrationError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
