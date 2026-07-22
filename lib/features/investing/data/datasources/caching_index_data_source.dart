import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
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
    this.now = DateTime.now,
  });

  final IndexDataSource _inner;

  /// How long a cached series stays fresh.
  final Duration ttl;

  /// Clock seam, injectable for tests.
  final DateTime Function() now;

  final Map<String, ({List<IndexPoint> points, DateTime at})> _cache = {};

  @override
  Future<Either<Failure, List<IndexPoint>>> series(
    EconomicIndex index,
    DateTime from,
  ) async {
    final key = '${index.name}@${from.toIso8601String()}';
    final hit = _cache[key];
    if (hit != null && now().difference(hit.at) < ttl) {
      return Right(hit.points);
    }
    final result = await _inner.series(index, from);
    result.fold((_) {}, (points) => _cache[key] = (points: points, at: now()));
    return result;
  }
}
