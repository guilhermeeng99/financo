import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/repositories/asset_class_repository.dart';

class CreateAssetClassUseCase {
  const CreateAssetClassUseCase(this._repository);

  final AssetClassRepository _repository;

  Future<Either<Failure, AssetClassEntity>> call(
    AssetClassEntity assetClass,
  ) async {
    final validation = _validate(assetClass);
    if (validation != null) return Left(validation);

    // Pull the full list once so we can check both the
    // parent-must-be-root and sibling-sum-≤-100 invariants in one
    // pass.
    final result = await _repository.getAssetClasses(
      userId: assetClass.userId,
    );
    final guard = result.fold<Failure?>(
      (failure) => failure,
      (classes) => _validateAgainst(classes, assetClass, isUpdate: false),
    );
    if (guard != null) return Left(guard);

    return _repository.createAssetClass(assetClass);
  }

  Failure? _validate(AssetClassEntity assetClass) {
    if (assetClass.name.trim().isEmpty) {
      return const EmptyNameFailure();
    }
    if (assetClass.targetPercent < 0 || assetClass.targetPercent > 100) {
      return const TargetPercentOutOfRangeFailure();
    }
    return null;
  }

  Failure? _validateAgainst(
    List<AssetClassEntity> classes,
    AssetClassEntity candidate, {
    required bool isUpdate,
  }) {
    if (candidate.parentId != null) {
      AssetClassEntity? parent;
      for (final c in classes) {
        if (c.id == candidate.parentId) {
          parent = c;
          break;
        }
      }
      if (parent == null) {
        return const ParentAssetClassNotFoundFailure();
      }
      if (parent.parentId != null) {
        return const SubclassCannotBeParentFailure();
      }
    }
    return validateSiblingTargetSum(
      classes: classes,
      candidate: candidate,
      isUpdate: isUpdate,
    );
  }
}

/// Shared between create + update. Sums the `targetPercent` of every
/// sibling (same `parentId`, excluding the candidate itself on
/// updates) and rejects when the total — including the candidate —
/// exceeds 100 by more than a float tolerance.
///
/// Roots vs roots share the global 100% budget; subclasses share
/// their parent's 100% budget. The error message lists both numbers
/// so the user knows how much head-room is left.
Failure? validateSiblingTargetSum({
  required List<AssetClassEntity> classes,
  required AssetClassEntity candidate,
  required bool isUpdate,
}) {
  final siblingSum = classes
      .where(
        (c) =>
            c.parentId == candidate.parentId &&
            (!isUpdate || c.id != candidate.id),
      )
      .fold<double>(0, (sum, c) => sum + c.targetPercent);
  final newSum = siblingSum + candidate.targetPercent;
  if (newSum <= 100 + 0.01) return null;
  final available = (100 - siblingSum).clamp(0.0, 100.0);
  return TargetSumExceededFailure(
    availablePercent: available,
    isRoot: candidate.parentId == null,
  );
}
