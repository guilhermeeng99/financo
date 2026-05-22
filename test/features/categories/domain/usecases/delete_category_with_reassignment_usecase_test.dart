import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/categories/domain/usecases/delete_category_with_reassignment_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/budget_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockTransactionRepository transactions;
  late MockGetBudgetsUseCase getBudgets;
  late MockDeleteBudgetUseCase deleteBudget;
  late MockDeleteCategoryUseCase deleteCategory;
  late DeleteCategoryWithReassignmentUseCase useCase;

  setUp(() {
    transactions = MockTransactionRepository();
    getBudgets = MockGetBudgetsUseCase();
    deleteBudget = MockDeleteBudgetUseCase();
    deleteCategory = MockDeleteCategoryUseCase();
    useCase = DeleteCategoryWithReassignmentUseCase(
      transactionRepository: transactions,
      getBudgets: getBudgets,
      deleteBudget: deleteBudget,
      deleteCategory: deleteCategory,
    );
  });

  void stubReassignRight() {
    when(
      () => transactions.reassignTransactions(
        fromCategoryId: any(named: 'fromCategoryId'),
        toCategoryId: any(named: 'toCategoryId'),
      ),
    ).thenAnswer((_) async => const Right<Failure, void>(null));
  }

  group('DeleteCategoryWithReassignmentUseCase', () {
    test('reassigns, cascades only matching budgets, then deletes', () async {
      stubReassignRight();
      when(() => getBudgets(userId: any(named: 'userId'))).thenAnswer(
        (_) async => Right<Failure, List<BudgetEntity>>([
          BudgetFactory.make(id: 'b1', categoryId: 'from'),
          BudgetFactory.make(id: 'b2', categoryId: 'other'),
        ]),
      );
      when(
        () => deleteBudget(any()),
      ).thenAnswer((_) async => const Right<Failure, void>(null));
      when(
        () => deleteCategory(any()),
      ).thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await useCase(
        userId: 'u1',
        fromCategoryId: 'from',
        toCategoryId: 'to',
      );

      expect(result.isRight(), isTrue);
      verify(
        () => transactions.reassignTransactions(
          fromCategoryId: 'from',
          toCategoryId: 'to',
        ),
      ).called(1);
      verify(() => deleteBudget('b1')).called(1);
      verifyNever(() => deleteBudget('b2'));
      verify(() => deleteCategory('from')).called(1);
    });

    test('returns failure and skips delete when reassign fails', () async {
      when(
        () => transactions.reassignTransactions(
          fromCategoryId: any(named: 'fromCategoryId'),
          toCategoryId: any(named: 'toCategoryId'),
        ),
      ).thenAnswer((_) async => const Left<Failure, void>(ServerFailure()));

      final result = await useCase(
        userId: 'u1',
        fromCategoryId: 'from',
        toCategoryId: 'to',
      );

      expect(result.isLeft(), isTrue);
      verifyNever(() => getBudgets(userId: any(named: 'userId')));
      verifyNever(() => deleteCategory(any()));
    });

    test('still deletes the category when budget lookup fails', () async {
      stubReassignRight();
      when(() => getBudgets(userId: any(named: 'userId'))).thenAnswer(
        (_) async => const Left<Failure, List<BudgetEntity>>(ServerFailure()),
      );
      when(
        () => deleteCategory(any()),
      ).thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await useCase(
        userId: 'u1',
        fromCategoryId: 'from',
        toCategoryId: 'to',
      );

      expect(result.isRight(), isTrue);
      verifyNever(() => deleteBudget(any()));
      verify(() => deleteCategory('from')).called(1);
    });
  });
}
