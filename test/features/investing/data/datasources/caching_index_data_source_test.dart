import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/data/datasources/caching_index_data_source.dart';
import 'package:financo/features/investing/domain/datasources/index_data_source.dart';
import 'package:financo/features/investing/domain/entities/index_point.dart';
import 'package:flutter_test/flutter_test.dart';

class _CountingIndex implements IndexDataSource {
  int calls = 0;

  @override
  Future<Either<Failure, List<IndexPoint>>> series(
    EconomicIndex index,
    DateTime from,
  ) async {
    calls++;
    return Right([IndexPoint(date: from, rate: 0.04)]);
  }
}

void main() {
  test('serves a cached series within the TTL', () async {
    var now = DateTime(2024);
    final inner = _CountingIndex();
    final caching = CachingIndexDataSource(inner, now: () => now);

    await caching.series(EconomicIndex.cdi, DateTime(2024));
    now = now.add(const Duration(hours: 1));
    await caching.series(EconomicIndex.cdi, DateTime(2024));

    expect(inner.calls, 1);
  });

  test('re-fetches once the TTL has elapsed', () async {
    var now = DateTime(2024);
    final inner = _CountingIndex();
    final caching = CachingIndexDataSource(inner, now: () => now);

    await caching.series(EconomicIndex.cdi, DateTime(2024));
    now = now.add(const Duration(hours: 13));
    await caching.series(EconomicIndex.cdi, DateTime(2024));

    expect(inner.calls, 2);
  });
}
