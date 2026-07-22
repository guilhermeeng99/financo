import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/data/datasources/proxy_market_quote_data_source.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/quote.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  late MockFirebaseFunctions functions;
  late MockHttpsCallable callable;

  setUp(() {
    functions = MockFirebaseFunctions();
    callable = MockHttpsCallable();
    when(
      () => functions.httpsCallable('fetchInvestmentQuotes'),
    ).thenReturn(callable);
  });

  test('supports only BR and US equity kinds', () {
    final ds = ProxyMarketQuoteDataSource(functions: functions);
    expect(ds.supports(AssetFactory.stockBr()), isTrue);
    expect(ds.supports(AssetFactory.stockUs()), isTrue);
    final crypto = AssetFactory.stockBr().copyWith(kind: AssetKind.crypto);
    expect(ds.supports(crypto), isFalse);
  });

  test('maps proxied quotes back to Quote entities', () async {
    final result = MockHttpsCallableResult<Map<Object?, Object?>>();
    when(
      () => callable.call<Map<Object?, Object?>>(any<Map<String, dynamic>>()),
    ).thenAnswer((_) async => result);
    when(() => result.data).thenReturn({
      'quotes': [
        {
          'assetId': 'asset-petr4',
          'price': 40.0,
          'previousClose': 39.0,
          'currency': 'BRL',
        },
      ],
    });

    final ds = ProxyMarketQuoteDataSource(functions: functions);
    final fetched = await ds.fetch([AssetFactory.stockBr()]);
    final quotes = fetched.getOrElse(() => []);

    expect(quotes, hasLength(1));
    expect(quotes.first.unitPrice, Money.fromMajor(40, Currency.brl));
    expect(quotes.first.previousClose, Money.fromMajor(39, Currency.brl));
    expect(quotes.first.source, QuoteSource.brapi);
  });
}
