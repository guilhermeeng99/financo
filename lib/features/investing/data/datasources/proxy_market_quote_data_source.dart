import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/data/datasources/guarded_fetch.dart';
import 'package:financo/features/investing/domain/datasources/quote_data_source.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/quote.dart';

/// Prices the **keyed** sources (brapi for BR equities/FIIs/ETFs/BDRs, Finnhub
/// for US equities/ETFs) through the `fetchInvestmentQuotes` Cloud Function, so
/// the API tokens stay backend secrets rather than shipping in the web bundle.
/// Keyless sources price directly on the client. See `docs/specs/quotes.md`.
class ProxyMarketQuoteDataSource implements QuoteDataSource {
  /// Creates the adapter over Cloud Functions.
  ProxyMarketQuoteDataSource({required FirebaseFunctions functions})
    : _callable = functions.httpsCallable('fetchInvestmentQuotes');

  final HttpsCallable _callable;

  static const Set<AssetKind> _brapiKinds = {
    AssetKind.stockBr,
    AssetKind.fiiBr,
    AssetKind.etfBr,
    AssetKind.bdrBr,
  };
  static const Set<AssetKind> _finnhubKinds = {
    AssetKind.stockUs,
    AssetKind.etfUs,
  };

  @override
  bool supports(Asset asset) => _sourceFor(asset.kind) != null;

  String? _sourceFor(AssetKind kind) {
    if (_brapiKinds.contains(kind)) return 'brapi';
    if (_finnhubKinds.contains(kind)) return 'finnhub';
    return null;
  }

  @override
  Future<Either<Failure, List<Quote>>> fetch(List<Asset> assets) async {
    final supported = assets.where(supports).toList();
    if (supported.isEmpty) return const Right([]);

    return guardedFetch(() async {
      final items = [
        for (final asset in supported)
          {
            'assetId': asset.id,
            'ticker': asset.ticker,
            'source': _sourceFor(asset.kind),
          },
      ];
      final response = await _callable.call<Map<Object?, Object?>>({
        'items': items,
      });
      final data = Map<String, dynamic>.from(response.data);
      final rawQuotes = (data['quotes'] as List<dynamic>?) ?? const [];
      final assetsById = {for (final a in supported) a.id: a};
      final now = DateTime.now();

      final quotes = <Quote>[];
      for (final raw in rawQuotes) {
        final map = Map<String, dynamic>.from(raw as Map);
        final asset = assetsById[map['assetId'] as String?];
        final price = (map['price'] as num?)?.toDouble();
        if (asset == null || price == null) continue;
        final previous = (map['previousClose'] as num?)?.toDouble();
        final source = map['currency'] == 'USD'
            ? QuoteSource.finnhub
            : QuoteSource.brapi;
        quotes.add(
          Quote(
            assetId: asset.id,
            unitPrice: Money.fromMajor(price, asset.currency),
            previousClose: previous == null
                ? null
                : Money.fromMajor(previous, asset.currency),
            asOf: now,
            fetchedAt: now,
            source: source,
          ),
        );
      }
      return Right(quotes);
    });
  }
}
