import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/chat/domain/action_handlers/transaction_chat_action_handler.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetAccountsUseCase mockGetAccounts;
  late MockGetCategoriesUseCase mockGetCategories;
  late MockCreateTransactionUseCase mockCreateTransaction;
  late TransactionChatActionHandler handler;
  late AppLocale locale;

  const userId = 'user-1';

  setUpAll(() {
    registerAccountFallbackValues();
    registerCategoryFallbackValues();
    registerTransactionFallbackValues();
  });

  setUp(() {
    mockGetAccounts = MockGetAccountsUseCase();
    mockGetCategories = MockGetCategoriesUseCase();
    mockCreateTransaction = MockCreateTransactionUseCase();
    handler = TransactionChatActionHandler(
      getAccounts: mockGetAccounts,
      getCategories: mockGetCategories,
      createTransaction: mockCreateTransaction,
    );
    locale = AppLocale.en;
  });

  group('preflight', () {
    test('rejects when amount is zero', () async {
      final error = await handler.preflight(
        userId: userId,
        meta: const {'amount': 0, 'category': 'X', 'account': 'Y'},
        locale: locale,
      );
      expect(error, isNotNull);
    });

    test('rejects when category does not exist', () async {
      when(
        () => mockGetCategories(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, List<CategoryEntity>>([]),
      );
      final error = await handler.preflight(
        userId: userId,
        meta: const {'amount': 50, 'category': 'Unknown', 'account': 'Y'},
        locale: locale,
      );
      expect(error, contains('Unknown'));
    });

    test('passes when category and account both exist', () async {
      when(
        () => mockGetCategories(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, List<CategoryEntity>>([
          CategoryEntity(
            id: 'c-1',
            name: 'Food',
            icon: 58332,
            color: 4280391411,
            type: CategoryType.expense,
          ),
        ]),
      );
      when(
        () => mockGetAccounts(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => Right<Failure, List<AccountEntity>>(
          [AccountFactory.checking()],
        ),
      );
      final error = await handler.preflight(
        userId: userId,
        meta: const {
          'amount': 50,
          'category': 'Food',
          'account': 'Nubank Checking',
        },
        locale: locale,
      );
      expect(error, isNull);
    });
  });

  group('handle', () {
    test('substring-resolves partial account name', () async {
      when(
        () => mockGetCategories(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, List<CategoryEntity>>([
          CategoryEntity(
            id: 'cat-1',
            name: 'Mercado',
            icon: 58332,
            color: 4280391411,
            type: CategoryType.expense,
          ),
        ]),
      );
      when(
        () => mockGetAccounts(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => Right<Failure, List<AccountEntity>>(
          [
            AccountFactory.checking(id: 'acc-checking'),
            AccountFactory.creditCard(
              id: 'acc-target',
              name: 'Cartão Nubank Mila',
            ),
          ],
        ),
      );
      when(() => mockCreateTransaction(any())).thenAnswer(
        (_) async => Right<Failure, TransactionEntity>(
          TransactionEntity(
            id: 'tx-1',
            userId: userId,
            accountId: 'acc-target',
            categoryId: 'cat-1',
            type: TransactionType.expense,
            amount: 30,
            description: 'Test',
            date: DateTime(2026, 4, 21),
            createdAt: DateTime(2026, 4, 21),
            updatedAt: DateTime(2026, 4, 21),
          ),
        ),
      );

      await handler.handle(
        userId: userId,
        meta: const {
          'amount': 30.0,
          'category': 'Mercado',
          'account': 'Cartão Mila',
          'description': 'Test',
          'date': '2026-04-21',
        },
        locale: locale,
      );

      final captured =
          verify(() => mockCreateTransaction(captureAny())).captured;
      final tx = captured.first as TransactionEntity;
      expect(tx.accountId, 'acc-target');
    });

    test('refuses to create when ambiguous account match', () async {
      when(
        () => mockGetCategories(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, List<CategoryEntity>>([
          CategoryEntity(
            id: 'cat-1',
            name: 'Food',
            icon: 58332,
            color: 4280391411,
            type: CategoryType.expense,
          ),
        ]),
      );
      when(
        () => mockGetAccounts(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => Right<Failure, List<AccountEntity>>([
          AccountFactory.creditCard(id: 'a-1', name: 'Cartão Nubank Mila'),
          AccountFactory.creditCard(id: 'a-2', name: 'Cartão Nubank Gui'),
        ]),
      );
      await handler.handle(
        userId: userId,
        meta: const {
          'amount': 50.0,
          'category': 'Food',
          'account': 'Cartão Nubank',
          'description': 'Lunch',
        },
        locale: locale,
      );
      verifyNever(() => mockCreateTransaction(any()));
    });
  });
}
