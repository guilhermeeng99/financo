import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  Future<Either<Failure, List<CategoryEntity>>> call({
    required String userId,
    bool forceRefresh = false,
  }) => _repository.getCategories(userId: userId, forceRefresh: forceRefresh);
}
