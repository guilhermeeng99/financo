import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';

/// In-memory time-to-live cache with an injectable clock, shared by the
/// market-data caching datasources (FX rates, economic-index series).
///
/// [getOrFetch] returns the cached value for a key while it is younger than the
/// given TTL, else it runs the fetch and caches only a successful ([Right])
/// result — a failed fetch is never cached, so the next call retries. The one
/// place the "fetch-through with TTL and a clock seam" logic lives, so the FX
/// and index caches don't each re-implement it. See `docs/specs/quotes.md`.
///
/// Example:
/// ```dart
/// final cache = TtlCache<String, double>();
/// final rate = await cache.getOrFetch(key, ttl, () => source.rate(from, to));
/// ```
class TtlCache<K, V> {
  /// [now] is the clock seam, injectable for deterministic tests.
  TtlCache({DateTime Function() now = DateTime.now}) : _now = now;

  final DateTime Function() _now;
  final Map<K, ({V value, DateTime at})> _entries = {};

  /// Returns the fresh cached value for [key], or awaits [fetch] and caches its
  /// success. A [Left] result is returned to the caller but not cached.
  Future<Either<Failure, V>> getOrFetch(
    K key,
    Duration ttl,
    Future<Either<Failure, V>> Function() fetch,
  ) async {
    final hit = _entries[key];
    if (hit != null && _now().difference(hit.at) < ttl) {
      return Right(hit.value);
    }
    final result = await fetch();
    result.fold((_) {}, (value) => _entries[key] = (value: value, at: _now()));
    return result;
  }
}
