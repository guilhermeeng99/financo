import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/data/datasources/tesouro_direto_data_source.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(Uri.parse('https://example.com')));

  test(
    'matches a treasury by name and prices at the redemption value',
    () async {
      final client = MockHttpClient();
      when(() => client.get(any())).thenAnswer(
        (_) async => http.Response(
          '{"response":{"TrsrBdTradgList":['
          '{"TrsrBd":{"nm":"Tesouro Selic 2027","untrRedVal":140.5}}]}}',
          200,
        ),
      );
      final ds = TesouroDiretoDataSource(client);
      final asset = Asset(
        id: 't1',
        userId: 'u',
        ticker: 'SELIC2027',
        name: 'Tesouro Selic 2027',
        kind: AssetKind.treasury,
        market: Market.br,
        currency: Currency.brl,
        createdAt: DateTime(2024),
      );

      final result = await ds.fetch([asset]);
      final quotes = result.getOrElse(() => []);
      expect(quotes, hasLength(1));
      expect(quotes.first.unitPrice, Money.fromMajor(140.5, Currency.brl));
    },
  );
}
