import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/usecases/create_budget_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/budget_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late CreateBudgetUseCase useCase;
  late MockBudgetRepository repo;

  setUpAll(registerBudgetFallbackValues);

  setUp(() {
    repo = MockBudgetRepository();
    useCase = CreateBudgetUseCase(repo);
  });

  test('delegates to repository', () async {
    final budget = BudgetFactory.make();
    when(() => repo.createBudget(any())).thenAnswer((_) async => Right(budget));

    final result = await useCase(budget);

    expect(result.isRight(), isTrue);
    verify(() => repo.createBudget(budget)).called(1);
  });

  test('propagates ValidationFailure for duplicates', () async {
    final budget = BudgetFactory.make();
    when(() => repo.createBudget(any())).thenAnswer(
      (_) async => const Left(ValidationFailure('Já existe um orçamento')),
    );

    final result = await useCase(budget);
    expect(result.isLeft(), isTrue);
  });
}
