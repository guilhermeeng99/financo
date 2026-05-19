import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/account_balance_calculator.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';
import 'package:financo/features/investments/domain/entities/investment_overview.dart';
import 'package:financo/features/investments/domain/repositories/asset_class_repository.dart';
import 'package:financo/features/investments/domain/repositories/asset_holding_repository.dart';
import 'package:financo/features/investments/domain/services/compute_investment_overview.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

/// Aggregated payload returned by the use case — both the computed
/// overview and the raw lists, so the cubit can drive forms and
/// pickers without re-fetching.
class InvestmentSnapshot extends Equatable {
  const InvestmentSnapshot({
    required this.overview,
    required this.accounts,
    required this.classes,
    required this.holdings,
  });

  final InvestmentOverview overview;
  final List<AccountEntity> accounts;
  final List<AssetClassEntity> classes;
  final List<AssetHoldingEntity> holdings;

  @override
  List<Object?> get props => [overview, accounts, classes, holdings];
}

class GetInvestmentOverviewUseCase {
  const GetInvestmentOverviewUseCase({
    required AccountRepository accountRepository,
    required AssetClassRepository assetClassRepository,
    required AssetHoldingRepository assetHoldingRepository,
    required TransactionRepository transactionRepository,
  }) : _accounts = accountRepository,
       _classes = assetClassRepository,
       _holdings = assetHoldingRepository,
       _transactions = transactionRepository;

  final AccountRepository _accounts;
  final AssetClassRepository _classes;
  final AssetHoldingRepository _holdings;
  final TransactionRepository _transactions;

  Future<Either<Failure, InvestmentSnapshot>> call({
    required String userId,
    bool forceRefresh = false,
  }) async {
    // Fan-out the four reads in parallel — each is a separate Firestore
    // round-trip when `forceRefresh` is true, so doing them
    // concurrently cuts the page mount latency by ~4x compared to the
    // earlier sequential await chain.
    final results = await Future.wait([
      _accounts.getAccounts(userId: userId, forceRefresh: forceRefresh),
      _classes.getAssetClasses(userId: userId, forceRefresh: forceRefresh),
      _holdings.getAssetHoldings(userId: userId, forceRefresh: forceRefresh),
      _transactions.getTransactions(userId: userId),
    ]);

    final accountsResult =
        results[0] as Either<Failure, List<AccountEntity>>;
    if (accountsResult.isLeft()) {
      return Left(
        accountsResult.fold((f) => f, (_) => const ServerFailure()),
      );
    }
    final classesResult =
        results[1] as Either<Failure, List<AssetClassEntity>>;
    if (classesResult.isLeft()) {
      return Left(
        classesResult.fold((f) => f, (_) => const ServerFailure()),
      );
    }
    final holdingsResult =
        results[2] as Either<Failure, List<AssetHoldingEntity>>;
    if (holdingsResult.isLeft()) {
      return Left(
        holdingsResult.fold((f) => f, (_) => const ServerFailure()),
      );
    }

    final rawAccounts = accountsResult.getOrElse(() => const []);
    final classes = classesResult.getOrElse(() => const []);
    final holdings = holdingsResult.getOrElse(() => const []);

    // The account repository returns `currentBalance == null` because
    // running balances are computed at runtime, not persisted. Apply
    // the calculator so investment accounts report the same
    // `effectiveBalance` the dashboard / accounts list show. A
    // transaction-fetch failure degrades to the seed balance rather
    // than failing the whole snapshot.
    final transactionsResult = results[3] as Either<Failure, dynamic>;
    final accounts = transactionsResult.fold(
      (_) => rawAccounts,
      (transactions) => applyTransactionsToAccounts(
        rawAccounts,
        transactions as List<TransactionEntity>,
      ),
    );

    final overview = computeInvestmentOverview(
      accounts: accounts,
      classes: classes,
      holdings: holdings,
    );

    return Right(
      InvestmentSnapshot(
        overview: overview,
        accounts: accounts,
        classes: classes,
        holdings: holdings,
      ),
    );
  }
}
