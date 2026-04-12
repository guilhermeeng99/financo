import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';

class UpdateCategoryUseCase {
  const UpdateCategoryUseCase(this._repository);

  final CategoryRepository _repository;

  Future<Either<Failure, CategoryEntity>> call(CategoryEntity category) =>
      _repository.updateCategory(category);
}
