import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/quote.dart';

/// Cached-first access to quotes. See `docs/specs/quotes.md`.
abstract class QuoteRepository {
  /// Returns cached quotes for the given asset ids (may be empty/stale).
  Future<Either<Failure, List<Quote>>> getCached(List<String> assetIds);

  /// Fetches fresh quotes from the data sources and updates the cache. Returns
  /// the quotes obtained (a partial set on partial failure).
  Future<Either<Failure, List<Quote>>> refresh(List<Asset> assets);

  /// The newest `fetchedAt` among cached quotes for [assetIds], or null when
  /// none are cached. Lets a caller skip a redundant network refresh while the
  /// cache is still fresh — both portfolio screens dedupe against this signal.
  Future<DateTime?> lastFetchedAt(List<String> assetIds);
}
