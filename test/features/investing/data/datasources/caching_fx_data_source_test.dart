import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/data/datasources/caching_fx_data_source.dart';
import 'package:financo/features/investing/domain/datasources/quote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

class _CountingFx implements FxDataSource {
  int calls = 0;
  Either<Failure, double> result = const Right(5);

  @override
  Future<Either<Failure, double>> rate(Currency from, Currency to) async {
    calls++;
    return result;
  }
}

void main() {
  test('serves a cached rate within the TTL without re-fetching', () async {
    var now = DateTime(2024);
    final inner = _CountingFx();
    final caching = CachingFxDataSource(inner, now: () => now);

    await caching.rate(Currency.usd, Currency.brl);
    now = now.add(const Duration(minutes: 5));
    await caching.rate(Currency.usd, Currency.brl);

    expect(inner.calls, 1);
  });

  test('re-fetches once the TTL has elapsed', () async {
    var now = DateTime(2024);
    final inner = _CountingFx();
    final caching = CachingFxDataSource(inner, now: () => now);

    await caching.rate(Currency.usd, Currency.brl);
    now = now.add(const Duration(minutes: 11));
    await caching.rate(Currency.usd, Currency.brl);

    expect(inner.calls, 2);
  });

  test('does not cache a failed fetch', () async {
    final inner = _CountingFx()..result = const Left(ServerFailure());
    final caching = CachingFxDataSource(inner, now: () => DateTime(2024));

    await caching.rate(Currency.usd, Currency.brl);
    await caching.rate(Currency.usd, Currency.brl);

    expect(inner.calls, 2);
  });
}
