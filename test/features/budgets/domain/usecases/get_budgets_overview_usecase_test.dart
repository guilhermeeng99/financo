import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/budgets/domain/usecases/get_budgets_overview_usecase.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/budget_factory.dart';
import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockBudgetRepository budgetRepo;
  late MockCategoryRepository categoryRepo;
  late MockTransactionRepository transactionRepo;
  late GetBudgetsOverviewUseCase useCase;

  setUp(() {
    budgetRepo = MockBudgetRepository();
    categoryRepo = MockCategoryRepository();
    transactionRepo = MockTransactionRepository();
    useCase = GetBudgetsOverviewUseCase(
      budgetRepository: budgetRepo,
      categoryRepository: categoryRepo,
      transactionRepository: transactionRepo,
    );
  });

  void stubBudgets(List<BudgetEntity> budgets) {
    when(
      () => budgetRepo.getBudgets(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Right(budgets));
  }

  void stubCategories(List<CategoryEntity> categories) {
    when(
      () => categoryRepo.getCategories(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Right(categories));
  }

  void stubTransactions(List<TransactionEntity> transactions) {
    when(
      () => transactionRepo.getTransactions(
        userId: any(named: 'userId'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        categoryId: any(named: 'categoryId'),
        accountId: any(named: 'accountId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Right(transactions));
  }

  const userId = 'user-1';
  final month = DateTime(2026, 4, 15);

  test('aggregates root-category transactions into spent', () async {
    final root = CategoryFactory.expense(id: 'cat-food', name: 'Alimentação');
    stubBudgets([
      BudgetFactory.make(id: 'b1', categoryId: 'cat-food', amount: 1000),
    ]);
    stubCategories([root]);
    stubTransactions([
      TransactionFactory.expense(
        id: 't1',
        categoryId: 'cat-food',
        amount: 200,
      ),
      TransactionFactory.expense(
        id: 't2',
        categoryId: 'cat-food',
        amount: 75,
      ),
    ]);

    final result = await useCase(userId: userId, month: month);

    expect(result.isRight(), isTrue);
    final overviews = result.getOrElse(() => throw StateError('expected'));
    expect(overviews.length, 1);
    expect(overviews.first.spent, 275);
    expect(overviews.first.categoryName, 'Alimentação');
  });

  test('rolls subcategory spend up into the parent budget', () async {
    final root = CategoryFactory.expense(id: 'cat-food', name: 'Alimentação');
    final child = CategoryFactory.subcategory(
      id: 'cat-restaurant',
      name: 'Restaurantes',
      parentId: 'cat-food',
    );
    stubBudgets([
      BudgetFactory.make(categoryId: 'cat-food', amount: 1000),
    ]);
    stubCategories([root, child]);
    stubTransactions([
      TransactionFactory.expense(
        id: 't1',
        categoryId: 'cat-food',
        amount: 100,
      ),
      TransactionFactory.expense(
        id: 't2',
        categoryId: 'cat-restaurant',
        amount: 250,
      ),
    ]);

    final result = await useCase(userId: userId, month: month);
    final overviews = result.getOrElse(() => throw StateError('expected'));
    expect(overviews.first.spent, 350);
  });

  test('excludes transfers from spent', () async {
    final root = CategoryFactory.expense(id: 'cat-food');
    stubBudgets([BudgetFactory.make(categoryId: 'cat-food', amount: 1000)]);
    stubCategories([root]);
    final pair = TransactionFactory.transfer(amount: 700);
    stubTransactions([
      TransactionFactory.expense(categoryId: 'cat-food', amount: 100),
      // Set the transfer leg's category to the budgeted one to prove the
      // exclusion is driven by `isTransfer`, not by the empty categoryId
      // the factory uses by default.
      pair.expense.copyWith(categoryId: 'cat-food'),
    ]);

    final result = await useCase(userId: userId, month: month);
    final overviews = result.getOrElse(() => throw StateError('expected'));
    expect(overviews.first.spent, 100);
  });

  test('excludes income transactions from spent', () async {
    final root = CategoryFactory.expense(id: 'cat-food');
    stubBudgets([BudgetFactory.make(categoryId: 'cat-food', amount: 1000)]);
    stubCategories([root]);
    stubTransactions([
      TransactionFactory.expense(categoryId: 'cat-food', amount: 100),
      // An income row filed against an expense category — should not
      // contribute to spend.
      TransactionFactory.income(categoryId: 'cat-food', amount: 9999),
    ]);

    final result = await useCase(userId: userId, month: month);
    final overviews = result.getOrElse(() => throw StateError('expected'));
    expect(overviews.first.spent, 100);
  });

  test('skips orphan budget when category was deleted', () async {
    stubBudgets([
      BudgetFactory.make(id: 'b1', categoryId: 'cat-deleted', amount: 1000),
    ]);
    stubCategories(const []);
    stubTransactions(const []);

    final result = await useCase(userId: userId, month: month);
    final overviews = result.getOrElse(() => throw StateError('expected'));
    expect(overviews, isEmpty);
  });

  test('skips budget pointing at a subcategory (defensive)', () async {
    final child = CategoryFactory.subcategory(
      id: 'cat-restaurant',
      parentId: 'cat-food',
    );
    stubBudgets([BudgetFactory.make(categoryId: 'cat-restaurant')]);
    stubCategories([
      CategoryFactory.expense(id: 'cat-food'),
      child,
    ]);
    stubTransactions(const []);

    final result = await useCase(userId: userId, month: month);
    final overviews = result.getOrElse(() => throw StateError('expected'));
    expect(overviews, isEmpty);
  });

  test('sorts overviews by category name (case-insensitive)', () async {
    stubBudgets([
      BudgetFactory.make(id: 'b1', categoryId: 'cat-z'),
      BudgetFactory.make(id: 'b2', categoryId: 'cat-a'),
    ]);
    stubCategories([
      CategoryFactory.expense(id: 'cat-z', name: 'Zero'),
      CategoryFactory.expense(id: 'cat-a', name: 'alpha'),
    ]);
    stubTransactions(const []);

    final result = await useCase(userId: userId, month: month);
    final overviews = result.getOrElse(() => throw StateError('expected'));
    expect(
      overviews.map((o) => o.categoryName).toList(),
      ['alpha', 'Zero'],
    );
  });

  test('returns Left when budgets fetch fails', () async {
    when(
      () => budgetRepo.getBudgets(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => const Left(ServerFailure()));
    stubCategories(const []);
    stubTransactions(const []);

    final result = await useCase(userId: userId, month: month);
    expect(result.isLeft(), isTrue);
  });
}
