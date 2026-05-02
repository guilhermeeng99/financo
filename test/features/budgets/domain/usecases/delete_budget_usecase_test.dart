import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/usecases/delete_budget_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late DeleteBudgetUseCase useCase;
  late MockBudgetRepository repo;

  setUp(() {
    repo = MockBudgetRepository();
    useCase = DeleteBudgetUseCase(repo);
  });

  test('delegates to repository', () async {
    when(
      () => repo.deleteBudget(any()),
    ).thenAnswer((_) async => const Right<Failure, void>(null));

    final result = await useCase('budget-1');

    expect(result, const Right<Failure, void>(null));
    verify(() => repo.deleteBudget('budget-1')).called(1);
  });

  test('propagates failure', () async {
    when(
      () => repo.deleteBudget(any()),
    ).thenAnswer(
      (_) async => const Left<Failure, void>(ServerFailure('boom')),
    );

    final result = await useCase('budget-1');
    expect(result, isA<Left<Failure, void>>());
  });
}
