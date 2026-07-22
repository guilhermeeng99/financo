import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/data/datasources/coingecko_quote_data_source.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(Uri.parse('https://example.com')));

  const brl = Currency.brl;
  Asset btc() => Asset(
    id: 'c1',
    userId: 'u',
    ticker: 'BTC',
    name: 'Bitcoin',
    kind: AssetKind.crypto,
    market: Market.global,
    currency: brl,
    createdAt: DateTime(2024),
  );

  test('supports only crypto assets', () {
    final ds = CoinGeckoQuoteDataSource(MockHttpClient());
    expect(ds.supports(btc()), isTrue);
    expect(ds.supports(AssetFactory.stockBr()), isFalse);
  });

  test('parses price and previous close from the 24h change', () async {
    final client = MockHttpClient();
    when(() => client.get(any())).thenAnswer(
      (_) async => http.Response(
        '{"bitcoin":{"brl":100000,"brl_24h_change":25}}',
        200,
      ),
    );
    final ds = CoinGeckoQuoteDataSource(client);

    final result = await ds.fetch([btc()]);
    final quotes = result.getOrElse(() => []);
    expect(quotes, hasLength(1));
    expect(quotes.first.unitPrice, Money.fromMajor(100000, brl));
    // 100000 / (1 + 25/100) = 80000
    expect(quotes.first.previousClose, Money.fromMajor(80000, brl));
  });
}
