import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';
import 'package:financo/features/investments/domain/repositories/asset_class_repository.dart';
import 'package:financo/features/investments/domain/repositories/asset_holding_repository.dart';

/// Deletes an asset class. Rule 5 of `docs/specs/investments.md`: refuses
/// to delete when holdings still reference the class. The user must
/// either reassign or delete the holdings first. We return the
/// blocking holding count in the failure message so the UI can build
/// a helpful confirm-or-cleanup prompt.
class DeleteAssetClassUseCase {
  const DeleteAssetClassUseCase({
    required AssetClassRepository assetClassRepository,
    required AssetHoldingRepository assetHoldingRepository,
  }) : _classRepository = assetClassRepository,
       _holdingRepository = assetHoldingRepository;

  final AssetClassRepository _classRepository;
  final AssetHoldingRepository _holdingRepository;

  Future<Either<Failure, void>> call({
    required String id,
    required String userId,
  }) async {
    // Block when subclasses still point at this class — the user must
    // remove or re-parent them first (docs/specs/investments.md §1 rule 5).
    final classesResult = await _classRepository.getAssetClasses(
      userId: userId,
    );
    final subclassFailure = classesResult.fold<Failure?>(
      (failure) => failure,
      (classes) {
        final subs = classes.where((c) => c.parentId == id).toList();
        if (subs.isEmpty) return null;
        return ValidationFailure(
          'Cannot delete: ${subs.length} subclass(es) still reference '
          'this class.',
        );
      },
    );
    if (subclassFailure != null) return Left(subclassFailure);

    final holdingsResult = await _holdingRepository.getAssetHoldings(
      userId: userId,
    );
    final blockingFailure = await holdingsResult.fold<Future<Failure?>>(
      (failure) async => failure,
      (holdings) async {
        final tied = holdings.where((h) => h.assetClassId == id).toList();
        if (tied.isEmpty) return null;
        return ValidationFailure(
          'Cannot delete: ${tied.length} holding(s) still reference '
          'this class.',
        );
      },
    );
    if (blockingFailure != null) return Left(blockingFailure);

    return _classRepository.deleteAssetClass(id);
  }

  /// Variant that the user opted into after seeing the warning —
  /// removes the tied holdings first, then the class itself. Used by
  /// the "Delete class AND its holdings" path in the UI.
  Future<Either<Failure, void>> callWithCascade({
    required String id,
  }) async {
    final purge = await _holdingRepository.deleteHoldingsForClass(id);
    return purge.fold(
      Left.new,
      (_) => _classRepository.deleteAssetClass(id),
    );
  }

  /// Helper for callers that just need to know "is this class deletable
  /// right now without cascading?" — surfaces the tied holdings list so
  /// the dialog can list them.
  Future<Either<Failure, List<AssetHoldingEntity>>> getBlockingHoldings({
    required String id,
    required String userId,
  }) async {
    final result = await _holdingRepository.getAssetHoldings(userId: userId);
    return result.map(
      (all) => all.where((h) => h.assetClassId == id).toList(),
    );
  }
}
