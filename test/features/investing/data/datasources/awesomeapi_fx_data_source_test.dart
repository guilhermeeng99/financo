import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/data/datasources/awesomeapi_fx_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(Uri.parse('https://example.com')));

  test('short-circuits to 1 for the same currency (no request)', () async {
    final client = MockHttpClient();
    final ds = AwesomeApiFxDataSource(client);

    final r = await ds.rate(Currency.brl, Currency.brl);
    r.fold((_) => fail('expected a rate'), (v) => expect(v, 1));
    verifyNever(() => client.get(any()));
  });

  test('parses the bid from the pair node', () async {
    final client = MockHttpClient();
    when(() => client.get(any())).thenAnswer(
      (_) async => http.Response('{"USDBRL":{"bid":"5.12"}}', 200),
    );
    final ds = AwesomeApiFxDataSource(client);

    final r = await ds.rate(Currency.usd, Currency.brl);
    r.fold((_) => fail('expected a rate'), (v) => expect(v, 5.12));
  });

  test('returns a failure on a non-200 response', () async {
    final client = MockHttpClient();
    when(
      () => client.get(any()),
    ).thenAnswer((_) async => http.Response('nope', 500));
    final ds = AwesomeApiFxDataSource(client);

    final r = await ds.rate(Currency.usd, Currency.brl);
    expect(r.isLeft(), isTrue);
  });
}
