import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/budgets/domain/usecases/get_budgets_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/budget_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late GetBudgetsUseCase useCase;
  late MockBudgetRepository repo;

  setUp(() {
    repo = MockBudgetRepository();
    useCase = GetBudgetsUseCase(repo);
  });

  group('GetBudgetsUseCase', () {
    const userId = 'user-1';

    test('delegates to repository.getBudgets and forwards the list', () async {
      final budgets = [BudgetFactory.make()];
      when(
        () => repo.getBudgets(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => Right(budgets));

      final result = await useCase(userId: userId);

      expect(result, Right<Failure, List<BudgetEntity>>(budgets));
      verify(() => repo.getBudgets(userId: userId)).called(1);
    });

    test('forwards the forceRefresh flag to the repository', () async {
      when(
        () => repo.getBudgets(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => const Right([]));

      await useCase(userId: userId, forceRefresh: true);

      verify(
        () => repo.getBudgets(userId: userId, forceRefresh: true),
      ).called(1);
    });

    test('forwards a Left failure from the repository', () async {
      when(
        () => repo.getBudgets(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('fetch failed')));

      final result = await useCase(userId: userId);

      expect(result, isA<Left<Failure, List<BudgetEntity>>>());
    });
  });
}
