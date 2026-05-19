import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/account_balance_calculator.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';
import 'package:financo/features/investments/domain/repositories/asset_class_repository.dart';
import 'package:financo/features/investments/domain/repositories/asset_holding_repository.dart';
import 'package:financo/features/investments/domain/services/compute_investment_overview.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

/// Creates a holding after enforcing the V1 invariants from
/// `specs/investments.md` §2:
///
/// 1. `accountId` must point at an `AccountType.investment` account.
/// 2. `amount >= 0`.
/// 3. `Σ(holdings on this account) + this.amount <= account.balance`.
/// 4. `assetClassId` must point at a **subclass** (`parentId != null`).
///    Root classes are organisational containers only — money lives
///    on the leaves.
///
/// We re-check at the use-case layer (not only in the form) so that
/// AI chat actions or future CSV imports cannot bypass the rule.
class CreateAssetHoldingUseCase {
  const CreateAssetHoldingUseCase({
    required AssetHoldingRepository holdingRepository,
    required AccountRepository accountRepository,
    required AssetClassRepository assetClassRepository,
    required TransactionRepository transactionRepository,
  }) : _holdings = holdingRepository,
       _accounts = accountRepository,
       _classes = assetClassRepository,
       _transactions = transactionRepository;

  final AssetHoldingRepository _holdings;
  final AccountRepository _accounts;
  final AssetClassRepository _classes;
  final TransactionRepository _transactions;

  Future<Either<Failure, AssetHoldingEntity>> call(
    AssetHoldingEntity holding,
  ) async {
    if (holding.amount < 0) {
      return const Left(ValidationFailure('Amount must be at least zero.'));
    }

    final classGuard = await _verifyClass(
      userId: holding.userId,
      classId: holding.assetClassId,
    );
    if (classGuard != null) return Left(classGuard);

    final accountResult = await _accounts.getAccount(holding.accountId);
    final accountFailure = accountResult.fold<Failure?>(
      (failure) => failure,
      (account) {
        if (account.type != AccountType.investment) {
          return const ValidationFailure(
            'Holdings can only be attached to investment accounts.',
          );
        }
        return null;
      },
    );
    if (accountFailure != null) return Left(accountFailure);
    final rawAccount =
        accountResult.fold<AccountEntity?>((_) => null, (a) => a)!;

    // `getAccount` returns the seed balance (`currentBalance == null`).
    // The form's helper compares against `effectiveBalance` which would
    // collapse to the seed and reject any allocation above it. Apply
    // the transaction history here so the use case agrees with the
    // page-level snapshot built by `GetInvestmentOverviewUseCase`.
    final txResult = await _transactions.getTransactions(
      userId: holding.userId,
      accountId: holding.accountId,
    );
    final account = txResult.fold(
      (_) => rawAccount,
      (txns) => applyTransactionsToAccounts([rawAccount], txns).single,
    );

    final existingResult = await _holdings.getAssetHoldings(
      userId: holding.userId,
    );
    final overflowFailure = existingResult.fold<Failure?>(
      (failure) => failure,
      (holdings) {
        final available = computeAvailableForAccount(
          account: account,
          holdings: holdings,
        );
        if (holding.amount > available + 0.005) {
          return ValidationFailure(
            'Allocation exceeds the available balance on this account '
            '(${available.toStringAsFixed(2)}).',
          );
        }
        return null;
      },
    );
    if (overflowFailure != null) return Left(overflowFailure);

    return _holdings.createAssetHolding(holding);
  }

  Future<Failure?> _verifyClass({
    required String userId,
    required String classId,
  }) async {
    final result = await _classes.getAssetClasses(userId: userId);
    return result.fold((failure) => failure, (classes) {
      AssetClassEntity? klass;
      for (final c in classes) {
        if (c.id == classId) {
          klass = c;
          break;
        }
      }
      if (klass == null) {
        return const ValidationFailure('Asset class not found.');
      }
      if (klass.parentId == null) {
        return const ValidationFailure(
          'Holdings must point at a subclass. Add a subclass to the '
          'chosen class first.',
        );
      }
      return null;
    });
  }
}
