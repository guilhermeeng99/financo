import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';

/// Reads/writes investing transactions (buy/sell/dividend), the source of truth
/// for holdings. Firestore-primary with a Drift cache. See
/// `docs/specs/investing_transactions.md`.
abstract class AssetTransactionRepository {
  Future<Either<Failure, List<AssetTransaction>>> getTransactions({
    required String userId,
    bool forceRefresh = false,
  });

  /// Creates or updates a transaction (upsert). Enforces the institution-match,
  /// non-positive-quantity, oversell and future-date rules before writing.
  Future<Either<Failure, AssetTransaction>> saveTransaction(
    AssetTransaction tx,
  );

  Future<Either<Failure, void>> deleteTransaction(String id);
}
