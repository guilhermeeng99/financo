import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

/// Reconciles the checking-side cash row that mirrors an investing buy/sell
/// (F8.4 — `docs/specs/investing_account_unification.md` §4 rules 4–6).
///
/// A buy funded from a checking account is an **aporte**: an expense on that
/// account tagged with the broker's `institutionId`. A sell paid into one is a
/// **resgate**: the symmetric income. The tag is what makes the row invisible
/// to the month's income/expense summary and visible to the 50/30/20 savings
/// bucket, so it must be written by the same action that writes the investing
/// leg — never by hand.
///
/// This is a reconcile, not an insert: it derives the row the investing
/// transaction *should* have and makes reality match, so the single entry
/// point covers create, edit (amount/account/date/kind changed), un-funding
/// (account cleared → row deleted) and the investing row's own deletion.
///
/// ```dart
/// // Sell R$7.000 of a fixed-income position, paid into a checking account.
/// await syncInvestmentCashFlow(
///   tx.copyWith(fundingAccountId: 'acc-nubank-gui'),
/// ); // → income of R$7.000 on acc-nubank-gui, tagged with the institution
/// ```
class SyncInvestmentCashFlowUseCase {
  const SyncInvestmentCashFlowUseCase(this._transactions);

  final TransactionRepository _transactions;

  /// Reconciles the paired row for [transaction].
  ///
  /// Pass [investingDeleted] when the investing transaction itself is gone —
  /// any paired row is then removed. Returns the row now backing the investing
  /// transaction, or `null` when it should not have one (no funding account,
  /// or a dividend, which is not a cash movement between the two ledgers).
  Future<Either<Failure, TransactionEntity?>> call(
    AssetTransaction transaction, {
    bool investingDeleted = false,
  }) async {
    final wanted = investingDeleted ? null : _desiredRow(transaction);
    // A brand-new transaction with nothing to write cannot have an orphan row,
    // so skip the full-ledger read the lookup would otherwise cost. This is the
    // CSV importer's path — it never funds from an account.
    if (wanted == null && transaction.id.isEmpty) return const Right(null);

    final pairedResult = await _paired(
      userId: transaction.userId,
      investingTransactionId: transaction.id,
    );
    final lookupFailure = pairedResult.fold<Failure?>((f) => f, (_) => null);
    if (lookupFailure != null) return Left(lookupFailure);
    final paired = pairedResult.getOrElse(() => const []);

    if (wanted == null) return _removeAll(paired);
    if (paired.isEmpty) {
      final created = await _transactions.createTransaction(wanted);
      return created.map<TransactionEntity?>((tx) => tx);
    }

    // Reuse the first row and drop any duplicates a partial failure may have
    // left behind, so the invariant "one cash row per investing transaction"
    // self-heals instead of double-counting the aporte.
    final surplus = paired.skip(1).toList();
    if (surplus.isNotEmpty) {
      final removed = await _removeAll(surplus);
      final removeFailure = removed.fold<Failure?>((f) => f, (_) => null);
      if (removeFailure != null) return Left(removeFailure);
    }
    final updated = await _transactions.updateTransaction(
      _merge(paired.first, wanted),
    );
    return updated.map<TransactionEntity?>((tx) => tx);
  }

  /// The cash row [transaction] should be backed by, or `null` for none.
  TransactionEntity? _desiredRow(AssetTransaction transaction) {
    final accountId = transaction.fundingAccountId;
    if (accountId == null || accountId.isEmpty) return null;
    // Dividends stay out: they are yield credited at the broker, not a
    // transfer between the cash and investing ledgers, so tagging one would
    // wrongly shrink the month's savings bucket.
    if (transaction.kind == TransactionKind.dividend) return null;
    final isBuy = transaction.kind == TransactionKind.buy;
    final amount = (transaction.cashAmount ?? transaction.amount).major;
    return TransactionEntity(
      id: '',
      userId: transaction.userId,
      accountId: accountId,
      categoryId: '',
      type: isBuy ? TransactionType.expense : TransactionType.income,
      amount: amount,
      description: _label(transaction, isBuy: isBuy),
      date: transaction.date,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
      institutionId: transaction.institutionId,
      linkedInvestmentTransactionId: transaction.id,
    );
  }

  /// Carries [wanted]'s values onto the stored row so its id survives the edit.
  TransactionEntity _merge(TransactionEntity stored, TransactionEntity wanted) {
    return stored.copyWith(
      accountId: wanted.accountId,
      type: wanted.type,
      amount: wanted.amount,
      description: wanted.description,
      date: wanted.date,
      dueDate: wanted.date,
      institutionId: wanted.institutionId,
      linkedInvestmentTransactionId: wanted.linkedInvestmentTransactionId,
      updatedAt: wanted.updatedAt,
    );
  }

  String _label(AssetTransaction transaction, {required bool isBuy}) {
    final notes = transaction.notes?.trim();
    if (notes != null && notes.isNotEmpty) return notes;
    return isBuy ? 'Aporte' : 'Resgate';
  }

  Future<Either<Failure, List<TransactionEntity>>> _paired({
    required String userId,
    required String investingTransactionId,
  }) async {
    if (investingTransactionId.isEmpty) return const Right([]);
    final all = await _transactions.getTransactions(userId: userId);
    return all.map(
      (rows) => [
        for (final row in rows)
          if (row.linkedInvestmentTransactionId == investingTransactionId) row,
      ],
    );
  }

  Future<Either<Failure, TransactionEntity?>> _removeAll(
    List<TransactionEntity> rows,
  ) async {
    if (rows.isEmpty) return const Right(null);
    final deleted = await _transactions.deleteTransactions([
      for (final row in rows) row.id,
    ]);
    return deleted.map<TransactionEntity?>((_) => null);
  }
}
