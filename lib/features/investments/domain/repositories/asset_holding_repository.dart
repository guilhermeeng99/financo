import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';

abstract class AssetHoldingRepository {
  Future<Either<Failure, List<AssetHoldingEntity>>> getAssetHoldings({
    required String userId,
    bool forceRefresh = false,
  });

  Future<Either<Failure, AssetHoldingEntity>> createAssetHolding(
    AssetHoldingEntity holding,
  );

  Future<Either<Failure, AssetHoldingEntity>> updateAssetHolding(
    AssetHoldingEntity holding,
  );

  Future<Either<Failure, void>> deleteAssetHolding(String id);

  /// Cascade-delete every holding tied to an account. Called by the
  /// accounts cubit after a successful `deleteAccount` so orphan
  /// holdings don't accumulate. Best-effort: failures are logged
  /// upstream but do not block the account delete.
  Future<Either<Failure, void>> deleteHoldingsForAccount(String accountId);

  /// Cascade-delete every holding tied to a class. Used by the asset
  /// class delete flow only after the user explicitly confirms.
  Future<Either<Failure, void>> deleteHoldingsForClass(String classId);
}
