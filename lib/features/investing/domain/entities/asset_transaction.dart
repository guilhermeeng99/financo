import 'package:equatable/equatable.dart';
import 'package:financo/core/money/money.dart';

/// The kind of transaction. Named [AssetTransaction] (not `Transaction`) to
/// avoid clashing with Drift's `Transaction` type **and** Financo's cash-side
/// `TransactionEntity`.
enum TransactionKind { buy, sell, dividend }

/// Settlement order within the same instant: a buy (then a dividend) settles
/// before a sell, so a same-timestamp deposit covers its redemption. Used as
/// the tiebreak when ordering transactions by date — shared by
/// `oversell_check.dart` and the CSV import so the buy-before-sell rule has one
/// definition. Lower sorts first.
int transactionKindRank(TransactionKind kind) => switch (kind) {
  TransactionKind.buy => 0,
  TransactionKind.dividend => 1,
  TransactionKind.sell => 2,
};

/// Orders transactions oldest-first for replaying a position's timeline: by
/// [AssetTransaction.date], then [AssetTransaction.createdAt], then
/// [transactionKindRank] so a same-instant buy settles before a sell. This is
/// the **single** ordering definition shared by `HoldingCalculator` and
/// `oversell_check.dart`, so the oversell guard and the holding math can never
/// disagree on the order of same-timestamp transactions (e.g. bulk-imported
/// fixed-income cash flows) — a disagreement would let the guard accept a sell
/// the calculator then clamps to zero, corrupting cost basis.
int compareTransactionsOldestFirst(AssetTransaction a, AssetTransaction b) {
  final byDate = a.date.compareTo(b.date);
  if (byDate != 0) return byDate;
  final byCreation = a.createdAt.compareTo(b.createdAt);
  if (byCreation != 0) return byCreation;
  return transactionKindRank(a.kind).compareTo(transactionKindRank(b.kind));
}

/// A buy/sell/dividend event that builds a position. Source of truth for
/// holdings. See `docs/specs/investing_transactions.md`.
class AssetTransaction extends Equatable {
  /// Creates a transaction.
  const AssetTransaction({
    required this.id,
    required this.userId,
    required this.institutionId,
    required this.assetId,
    required this.kind,
    required this.quantity,
    required this.unitPrice,
    required this.fees,
    required this.amount,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.fundingAccountId,
    this.cashAmount,
  });

  /// Stable unique id.
  final String id;

  /// Owner user id.
  final String userId;

  /// Institution where it happened (must equal the asset's institution).
  final String institutionId;

  /// Asset traded.
  final String assetId;

  /// buy / sell / dividend.
  final TransactionKind kind;

  /// Units traded (fractional allowed). Ignored for dividends.
  final double quantity;

  /// Price per unit in the asset's native currency.
  final Money unitPrice;

  /// Brokerage/other fees.
  final Money fees;

  /// For dividends: total received. For buy/sell: `quantity * unitPrice`.
  final Money amount;

  /// When the transaction occurred (not in the future).
  final DateTime date;

  /// Optional free-text note.
  final String? notes;

  /// The checking account the cash came from (buy) / went to (sell). When set,
  /// the app auto-manages a paired cash-flow transaction so the purchase is a
  /// single entry that also feeds the 50/30/20 savings bucket (F8 — see
  /// docs/specs/investing_account_unification.md). Null → cash already at the
  /// broker / external; no cash-flow row is generated.
  final String? fundingAccountId;

  /// The amount that actually moved on the checking side, always in BRL (the
  /// buy's native [amount] may be USD; this is the reais debited/credited).
  /// Non-null only alongside [fundingAccountId].
  final Money? cashAmount;

  /// Audit — creation timestamp.
  final DateTime createdAt;

  /// Audit — last update timestamp.
  final DateTime updatedAt;

  /// Returns a copy with the given fields replaced.
  AssetTransaction copyWith({
    String? institutionId,
    String? assetId,
    TransactionKind? kind,
    double? quantity,
    Money? unitPrice,
    Money? fees,
    Money? amount,
    DateTime? date,
    String? notes,
    String? fundingAccountId,
    Money? cashAmount,
    DateTime? updatedAt,
  }) {
    return AssetTransaction(
      id: id,
      userId: userId,
      institutionId: institutionId ?? this.institutionId,
      assetId: assetId ?? this.assetId,
      kind: kind ?? this.kind,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      fees: fees ?? this.fees,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      fundingAccountId: fundingAccountId ?? this.fundingAccountId,
      cashAmount: cashAmount ?? this.cashAmount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    institutionId,
    assetId,
    kind,
    quantity,
    unitPrice,
    fees,
    amount,
    date,
    notes,
    fundingAccountId,
    cashAmount,
    createdAt,
    updatedAt,
  ];
}
