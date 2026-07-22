import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/data/datasources/guarded_fetch.dart';
import 'package:financo/features/investing/domain/datasources/quote_data_source.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/quote.dart';
import 'package:http/http.dart' as http;

/// Prices Tesouro Direto bonds via B3's public market endpoint. A single
/// request returns every bond; each held treasury asset is matched by name and
/// priced at its redemption unit value (`untrRedVal`) — what the holder
/// receives today, so the right figure for current valuation. Keyless. See
/// `docs/specs/quotes.md`.
class TesouroDiretoDataSource implements QuoteDataSource {
  /// Creates the adapter over an HTTP client.
  const TesouroDiretoDataSource(this._client);

  final http.Client _client;

  static const _endpoint =
      'https://www.tesourodireto.com.br/json/br/com/b3/tesourodireto'
      '/service/api/treasury/getMarket';

  @override
  bool supports(Asset asset) => asset.kind == AssetKind.treasury;

  @override
  Future<Either<Failure, List<Quote>>> fetch(List<Asset> assets) async {
    final supported = assets.where(supports).toList();
    if (supported.isEmpty) return const Right([]);

    return guardedFetch(() async {
      final response = await _client.get(Uri.parse(_endpoint));
      if (response.statusCode != 200) {
        return const Left(ServerFailure('Treasury request failed.'));
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final priceByName = _redemptionPricesByName(data);
      final now = DateTime.now();
      final quotes = <Quote>[];
      for (final asset in supported) {
        final price = priceByName[_matchKey(asset)];
        if (price == null) continue;
        quotes.add(
          Quote(
            assetId: asset.id,
            unitPrice: Money.fromMajor(price, asset.currency),
            asOf: now,
            fetchedAt: now,
            source: QuoteSource.tesouro,
          ),
        );
      }
      return Right(quotes);
    });
  }

  /// Redemption unit value (`untrRedVal`) of every bond, keyed by normalized
  /// name.
  Map<String, double> _redemptionPricesByName(Map<String, dynamic> data) {
    final response = data['response'] as Map<String, dynamic>?;
    final list = (response?['TrsrBdTradgList'] as List<dynamic>?) ?? const [];
    final prices = <String, double>{};
    for (final raw in list) {
      final bond =
          (raw as Map<String, dynamic>)['TrsrBd'] as Map<String, dynamic>?;
      final name = bond?['nm'] as String?;
      final price = (bond?['untrRedVal'] as num?)?.toDouble();
      if (name == null || price == null) continue;
      prices[_normalize(name)] = price;
    }
    return prices;
  }

  /// Prefers an explicit `tesouroName`; falls back to the asset's display name
  /// so a well-named asset prices without extra setup.
  String _matchKey(Asset asset) {
    final tesouroName = asset.metadata['tesouroName'];
    return _normalize(
      tesouroName == null || tesouroName.isEmpty ? asset.name : tesouroName,
    );
  }

  /// Tolerant comparison key: trimmed, lowercased, single-spaced.
  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
