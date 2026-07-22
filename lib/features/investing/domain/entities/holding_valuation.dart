import 'package:equatable/equatable.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';

/// A priced holding: money figures consolidated to the base currency. See
/// `docs/specs/valuation.md`.
class HoldingValuation extends Equatable {
  /// Creates a holding valuation.
  const HoldingValuation({
    required this.assetId,
    required this.institutionId,
    required this.assetKind,
    required this.quantity,
    required this.marketValueBase,
    required this.marketValueNative,
    required this.investedBase,
    required this.unrealizedPL,
    required this.totalPL,
    required this.returnPct,
    required this.dayChangeBase,
    required this.priceStale,
    this.fxMissing = false,
  });

  /// Asset id.
  final String assetId;

  /// Institution id.
  final String institutionId;

  /// Asset class (for allocation).
  final AssetKind assetKind;

  /// Net quantity held.
  final double quantity;

  /// Current market value (base currency).
  final Money marketValueBase;

  /// Current market value in the asset's **own** currency (e.g. USD for an
  /// Avenue ETF). Equals [marketValueBase] for base-currency holdings. Lets the
  /// UI show the native amount alongside the consolidated one.
  final Money marketValueNative;

  /// Cost basis (base currency).
  final Money investedBase;

  /// Unrealized profit/loss (base currency).
  final Money unrealizedPL;

  /// Unrealized + realized + dividends (base currency).
  final Money totalPL;

  /// Unrealized return as a ratio (0.12 = +12%).
  final double returnPct;

  /// Change since previous close (base currency).
  final Money dayChangeBase;

  /// Whether the price is missing or stale.
  final bool priceStale;

  /// Whether this foreign holding was excluded from totals because no FX rate
  /// was available to consolidate it to the base currency.
  final bool fxMissing;

  @override
  List<Object?> get props => [
    assetId,
    institutionId,
    assetKind,
    quantity,
    marketValueBase,
    marketValueNative,
    investedBase,
    unrealizedPL,
    totalPL,
    returnPct,
    dayChangeBase,
    priceStale,
    fxMissing,
  ];
}
