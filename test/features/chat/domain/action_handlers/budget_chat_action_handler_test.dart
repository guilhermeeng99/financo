import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/chat/domain/action_handlers/budget_chat_action_handler.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/budget_factory.dart';
import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetCategoriesUseCase mockGetCategories;
  late MockGetBudgetsUseCase mockGetBudgets;
  late MockCreateBudgetUseCase mockCreateBudget;
  late MockUpdateBudgetUseCase mockUpdateBudget;
  late MockDeleteBudgetUseCase mockDeleteBudget;
  late BudgetChatActionHandler handler;
  late AppLocale locale;

  const userId = 'user-1';

  // Root expense category resolved by name in every create/update/delete path.
  final foodCategory = CategoryFactory.expense(id: 'cat-food');

  setUpAll(() {
    registerBudgetFallbackValues();
    registerCategoryFallbackValues();
  });

  setUp(() {
    mockGetCategories = MockGetCategoriesUseCase();
    mockGetBudgets = MockGetBudgetsUseCase();
    mockCreateBudget = MockCreateBudgetUseCase();
    mockUpdateBudget = MockUpdateBudgetUseCase();
    mockDeleteBudget = MockDeleteBudgetUseCase();
    handler = BudgetChatActionHandler(
      getCategories: mockGetCategories,
      getBudgets: mockGetBudgets,
      createBudget: mockCreateBudget,
      updateBudget: mockUpdateBudget,
      deleteBudget: mockDeleteBudget,
    );
    locale = AppLocale.en;
  });

  void stubCategories(List<CategoryEntity> categories) {
    when(
      () => mockGetCategories(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, List<CategoryEntity>>(categories),
    );
  }

  void stubBudgets(List<BudgetEntity> budgets) {
    when(
      () => mockGetBudgets(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, List<BudgetEntity>>(budgets),
    );
  }

  group('handle - create', () {
    test('builds a budget for the resolved category and returns success',
        () async {
      stubCategories([foodCategory]);
      when(() => mockCreateBudget(any())).thenAnswer(
        (_) async => Right<Failure, BudgetEntity>(
          BudgetFactory.make(categoryId: 'cat-food', amount: 800),
        ),
      );

      final result = await handler.handle(
        userId: userId,
        meta: const {
          'action': 'create',
          'category': 'Food',
          'amount': 800,
        },
        locale: locale,
      );

      final captured =
          verify(() => mockCreateBudget(captureAny())).captured;
      final budget = captured.single as BudgetEntity;
      expect(budget.categoryId, 'cat-food');
      expect(budget.userId, userId);
      expect(budget.amount, 800);
      // budgetCreated embeds the resolved category name.
      expect(result, contains('Food'));
    });

    test('resolves category case-insensitively', () async {
      stubCategories([foodCategory]);
      when(() => mockCreateBudget(any())).thenAnswer(
        (_) async => Right<Failure, BudgetEntity>(
          BudgetFactory.make(categoryId: 'cat-food', amount: 500),
        ),
      );

      await handler.handle(
        userId: userId,
        meta: const {
          'action': 'create',
          'category': 'food',
          'amount': 500,
        },
        locale: locale,
      );

      final captured =
          verify(() => mockCreateBudget(captureAny())).captured;
      expect((captured.single as BudgetEntity).categoryId, 'cat-food');
    });

    test('non-positive amount returns invalidAmount without creating',
        () async {
      stubCategories([foodCategory]);

      final result = await handler.handle(
        userId: userId,
        meta: const {
          'action': 'create',
          'category': 'Food',
          'amount': 0,
        },
        locale: locale,
      );

      expect(result, 'Invalid amount.');
      verifyNever(() => mockCreateBudget(any()));
    });

    test('createBudget failure surfaces the error message', () async {
      stubCategories([foodCategory]);
      when(() => mockCreateBudget(any())).thenAnswer(
        (_) async =>
            const Left<Failure, BudgetEntity>(ServerFailure('write denied')),
      );

      final result = await handler.handle(
        userId: userId,
        meta: const {
          'action': 'create',
          'category': 'Food',
          'amount': 300,
        },
        locale: locale,
      );

      expect(result, contains('write denied'));
    });
  });

  group('handle - update', () {
    test('updates the existing budget for the category and returns success',
        () async {
      stubCategories([foodCategory]);
      stubBudgets([
        BudgetFactory.make(id: 'b-1', categoryId: 'cat-food', amount: 100),
      ]);
      when(() => mockUpdateBudget(any())).thenAnswer(
        (_) async => Right<Failure, BudgetEntity>(
          BudgetFactory.make(id: 'b-1', categoryId: 'cat-food', amount: 999),
        ),
      );

      final result = await handler.handle(
        userId: userId,
        meta: const {
          'action': 'update',
          'category': 'Food',
          'amount': 999,
        },
        locale: locale,
      );

      final captured =
          verify(() => mockUpdateBudget(captureAny())).captured;
      final budget = captured.single as BudgetEntity;
      expect(budget.id, 'b-1');
      expect(budget.amount, 999);
      expect(result, contains('Food'));
    });

    test('non-positive amount returns invalidAmount without loading budgets',
        () async {
      stubCategories([foodCategory]);

      final result = await handler.handle(
        userId: userId,
        meta: const {
          'action': 'update',
          'category': 'Food',
          'amount': -5,
        },
        locale: locale,
      );

      expect(result, 'Invalid amount.');
      verifyNever(
        () => mockGetBudgets(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      );
      verifyNever(() => mockUpdateBudget(any()));
    });

    test('returns budgetNoActive when category has no budget', () async {
      stubCategories([foodCategory]);
      stubBudgets([
        BudgetFactory.make(id: 'b-other', categoryId: 'cat-other'),
      ]);

      final result = await handler.handle(
        userId: userId,
        meta: const {
          'action': 'update',
          'category': 'Food',
          'amount': 200,
        },
        locale: locale,
      );

      expect(result, 'No active budget for "Food".');
      verifyNever(() => mockUpdateBudget(any()));
    });
  });

  group('handle - delete', () {
    test('deletes the existing budget by id and returns success', () async {
      stubCategories([foodCategory]);
      stubBudgets([
        BudgetFactory.make(id: 'b-1', categoryId: 'cat-food'),
      ]);
      when(() => mockDeleteBudget(any())).thenAnswer(
        (_) async => const Right<Failure, void>(null),
      );

      final result = await handler.handle(
        userId: userId,
        meta: const {
          'action': 'delete',
          'category': 'Food',
        },
        locale: locale,
      );

      final captured =
          verify(() => mockDeleteBudget(captureAny())).captured;
      expect(captured.single, 'b-1');
      expect(result, contains('Food'));
    });

    test('returns budgetNoActive when category has no budget', () async {
      stubCategories([foodCategory]);
      stubBudgets(const []);

      final result = await handler.handle(
        userId: userId,
        meta: const {
          'action': 'delete',
          'category': 'Food',
        },
        locale: locale,
      );

      expect(result, 'No active budget for "Food".');
      verifyNever(() => mockDeleteBudget(any()));
    });

    test('deleteBudget failure surfaces the error message', () async {
      stubCategories([foodCategory]);
      stubBudgets([
        BudgetFactory.make(id: 'b-1', categoryId: 'cat-food'),
      ]);
      when(() => mockDeleteBudget(any())).thenAnswer(
        (_) async => const Left<Failure, void>(ServerFailure('delete failed')),
      );

      final result = await handler.handle(
        userId: userId,
        meta: const {
          'action': 'delete',
          'category': 'Food',
        },
        locale: locale,
      );

      expect(result, contains('delete failed'));
    });
  });

  group('handle - category resolution', () {
    test('empty category name returns budgetCategoryRequired', () async {
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'create', 'category': '   ', 'amount': 100},
        locale: locale,
      );

      expect(result, 'A category is required for the budget.');
      verifyNever(
        () => mockGetCategories(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      );
    });

    test('failed category load returns budgetLoadCategoriesFailed', () async {
      when(
        () => mockGetCategories(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, List<CategoryEntity>>(ServerFailure('boom')),
      );

      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'create', 'category': 'Food', 'amount': 100},
        locale: locale,
      );

      expect(result, "Couldn't load categories.");
    });

    test('unresolved category name returns budgetCategoryNotFound', () async {
      stubCategories([foodCategory]);

      final result = await handler.handle(
        userId: userId,
        meta: const {
          'action': 'create',
          'category': 'Travel',
          'amount': 100,
        },
        locale: locale,
      );

      expect(result, 'Category "Travel" not found.');
      verifyNever(() => mockCreateBudget(any()));
    });
  });

  test('unknown action returns unknownBudgetAction fallback', () async {
    stubCategories([foodCategory]);

    final result = await handler.handle(
      userId: userId,
      meta: const {'action': 'archive', 'category': 'Food'},
      locale: locale,
    );

    expect(result, 'Unknown budget action.');
  });
}
