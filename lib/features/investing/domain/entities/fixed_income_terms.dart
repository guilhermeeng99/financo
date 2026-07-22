import 'package:equatable/equatable.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/index_point.dart';

/// How a fixed-income position accrues. Drives which formula values it.
enum FixedIncomeBasis {
  /// Percentage of the CDI daily rate (e.g. 110% of CDI).
  cdi,

  /// Percentage of the Selic daily rate.
  selic,

  /// Fixed annual rate, compounded over business days (e.g. 12% a.a.).
  prefixed,

  /// IPCA monthly inflation plus a fixed annual spread (e.g. IPCA + 6% a.a.).
  ipca,
}

/// Maps an accrual basis to the BCB index whose series it needs.
extension FixedIncomeBasisIndex on FixedIncomeBasis {
  /// The economic index to fetch, or null for `prefixed` (needs no series).
  EconomicIndex? get economicIndex => switch (this) {
    FixedIncomeBasis.cdi => EconomicIndex.cdi,
    FixedIncomeBasis.selic => EconomicIndex.selic,
    FixedIncomeBasis.ipca => EconomicIndex.ipca,
    FixedIncomeBasis.prefixed => null,
  };
}

/// A dated cash movement on a fixed-income position: a deposit (positive
/// [amount]) or a withdrawal/redemption (negative). Each flow accrues the index
/// from its own [date], so a CDB/RDB with many deposits **and partial
/// redemptions** values correctly — by linearity of daily accrual, the balance
/// today is `Σ amount × accrualFactor(date → now)` regardless of order.
class FixedIncomeCashFlow extends Equatable {
  /// Creates a cash flow. [amount] is signed: deposits positive, withdrawals
  /// negative (native currency).
  const FixedIncomeCashFlow({required this.date, required this.amount});

  /// When the money moved — accrual start (deposit) or stop (withdrawal).
  final DateTime date;

  /// Signed amount: `+` deposit (aplicação), `−` withdrawal (resgate).
  final Money amount;

  @override
  List<Object?> get props => [date, amount];
}

/// Everything needed to accrue one fixed-income holding to its current value.
///
/// [ratePercent] meaning depends on [basis]:
/// - `cdi`/`selic`: percent **of** the index (110 → 110% of CDI);
/// - `prefixed`: the annual rate itself (12 → 12% a.a.);
/// - `ipca`: the annual spread over inflation (6 → IPCA + 6% a.a.).
///
/// The position is a list of dated [cashFlows] (deposits and withdrawals); each
/// accrues from its own date. [series] is the index observations since the
/// earliest flow (daily for CDI/Selic, monthly for IPCA); empty for `prefixed`.
class FixedIncomeTerms extends Equatable {
  /// Creates the terms.
  const FixedIncomeTerms({
    required this.basis,
    required this.ratePercent,
    required this.cashFlows,
    this.series = const [],
  });

  /// Accrual basis.
  final FixedIncomeBasis basis;

  /// Contracted rate; meaning varies by [basis] (see class doc).
  final double ratePercent;

  /// Dated deposits/withdrawals making up the position.
  final List<FixedIncomeCashFlow> cashFlows;

  /// Index observations since the earliest cash flow; empty for `prefixed`.
  final List<IndexPoint> series;

  /// Earliest cash-flow date, or null when there are none.
  DateTime? get earliestDate => cashFlows.isEmpty
      ? null
      : cashFlows.map((c) => c.date).reduce((a, b) => a.isBefore(b) ? a : b);

  @override
  List<Object?> get props => [basis, ratePercent, cashFlows, series];
}
