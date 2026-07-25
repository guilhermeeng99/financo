import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/data/datasources/ttl_cache.dart';
import 'package:financo/features/investing/domain/datasources/quote_data_source.dart';

/// Wraps an [FxDataSource] with a short in-memory TTL cache, so back-to-back
/// refreshes — and the dashboard + allocation cubits, which share this
/// singleton — reuse a recent rate instead of re-hitting the network. A failed
/// fetch is not cached, so the next call retries. See `docs/specs/quotes.md`
/// rule 5.
class CachingFxDataSource implements FxDataSource {
  /// Wraps [_inner]; [ttl] defaults to 10 minutes (FX drifts intraday).
  CachingFxDataSource(
    this._inner, {
    this.ttl = const Duration(minutes: 10),
    DateTime Function() now = DateTime.now,
  }) : _cache = TtlCache(now: now);

  final FxDataSource _inner;

  /// How long a cached rate stays fresh.
  final Duration ttl;

  final TtlCache<String, double> _cache;

  @override
  Future<Either<Failure, double>> rate(Currency from, Currency to) {
    final key = '${from.name}->${to.name}';
    return _cache.getOrFetch(key, ttl, () => _inner.rate(from, to));
  }
}
