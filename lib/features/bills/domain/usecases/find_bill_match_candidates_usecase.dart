import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/entities/bill_match_candidate.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

/// Pure (no IO) use case: scans an in-memory snapshot of bills and
/// transactions and returns the pairs that look like the user already
/// settled a bill via a manually recorded transaction. The BillsPage
/// shows these as suggestions and lets the user confirm or reject each.
///
/// See `specs/bills.md` → "Match Suggestions" for the full rule set.
class FindBillMatchCandidatesUseCase {
  const FindBillMatchCandidatesUseCase();

  /// Tolerance for double comparison — bill / transaction amounts come
  /// from currency input parsed in BRL, so anything below 1 cent is noise.
  static const double _amountTolerance = 0.01;

  List<BillMatchCandidate> call({
    required List<BillEntity> bills,
    required List<TransactionEntity> transactions,
  }) {
    if (bills.isEmpty || transactions.isEmpty) return const [];

    // Transactions already claimed by a paid bill never appear as
    // candidates for any other bill — otherwise we'd keep suggesting
    // a transaction that's already been linked.
    final claimedTxIds = <String>{
      for (final bill in bills)
        if (bill.paidTransactionId != null) bill.paidTransactionId!,
    };

    final out = <BillMatchCandidate>[];
    for (final bill in bills) {
      if (!_billIsScannable(bill)) continue;
      final matches = transactions
          .where((tx) => _matches(bill, tx, claimedTxIds))
          .toList();
      if (matches.isNotEmpty) {
        out.add(BillMatchCandidate(bill: bill, candidates: matches));
      }
    }
    return out;
  }

  bool _billIsScannable(BillEntity bill) {
    if (bill.status != BillStatus.pending) return false;
    if (bill.paidTransactionId != null) return false;
    if (bill.categoryId == null) return false;
    return true;
  }

  bool _matches(
    BillEntity bill,
    TransactionEntity tx,
    Set<String> claimedTxIds,
  ) {
    if (claimedTxIds.contains(tx.id)) return false;
    if (bill.rejectedTransactionIds.contains(tx.id)) return false;
    // Transfers are between user-owned accounts — they're never the
    // settlement of a payable/receivable bill.
    if (tx.linkedTransactionId != null) return false;
    if (!_typeMatches(bill.type, tx.type)) return false;
    if (tx.categoryId != bill.categoryId) return false;
    if ((tx.amount - bill.amount).abs() >= _amountTolerance) return false;
    if (!_isSameDay(tx.date, bill.dueDate)) return false;
    return true;
  }

  bool _typeMatches(BillType billType, TransactionType txType) {
    return switch (billType) {
      BillType.payable => txType == TransactionType.expense,
      BillType.receivable => txType == TransactionType.income,
    };
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
