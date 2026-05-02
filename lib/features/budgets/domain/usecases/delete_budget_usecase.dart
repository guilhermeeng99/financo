import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/repositories/budget_repository.dart';

class DeleteBudgetUseCase {
  const DeleteBudgetUseCase(this._repository);

  final BudgetRepository _repository;

  Future<Either<Failure, void>> call(String id) =>
      _repository.deleteBudget(id);
}
