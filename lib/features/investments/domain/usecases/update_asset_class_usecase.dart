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
      return const Left(EmptyNameFailure());
    }
    if (assetClass.targetPercent < 0 || assetClass.targetPercent > 100) {
      return const Left(TargetPercentOutOfRangeFailure());
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
          return const ParentAssetClassNotFoundFailure();
        }
        // Self-parenting guard — must run before the nesting check: a
        // self-referencing class also carries a non-null parentId, which
        // would otherwise trip SubclassCannotBeParentFailure and surface
        // misleading copy to the user.
        if (parent.id == assetClass.id) {
          return const SelfParentAssetClassFailure();
        }
        if (parent.parentId != null) {
          return const SubclassCannotBeParentFailure();
        }
        // Demoting a root that owns subclasses → would create a chain.
        final hasOwnSubclasses =
            classes.any((c) => c.parentId == assetClass.id);
        if (hasOwnSubclasses) {
          return const ClassOwnsSubclassesFailure();
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
