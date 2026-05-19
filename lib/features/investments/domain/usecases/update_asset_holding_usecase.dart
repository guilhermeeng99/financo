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

class UpdateAssetHoldingUseCase {
  const UpdateAssetHoldingUseCase({
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

    // Holdings must point at a subclass — see specs/investments.md §2.
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

    // Apply transactions so `effectiveBalance` matches the live UI
    // snapshot — see CreateAssetHoldingUseCase for the rationale.
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
        // Excluding the current holding ID lets the user edit the same
        // row without tripping the "Σ exceeds balance" guard.
        final available = computeAvailableForAccount(
          account: account,
          holdings: holdings,
          excludeHoldingId: holding.id,
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

    return _holdings.updateAssetHolding(holding);
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
