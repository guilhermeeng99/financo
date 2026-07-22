import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
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
    this.now = DateTime.now,
  });

  final FxDataSource _inner;

  /// How long a cached rate stays fresh.
  final Duration ttl;

  /// Clock seam, injectable for tests.
  final DateTime Function() now;

  final Map<String, ({double rate, DateTime at})> _cache = {};

  @override
  Future<Either<Failure, double>> rate(Currency from, Currency to) async {
    final key = '${from.name}->${to.name}';
    final hit = _cache[key];
    if (hit != null && now().difference(hit.at) < ttl) {
      return Right(hit.rate);
    }
    final result = await _inner.rate(from, to);
    result.fold((_) {}, (rate) => _cache[key] = (rate: rate, at: now()));
    return result;
  }
}
