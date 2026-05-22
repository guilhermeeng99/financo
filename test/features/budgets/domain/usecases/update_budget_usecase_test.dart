import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/budgets/domain/usecases/update_budget_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/budget_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late UpdateBudgetUseCase useCase;
  late MockBudgetRepository repo;

  setUpAll(registerBudgetFallbackValues);

  setUp(() {
    repo = MockBudgetRepository();
    useCase = UpdateBudgetUseCase(repo);
  });

  group('UpdateBudgetUseCase', () {
    test('delegates to repository.updateBudget and forwards the budget',
        () async {
      final budget = BudgetFactory.make(amount: 2000);
      when(
        () => repo.updateBudget(any()),
      ).thenAnswer((_) async => Right(budget));

      final result = await useCase(budget);

      expect(result, Right<Failure, BudgetEntity>(budget));
      verify(() => repo.updateBudget(budget)).called(1);
    });

    test('forwards a Left failure from the repository', () async {
      when(() => repo.updateBudget(any())).thenAnswer(
        (_) async => const Left(ServerFailure('update failed')),
      );

      final result = await useCase(BudgetFactory.make());

      expect(result, isA<Left<Failure, BudgetEntity>>());
    });
  });
}
