import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/repositories/asset_class_repository.dart';
import 'package:financo/features/investments/domain/usecases/create_asset_class_usecase.dart'
    show validateSiblingTargetSum;

class UpdateAssetClassUseCase {
  const UpdateAssetClassUseCase(this._repository);

  final AssetClassRepository _repository;

  Future<Either<Failure, AssetClassEntity>> call(
    AssetClassEntity assetClass,
  ) async {
    if (assetClass.name.trim().isEmpty) {
      return const Left(
        ValidationFailure('Asset class name must not be empty.'),
      );
    }
    if (assetClass.targetPercent < 0 || assetClass.targetPercent > 100) {
      return const Left(
        ValidationFailure('Target percent must be between 0 and 100.'),
      );
    }
    // Same one-nesting-level rule as create (docs/specs/investments.md §1).
    // Also blocks demoting a root that already owns subclasses, since
    // that would create a 2-level chain.
    final result = await _repository.getAssetClasses(userId: assetClass.userId);
    final guard = result.fold<Failure?>((failure) => failure, (classes) {
      if (assetClass.parentId != null) {
        AssetClassEntity? parent;
        for (final c in classes) {
          if (c.id == assetClass.parentId) {
            parent = c;
            break;
          }
        }
        if (parent == null) {
          return const ValidationFailure('Parent class not found.');
        }
        if (parent.parentId != null) {
          return const ValidationFailure(
            'A subclass cannot be the parent of another subclass.',
          );
        }
        // Self-parenting guard.
        if (parent.id == assetClass.id) {
          return const ValidationFailure(
            'A class cannot be its own parent.',
          );
        }
        // Demoting a root that owns subclasses → would create a chain.
        final hasOwnSubclasses =
            classes.any((c) => c.parentId == assetClass.id);
        if (hasOwnSubclasses) {
          return const ValidationFailure(
            'This class owns subclasses — remove or re-parent them '
            'before turning it into a subclass.',
          );
        }
      }
      return validateSiblingTargetSum(
        classes: classes,
        candidate: assetClass,
        isUpdate: true,
      );
    });
    if (guard != null) return Left(guard);
    return _repository.updateAssetClass(assetClass);
  }
}
