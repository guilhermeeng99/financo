import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/data/repositories/market_cache_store_impl.dart';
import 'package:financo/features/investing/domain/entities/index_point.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2024));
    registerFallbackValue(<IndexPoint>[]);
  });

  late MockFxRatesDao fx;
  late MockIndexPointsDao index;
  late DriftMarketCacheStore store;

  setUp(() {
    fx = MockFxRatesDao();
    index = MockIndexPointsDao();
    store = DriftMarketCacheStore(fxRatesDao: fx, indexPointsDao: index);
  });

  test('lastFxRate reads by the "FROM->TO" pair key', () async {
    when(() => fx.getRate('USD->BRL')).thenAnswer((_) async => 5.12);
    expect(await store.lastFxRate(Currency.usd, Currency.brl), 5.12);
  });

  test('saveFxRate writes under the pair key', () async {
    when(() => fx.saveRate(any(), any(), any())).thenAnswer((_) async {});
    await store.saveFxRate(Currency.usd, Currency.brl, 5);
    verify(() => fx.saveRate('USD->BRL', 5, any())).called(1);
  });

  test('allIndexSeries maps stored names to EconomicIndex', () async {
    when(() => index.allByIndexName()).thenAnswer(
      (_) async => {
        'cdi': [IndexPoint(date: DateTime(2024), rate: 0.04)],
      },
    );
    final series = await store.allIndexSeries();
    expect(series[EconomicIndex.cdi], hasLength(1));
  });

  test('saveIndexSeries writes under the index name', () async {
    when(() => index.saveSeries(any(), any())).thenAnswer((_) async {});
    await store.saveIndexSeries(EconomicIndex.cdi, [
      IndexPoint(date: DateTime(2024), rate: 0.04),
    ]);
    verify(() => index.saveSeries('cdi', any())).called(1);
  });
}
