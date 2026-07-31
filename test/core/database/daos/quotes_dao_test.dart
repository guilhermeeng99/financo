import 'package:drift/native.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/quotes_dao.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/quote.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late QuotesDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.quotesDao;
  });

  tearDown(() => db.close());

  Quote quote({
    String assetId = 'asset-aapl',
    Money? unitPrice,
    Money? previousClose,
    DateTime? asOf,
    DateTime? fetchedAt,
    QuoteSource source = QuoteSource.brapi,
  }) => Quote(
    assetId: assetId,
    unitPrice: unitPrice ?? const Money(19099, Currency.usd),
    previousClose: previousClose,
    asOf: asOf ?? DateTime(2024, 3, 5, 21),
    fetchedAt: fetchedAt ?? DateTime(2024, 3, 5, 22),
    source: source,
  );

  group('upsertQuotes + getQuotesByAssetIds', () {
    test('round-trips a quote exactly', () async {
      final q = quote(previousClose: const Money(18950, Currency.usd));

      await dao.upsertQuotes([q]);

      expect((await dao.getQuotesByAssetIds(['asset-aapl'])).single, q);
    });

    test('preserves prices to the exact minor unit', () async {
      await dao.upsertQuotes([
        quote(
          unitPrice: const Money(1234567, Currency.usd),
          previousClose: const Money(1234566, Currency.usd),
        ),
      ]);

      final read = (await dao.getQuotesByAssetIds(['asset-aapl'])).single;
      expect(read.unitPrice.minorUnits, 1234567);
      expect(read.previousClose!.minorUnits, 1234566);
    });

    test('keeps previousClose null when the source omits it', () async {
      // Day-change is hidden rather than shown as -100% when there is no
      // previous close.
      await dao.upsertQuotes([quote()]);

      expect(
        (await dao.getQuotesByAssetIds(['asset-aapl'])).single.previousClose,
        isNull,
      );
    });

    test('replaces the cached quote for an asset on re-fetch', () async {
      await dao.upsertQuotes([
        quote(unitPrice: const Money(100, Currency.usd)),
      ]);
      await dao.upsertQuotes([
        quote(unitPrice: const Money(200, Currency.usd)),
      ]);

      final all = await dao.getQuotesByAssetIds(['asset-aapl']);
      expect(all, hasLength(1));
      expect(all.single.unitPrice.minorUnits, 200);
    });

    test('returns only the requested assets', () async {
      await dao.upsertQuotes([
        quote(),
        quote(assetId: 'asset-petr4'),
        quote(assetId: 'asset-btc'),
      ]);

      final read = await dao.getQuotesByAssetIds([
        'asset-aapl',
        'asset-btc',
      ]);

      expect(
        read.map((q) => q.assetId).toSet(),
        {'asset-aapl', 'asset-btc'},
      );
    });

    test('returns empty for an empty id list without querying', () async {
      await dao.upsertQuotes([quote()]);

      expect(await dao.getQuotesByAssetIds([]), isEmpty);
    });
  });

  group('newestFetchedAt', () {
    test('returns the newest fetch across the given assets', () async {
      // This is the shared freshness signal the two portfolio screens use to
      // dedupe refreshes; taking anything but the newest would re-fetch.
      await dao.upsertQuotes([
        quote(fetchedAt: DateTime(2024, 3, 5, 10)),
        quote(assetId: 'asset-petr4', fetchedAt: DateTime(2024, 3, 5, 18)),
        quote(assetId: 'asset-btc', fetchedAt: DateTime(2024, 3, 5, 14)),
      ]);

      expect(
        await dao.newestFetchedAt([
          'asset-aapl',
          'asset-petr4',
          'asset-btc',
        ]),
        DateTime(2024, 3, 5, 18),
      );
    });

    test('ignores assets outside the given ids', () async {
      await dao.upsertQuotes([
        quote(fetchedAt: DateTime(2024, 3, 5, 10)),
        quote(assetId: 'asset-petr4', fetchedAt: DateTime(2024, 3, 5, 18)),
      ]);

      expect(
        await dao.newestFetchedAt(['asset-aapl']),
        DateTime(2024, 3, 5, 10),
      );
    });

    test('returns null when nothing is cached', () async {
      expect(await dao.newestFetchedAt(['asset-aapl']), isNull);
    });

    test('returns null for an empty id list', () async {
      expect(await dao.newestFetchedAt([]), isNull);
    });
  });

  test('deleteAllQuotes clears the cache', () async {
    await dao.upsertQuotes([quote(), quote(assetId: 'asset-petr4')]);

    await dao.deleteAllQuotes();

    expect(
      await dao.getQuotesByAssetIds(['asset-aapl', 'asset-petr4']),
      isEmpty,
    );
  });
}
