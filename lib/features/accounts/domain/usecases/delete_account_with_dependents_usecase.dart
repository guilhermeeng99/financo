import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/investments/domain/repositories/asset_holding_repository.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

/// Deletes an account together with everything that hangs off it.
///
/// Order: every transaction on the account first (transfers cascade to their
/// linked leg via the transaction repository), then the account itself, then
/// — best-effort — the investment holdings tied to the account.
///
/// WHY a use case: this cascade used to live inline in the account page,
/// resolving repositories through the service locator and swallowing each
/// step's failure (it called `context.pop(true)` even when the account delete
/// failed). Here every transaction/account failure short-circuits to [Left]
/// so the caller never reports success on a partial delete. Holdings are
/// best-effort because the account is already gone and the investments
/// overview filters out orphan holdings.
///
/// Example:
/// ```dart
/// final result = await deleteAccountWithDependents(
///   userId: userId,
///   accountId: account.id,
/// );
/// result.fold(showError, (_) => Navigator.pop(context, true));
/// ```
class DeleteAccountWithDependentsUseCase {
  const DeleteAccountWithDependentsUseCase({
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
    required AssetHoldingRepository assetHoldingRepository,
  }) : _transactions = transactionRepository,
       _accounts = accountRepository,
       _holdings = assetHoldingRepository;

  final TransactionRepository _transactions;
  final AccountRepository _accounts;
  final AssetHoldingRepository _holdings;

  Future<Either<Failure, void>> call({
    required String userId,
    required String accountId,
  }) async {
    final txResult = await _transactions.getTransactions(
      userId: userId,
      accountId: accountId,
    );
    if (txResult.isLeft()) {
      return txResult.fold(
        Left<Failure, void>.new,
        (_) => const Right<Failure, void>(null),
      );
    }

    final transactions = txResult.getOrElse(() => const <TransactionEntity>[]);
    for (final tx in transactions) {
      final deleted = await _transactions.deleteTransaction(tx.id);
      if (deleted.isLeft()) return deleted;
    }

    final accountDeleted = await _accounts.deleteAccount(accountId);
    if (accountDeleted.isLeft()) return accountDeleted;

    // Best-effort: orphan holdings are filtered out of the overview, so a
    // failure here must not surface as a delete failure.
    await _holdings.deleteHoldingsForAccount(accountId);
    return const Right(null);
  }
}
