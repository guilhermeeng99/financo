import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/budgets/domain/repositories/budget_repository.dart';

class CreateBudgetUseCase {
  const CreateBudgetUseCase(this._repository);

  final BudgetRepository _repository;

  Future<Either<Failure, BudgetEntity>> call(BudgetEntity budget) =>
      _repository.createBudget(budget);
}
