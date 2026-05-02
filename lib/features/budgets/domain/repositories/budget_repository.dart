import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';

abstract class BudgetRepository {
  Future<Either<Failure, List<BudgetEntity>>> getBudgets({
    required String userId,
    bool forceRefresh = false,
  });

  /// Validates `(userId, categoryId)` uniqueness before writing — duplicates
  /// return `Left(ValidationFailure)` per spec rule 1.
  Future<Either<Failure, BudgetEntity>> createBudget(BudgetEntity budget);

  Future<Either<Failure, BudgetEntity>> updateBudget(BudgetEntity budget);

  Future<Either<Failure, void>> deleteBudget(String id);
}
