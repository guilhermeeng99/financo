import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/budgets_dao.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/repository_guard.dart';
import 'package:financo/features/budgets/data/datasources/budget_remote_datasource.dart';
import 'package:financo/features/budgets/data/models/budget_model.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/budgets/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl({
    required BudgetRemoteDataSource remoteDataSource,
    required BudgetsDao budgetsDao,
  }) : _remote = remoteDataSource,
       _dao = budgetsDao;

  final BudgetRemoteDataSource _remote;
  final BudgetsDao _dao;

  @override
  Future<Either<Failure, List<BudgetEntity>>> getBudgets({
    required String userId,
    bool forceRefresh = false,
  }) {
    return guardServer(() async {
      if (forceRefresh) {
        final remote = await _remote.getBudgets(userId: userId);
        await _dao.insertAllBudgets(remote);
      }
      return _dao.getBudgets(userId: userId);
    });
  }

  @override
  Future<Either<Failure, BudgetEntity>> createBudget(
    BudgetEntity budget,
  ) async {
    // Not routed through guardServer: the uniqueness guard returns a
    // ValidationFailure (not a ServerException) before any remote call.
    try {
      // Uniqueness check: one budget per (userId, categoryId). The remote
      // schema has no native uniqueness guard, so we enforce it here using
      // the local cache — which must be in sync with Firestore for the
      // current user, since every read goes through `getBudgets`.
      final existing = await _dao.getBudgets(userId: budget.userId);
      final dup = existing.any((b) => b.categoryId == budget.categoryId);
      if (dup) {
        return const Left(
          ValidationFailure('Já existe um orçamento para essa categoria.'),
        );
      }
      final result = await _remote.createBudget(BudgetModel.fromEntity(budget));
      await _dao.upsertBudget(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, BudgetEntity>> updateBudget(BudgetEntity budget) {
    return guardServer(() async {
      final result = await _remote.updateBudget(BudgetModel.fromEntity(budget));
      await _dao.upsertBudget(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) {
    return guardServerVoid(() async {
      await _remote.deleteBudget(id);
      await _dao.deleteBudget(id);
    });
  }
}
