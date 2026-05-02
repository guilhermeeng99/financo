import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/budgets/domain/repositories/budget_repository.dart';

class UpdateBudgetUseCase {
  const UpdateBudgetUseCase(this._repository);

  final BudgetRepository _repository;

  Future<Either<Failure, BudgetEntity>> call(BudgetEntity budget) =>
      _repository.updateBudget(budget);
}
