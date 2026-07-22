import 'package:equatable/equatable.dart';
import 'package:financo/core/money/money.dart';

/// A dated point on the net-worth history: the portfolio consolidated to the
/// base currency on a given day. One per user per calendar day (idempotent —
/// re-recording the same day overwrites). See `docs/specs/valuation.md`.
class Snapshot extends Equatable {
  /// Creates a snapshot. [totalValue], [totalInvested] and [unrealizedPL] are
  /// all in the same base currency.
  const Snapshot({
    required this.userId,
    required this.date,
    required this.totalValue,
    required this.totalInvested,
    required this.unrealizedPL,
  });

  /// Owner.
  final String userId;

  /// The calendar day this snapshot represents (local midnight).
  final DateTime date;

  /// Consolidated market value on [date].
  final Money totalValue;

  /// Consolidated cost basis on [date].
  final Money totalInvested;

  /// Consolidated unrealized P/L on [date].
  final Money unrealizedPL;

  /// `yyyy-MM-dd` key used as the idempotency key for the day.
  String get dayKey => snapshotDayKey(date);

  @override
  List<Object?> get props => [
    userId,
    date,
    totalValue,
    totalInvested,
    unrealizedPL,
  ];
}

/// Formats [date] as `yyyy-MM-dd` (local), the per-day idempotency key. Kept a
/// free function so the entity stays dependency-free (no intl).
String snapshotDayKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
