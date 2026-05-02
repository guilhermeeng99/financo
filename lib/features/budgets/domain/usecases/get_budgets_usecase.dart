import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/budgets/domain/repositories/budget_repository.dart';

class GetBudgetsUseCase {
  const GetBudgetsUseCase(this._repository);

  final BudgetRepository _repository;

  Future<Either<Failure, List<BudgetEntity>>> call({
    required String userId,
    bool forceRefresh = false,
  }) => _repository.getBudgets(
    userId: userId,
    forceRefresh: forceRefresh,
  );
}
