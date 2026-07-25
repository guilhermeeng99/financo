import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/data/datasources/ttl_cache.dart';
import 'package:financo/features/investing/domain/datasources/index_data_source.dart';
import 'package:financo/features/investing/domain/entities/index_point.dart';

/// Wraps an [IndexDataSource] with an in-memory TTL cache keyed by (index,
/// from), so a refresh reuses a recently fetched series instead of
/// re-downloading it. Index series move at most daily, so the TTL defaults to
/// 12 hours. A failed fetch is not cached. See `docs/specs/quotes.md` rule 5.
class CachingIndexDataSource implements IndexDataSource {
  /// Wraps [_inner]; [ttl] defaults to 12 hours.
  CachingIndexDataSource(
    this._inner, {
    this.ttl = const Duration(hours: 12),
    DateTime Function() now = DateTime.now,
  }) : _cache = TtlCache(now: now);

  final IndexDataSource _inner;

  /// How long a cached series stays fresh.
  final Duration ttl;

  final TtlCache<String, List<IndexPoint>> _cache;

  @override
  Future<Either<Failure, List<IndexPoint>>> series(
    EconomicIndex index,
    DateTime from,
  ) {
    final key = '${index.name}@${from.toIso8601String()}';
    return _cache.getOrFetch(key, ttl, () => _inner.series(index, from));
  }
}
