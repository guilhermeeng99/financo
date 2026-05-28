import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/chat/domain/action_handlers/category_chat_action_handler.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockCreateCategoryUseCase mockCreateCategory;
  late MockGetCategoriesUseCase mockGetCategories;
  late MockDeleteCategoryUseCase mockDeleteCategory;
  late CategoryChatActionHandler handler;
  late AppLocale locale;

  const userId = 'user-1';

  setUpAll(registerCategoryFallbackValues);

  setUp(() {
    mockCreateCategory = MockCreateCategoryUseCase();
    mockGetCategories = MockGetCategoriesUseCase();
    mockDeleteCategory = MockDeleteCategoryUseCase();
    handler = CategoryChatActionHandler(
      createCategory: mockCreateCategory,
      getCategories: mockGetCategories,
      deleteCategory: mockDeleteCategory,
    );
    locale = AppLocale.en;
  });

  void stubGetCategories(List<CategoryEntity> categories) {
    when(
      () => mockGetCategories(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, List<CategoryEntity>>(categories),
    );
  }

  group('create', () {
    test('builds entity from meta and returns success message', () async {
      stubGetCategories(const []);
      when(() => mockCreateCategory(any())).thenAnswer(
        (_) async => Right<Failure, CategoryEntity>(
          CategoryFactory.income(name: 'Bonus'),
        ),
      );

      final result = await handler.handle(
        userId: userId,
        meta: const {
          'action': 'create',
          'name': 'Bonus',
          'type': 'income',
          'icon': 99999,
        },
        locale: locale,
      );

      // The handler echoes the created category's name (not the meta name),
      // proving it surfaced the Right branch from the use case.
      expect(result, 'Category "Bonus" created successfully!');

      final captured =
          verify(() => mockCreateCategory(captureAny())).captured;
      final category = captured.first as CategoryEntity;
      expect(category.userId, userId);
      expect(category.name, 'Bonus');
      expect(category.type, CategoryType.income);
      expect(category.icon, 99999);
      // New categories are always created with an empty id (server assigns).
      expect(category.id, isEmpty);
    });

    test('defaults to expense type and default icon when meta omits them',
        () async {
      stubGetCategories(const []);
      when(() => mockCreateCategory(any())).thenAnswer(
        (_) async => Right<Failure, CategoryEntity>(
          CategoryFactory.expense(name: 'Misc'),
        ),
      );

      await handler.handle(
        userId: userId,
        meta: const {'action': 'create', 'name': 'Misc'},
        locale: locale,
      );

      final captured =
          verify(() => mockCreateCategory(captureAny())).captured;
      final category = captured.first as CategoryEntity;
      expect(category.type, CategoryType.expense);
      // Falls back to Icons.category codepoint when no icon is suggested.
      expect(category.icon, 58332);
    });

    test('surfaces create failure as localized error string', () async {
      stubGetCategories(const []);
      when(() => mockCreateCategory(any())).thenAnswer(
        (_) async =>
            const Left<Failure, CategoryEntity>(ServerFailure('DB down')),
      );

      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'create', 'name': 'Food', 'type': 'expense'},
        locale: locale,
      );

      expect(result, 'Failed to create category: DB down');
    });
  });

  group('delete', () {
    test('resolves category id by case-insensitive name and deletes it',
        () async {
      stubGetCategories([
        CategoryFactory.expense(id: 'cat-food-7'),
      ]);
      when(() => mockDeleteCategory(any())).thenAnswer(
        (_) async => const Right<Failure, void>(null),
      );

      final result = await handler.handle(
        userId: userId,
        // Mixed case to prove the lookup lower-cases both sides.
        meta: const {'action': 'delete', 'name': 'food'},
        locale: locale,
      );

      expect(result, 'Category "food" deleted successfully!');
      final captured =
          verify(() => mockDeleteCategory(captureAny())).captured;
      expect(captured.first, 'cat-food-7');
    });

    test('returns not-found message when no category matches', () async {
      stubGetCategories([
        CategoryFactory.expense(id: 'cat-food-7'),
      ]);

      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'delete', 'name': 'Travel'},
        locale: locale,
      );

      expect(result, 'No category named "Travel" found.');
      verifyNever(() => mockDeleteCategory(any()));
    });

    test('surfaces delete failure as localized error string', () async {
      stubGetCategories([
        CategoryFactory.expense(id: 'cat-food-7'),
      ]);
      when(() => mockDeleteCategory(any())).thenAnswer(
        (_) async => const Left<Failure, void>(ServerFailure('locked')),
      );

      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'delete', 'name': 'Food'},
        locale: locale,
      );

      expect(result, 'Failed to delete category: locked');
    });

    test('surfaces load failure when listing categories fails', () async {
      when(
        () => mockGetCategories(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, List<CategoryEntity>>(
          ServerFailure('offline'),
        ),
      );

      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'delete', 'name': 'Food'},
        locale: locale,
      );

      expect(result, 'Failed to find category: offline');
      verifyNever(() => mockDeleteCategory(any()));
    });
  });

  test('unknown action returns dedicated message without touching use cases',
      () async {
    final result = await handler.handle(
      userId: userId,
      meta: const {'action': 'update'},
      locale: locale,
    );

    expect(result, 'Unknown category action.');
    verifyNever(() => mockCreateCategory(any()));
    verifyNever(() => mockDeleteCategory(any()));
    verifyNever(
      () => mockGetCategories(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    );
  });

  test('preflight returns null (no confirmation gate)', () async {
    final result = await handler.preflight(
      userId: userId,
      meta: const {'action': 'delete', 'name': 'Food'},
      locale: locale,
    );

    expect(result, isNull);
  });
}
