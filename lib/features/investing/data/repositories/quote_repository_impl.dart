import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/quotes_dao.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/datasources/quote_data_source.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/quote.dart';
import 'package:financo/features/investing/domain/repositories/quote_repository.dart';

/// Caches quotes in Drift and routes refreshes to the registered data sources.
/// Failures degrade gracefully — the cache is served and quotes are flagged
/// stale rather than surfacing an error (see `docs/specs/quotes.md`).
class QuoteRepositoryImpl implements QuoteRepository {
  /// Creates the repository over the [quotesDao] cache and the ordered
  /// [sources] registry.
  const QuoteRepositoryImpl({
    required QuotesDao quotesDao,
    required List<QuoteDataSource> sources,
  }) : _dao = quotesDao,
       _sources = sources;

  final QuotesDao _dao;
  final List<QuoteDataSource> _sources;

  @override
  Future<Either<Failure, List<Quote>>> getCached(List<String> assetIds) async {
    if (assetIds.isEmpty) return const Right([]);
    try {
      return Right(await _dao.getQuotesByAssetIds(assetIds));
    } on Exception {
      return const Left(ServerFailure('Failed to read cached quotes.'));
    }
  }

  @override
  Future<Either<Failure, List<Quote>>> refresh(List<Asset> assets) async {
    final collected = <Quote>[];
    var attempted = false;
    var succeeded = false;

    for (final source in _sources) {
      final supported = assets.where(source.supports).toList();
      if (supported.isEmpty) continue;
      attempted = true;
      final result = await source.fetch(supported);
      result.fold((_) {}, (quotes) {
        collected.addAll(quotes);
        succeeded = true;
      });
    }

    if (collected.isNotEmpty) await _dao.upsertQuotes(collected);
    if (attempted && !succeeded) {
      return const Left(ServerFailure('Failed to refresh quotes.'));
    }
    return Right(collected);
  }

  @override
  Future<DateTime?> lastFetchedAt(List<String> assetIds) async {
    if (assetIds.isEmpty) return null;
    try {
      return await _dao.newestFetchedAt(assetIds);
    } on Exception {
      // A cache read error must not crash the freshness check (it runs on the
      // hot dashboard/allocation refresh path). Treat it as "no known fetch" so
      // the engine refreshes from the network instead of throwing.
      return null;
    }
  }
}
