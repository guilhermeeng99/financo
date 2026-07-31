import 'package:drift/drift.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/tables/quotes_table.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/core/utils/enum_parse.dart';
import 'package:financo/features/investing/domain/entities/quote.dart';

part 'quotes_dao.g.dart';

@DriftAccessor(tables: [LocalQuotes])
class QuotesDao extends DatabaseAccessor<AppDatabase> with _$QuotesDaoMixin {
  QuotesDao(super.attachedDatabase);

  Future<List<Quote>> getQuotesByAssetIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final rows = await (select(
      localQuotes,
    )..where((t) => t.assetId.isIn(ids))).get();
    return rows.map(_toQuote).toList();
  }

  Future<void> upsertQuotes(List<Quote> quotes) async {
    await batch((b) {
      for (final q in quotes) {
        b.insert(
          localQuotes,
          _toCompanion(q),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  /// Newest cached `fetchedAt` across [ids], or null when none are cached.
  Future<DateTime?> newestFetchedAt(List<String> ids) async {
    if (ids.isEmpty) return null;
    final rows = await (select(
      localQuotes,
    )..where((t) => t.assetId.isIn(ids))).get();
    if (rows.isEmpty) return null;
    return rows.map((r) => r.fetchedAt).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  Future<void> deleteAllQuotes() => delete(localQuotes).go();

  LocalQuotesCompanion _toCompanion(Quote q) => LocalQuotesCompanion.insert(
    assetId: q.assetId,
    unitPriceMinor: q.unitPrice.minorUnits,
    previousCloseMinor: Value(q.previousClose?.minorUnits),
    currency: q.unitPrice.currency.name,
    asOf: q.asOf,
    fetchedAt: q.fetchedAt,
    source: q.source.name,
  );

  Quote _toQuote(LocalQuote row) {
    final ccy = enumByName(Currency.values, row.currency, Currency.brl);
    final previous = row.previousCloseMinor;
    return Quote(
      assetId: row.assetId,
      unitPrice: Money(row.unitPriceMinor, ccy),
      previousClose: previous == null ? null : Money(previous, ccy),
      asOf: row.asOf,
      fetchedAt: row.fetchedAt,
      source: enumByName(QuoteSource.values, row.source, QuoteSource.manual),
    );
  }
}
