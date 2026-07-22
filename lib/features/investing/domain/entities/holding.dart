import 'package:equatable/equatable.dart';
import 'package:financo/core/money/money.dart';

/// A derived net position of one asset at one institution: quantity + weighted
/// average cost, plus realized results. Value object (no id, no userId — it is
/// computed from transactions by `HoldingCalculator`, never persisted). See
/// `docs/specs/holdings.md`.
class Holding extends Equatable {
  /// Creates a holding.
  const Holding({
    required this.assetId,
    required this.institutionId,
    required this.quantity,
    required this.avgCost,
    required this.realizedPL,
    required this.dividends,
  });

  /// Asset id (group key).
  final String assetId;

  /// Institution id (group key).
  final String institutionId;

  /// Net quantity (Σ buys − Σ sells). Zero means a closed position.
  final double quantity;

  /// Weighted average cost per unit (native currency, fees included).
  final Money avgCost;

  /// Realized profit/loss from sells (native currency).
  final Money realizedPL;

  /// Accumulated dividends received (native currency).
  final Money dividends;

  /// Cost basis of the open position (`quantity * avgCost`).
  Money get investedCost => avgCost * quantity;

  /// Whether the position is closed (quantity is effectively zero).
  bool get isClosed => quantity.abs() < 1e-9;

  @override
  List<Object?> get props => [
    assetId,
    institutionId,
    quantity,
    avgCost,
    realizedPL,
    dividends,
  ];
}
