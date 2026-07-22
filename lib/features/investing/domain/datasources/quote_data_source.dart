import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/quote.dart';

/// A source of unit prices for some kinds of asset. See `docs/specs/quotes.md`.
abstract class QuoteDataSource {
  /// Whether this source can price [asset].
  bool supports(Asset asset);

  /// Fetches quotes for the supported subset of [assets]. Unsupported assets
  /// are ignored; failures return a [Failure].
  Future<Either<Failure, List<Quote>>> fetch(List<Asset> assets);
}

/// A source of FX rates.
abstract class FxDataSource {
  /// Returns the multiplier converting [from] into [to] (1.0 when equal).
  Future<Either<Failure, double>> rate(Currency from, Currency to);
}
