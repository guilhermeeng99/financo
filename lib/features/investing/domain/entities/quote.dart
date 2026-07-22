import 'package:equatable/equatable.dart';
import 'package:financo/core/money/money.dart';

/// Where a quote came from.
enum QuoteSource { brapi, coingecko, finnhub, tesouro, bcb, manual }

/// Latest known unit price of an asset in its native currency. See
/// `docs/specs/quotes.md`.
class Quote extends Equatable {
  /// Creates a quote.
  const Quote({
    required this.assetId,
    required this.unitPrice,
    required this.asOf,
    required this.fetchedAt,
    required this.source,
    this.previousClose,
  });

  /// Asset this price refers to.
  final String assetId;

  /// Latest unit price (native currency).
  final Money unitPrice;

  /// Previous session close, for day-change (nullable).
  final Money? previousClose;

  /// When the source reported the price.
  final DateTime asOf;

  /// When we cached it (drives staleness).
  final DateTime fetchedAt;

  /// Origin of the quote.
  final QuoteSource source;

  @override
  List<Object?> get props => [
    assetId,
    unitPrice,
    previousClose,
    asOf,
    fetchedAt,
    source,
  ];
}
