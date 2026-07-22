import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/repositories/asset_repository.dart';
import 'package:financo/features/investing/domain/repositories/asset_transaction_repository.dart';
import 'package:financo/features/investing/domain/repositories/institution_repository.dart';

/// Deletes an institution, blocked while any asset or transaction still
/// references it (institutions.md rule 2).
class DeleteInstitutionUseCase {
  const DeleteInstitutionUseCase({
    required InstitutionRepository institutionRepository,
    required AssetRepository assetRepository,
    required AssetTransactionRepository transactionRepository,
  }) : _institutions = institutionRepository,
       _assets = assetRepository,
       _transactions = transactionRepository;

  final InstitutionRepository _institutions;
  final AssetRepository _assets;
  final AssetTransactionRepository _transactions;

  Future<Either<Failure, void>> call(Institution institution) async {
    final assetsResult = await _assets.getAssets(userId: institution.userId);
    final assetsFailure = assetsResult.fold<Failure?>((f) => f, (_) => null);
    if (assetsFailure != null) return Left(assetsFailure);
    final referencedByAsset = assetsResult
        .getOrElse(() => const [])
        .any((a) => a.institutionId == institution.id);
    if (referencedByAsset) return const Left(InstitutionInUseFailure());

    final txsResult = await _transactions.getTransactions(
      userId: institution.userId,
    );
    final txsFailure = txsResult.fold<Failure?>((f) => f, (_) => null);
    if (txsFailure != null) return Left(txsFailure);
    final referencedByTx = txsResult
        .getOrElse(() => const [])
        .any((t) => t.institutionId == institution.id);
    if (referencedByTx) return const Left(InstitutionInUseFailure());

    return _institutions.deleteInstitution(institution.id);
  }
}
