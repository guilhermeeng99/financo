import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/accounts/domain/services/account_fx_converter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late MockFxDataSource fx;
  late MockMarketCacheStore cache;
  late AccountFxConverter converter;

  setUpAll(() => registerFallbackValue(Currency.brl));

  setUp(() {
    fx = MockFxDataSource();
    cache = MockMarketCacheStore();
    converter = AccountFxConverter(fxDataSource: fx, cache: cache);
    when(
      () => cache.saveFxRate(any(), any(), any()),
    ).thenAnswer((_) async {});
  });

  group('rateToBrl', () {
    test('returns 1 for BRL without touching cache or network', () async {
      final rate = await converter.rateToBrl(Currency.brl);

      expect(rate, 1);
      verifyNever(() => cache.lastFxRate(any(), any()));
      verifyNever(() => fx.rate(any(), any()));
    });

    test('uses the cached rate and does not fetch', () async {
      when(
        () => cache.lastFxRate(Currency.usd, Currency.brl),
      ).thenAnswer((_) async => 5);

      final rate = await converter.rateToBrl(Currency.usd);

      expect(rate, 5);
      verifyNever(() => fx.rate(any(), any()));
    });

    test('fetches and persists on a cache miss', () async {
      when(
        () => cache.lastFxRate(Currency.usd, Currency.brl),
      ).thenAnswer((_) async => null);
      when(
        () => fx.rate(Currency.usd, Currency.brl),
      ).thenAnswer((_) async => const Right(5.2));

      final rate = await converter.rateToBrl(Currency.usd);

      expect(rate, 5.2);
      verify(
        () => cache.saveFxRate(Currency.usd, Currency.brl, 5.2),
      ).called(1);
    });

    test('returns null when uncached and the fetch fails', () async {
      when(
        () => cache.lastFxRate(any(), any()),
      ).thenAnswer((_) async => null);
      when(
        () => fx.rate(any(), any()),
      ).thenAnswer((_) async => const Left(ServerFailure()));

      final rate = await converter.rateToBrl(Currency.eur);

      expect(rate, isNull);
      verifyNever(() => cache.saveFxRate(any(), any(), any()));
    });
  });

  group('toBrl', () {
    test('multiplies the native amount by the rate', () async {
      when(
        () => cache.lastFxRate(Currency.eur, Currency.brl),
      ).thenAnswer((_) async => 6);

      final brl = await converter.toBrl(100, Currency.eur);

      expect(brl, 600);
    });

    test('returns null when the rate is unavailable', () async {
      when(() => cache.lastFxRate(any(), any())).thenAnswer((_) async => null);
      when(
        () => fx.rate(any(), any()),
      ).thenAnswer((_) async => const Left(ServerFailure()));

      final brl = await converter.toBrl(100, Currency.eur);

      expect(brl, isNull);
    });
  });

  group('ratesToBrl', () {
    test('resolves each currency and omits the ones without a rate', () async {
      when(
        () => cache.lastFxRate(Currency.usd, Currency.brl),
      ).thenAnswer((_) async => 5);
      when(
        () => cache.lastFxRate(Currency.eur, Currency.brl),
      ).thenAnswer((_) async => null);
      when(
        () => fx.rate(Currency.eur, Currency.brl),
      ).thenAnswer((_) async => const Left(ServerFailure()));

      final rates = await converter.ratesToBrl([
        Currency.brl,
        Currency.usd,
        Currency.eur,
      ]);

      expect(rates[Currency.brl], 1);
      expect(rates[Currency.usd], 5);
      expect(rates.containsKey(Currency.eur), isFalse);
    });
  });
}
