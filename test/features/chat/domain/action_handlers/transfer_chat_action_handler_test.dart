import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/chat/domain/action_handlers/transfer_chat_action_handler.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetAccountsUseCase mockGetAccounts;
  late MockCreateTransferUseCase mockCreateTransfer;
  late TransferChatActionHandler handler;
  late AppLocale locale;

  const userId = 'user-1';

  // The expense/income legs are passed via named params to CreateTransferUseCase
  // with any()/captureAny(); mocktail needs a TransactionEntity fallback.
  setUpAll(() {
    registerFallbackValue(
      TransactionEntity(
        id: 'fallback',
        userId: 'fallback',
        accountId: 'fallback',
        categoryId: 'fallback',
        type: TransactionType.expense,
        amount: 1,
        description: 'fallback',
        date: DateTime(2024),
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
    );
  });

  // Two distinct accounts so the happy path can resolve both legs.
  final source = AccountFactory.checking(id: 'acc-source', name: 'Nubank Gui');
  final destination = AccountFactory.investment(
    id: 'acc-dest',
    name: 'XP Invest',
  );

  void stubAccounts(List<AccountEntity> accounts) {
    when(
      () => mockGetAccounts(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, List<AccountEntity>>(accounts),
    );
  }

  setUp(() {
    mockGetAccounts = MockGetAccountsUseCase();
    mockCreateTransfer = MockCreateTransferUseCase();
    handler = TransferChatActionHandler(
      getAccounts: mockGetAccounts,
      createTransfer: mockCreateTransfer,
    );
    locale = AppLocale.en;
  });

  group('handle — validation guards (no transfer created)', () {
    test('amount <= 0 returns invalid-amount and never creates a transfer',
        () async {
      final result = await handler.handle(
        userId: userId,
        meta: const {'amount': 0, 'from': 'Nubank Gui', 'to': 'XP Invest'},
        locale: locale,
      );

      expect(result, locale.translations.chat.handlers.invalidAmount);
      verifyNever(() => mockGetAccounts(
            userId: any(named: 'userId'),
            forceRefresh: any(named: 'forceRefresh'),
          ));
      verifyNever(
        () => mockCreateTransfer(
          expense: any(named: 'expense'),
          income: any(named: 'income'),
        ),
      );
    });

    test('missing amount returns invalid-amount and never creates a transfer',
        () async {
      final result = await handler.handle(
        userId: userId,
        meta: const {'from': 'Nubank Gui', 'to': 'XP Invest'},
        locale: locale,
      );

      expect(result, locale.translations.chat.handlers.invalidAmount);
      verifyNever(
        () => mockCreateTransfer(
          expense: any(named: 'expense'),
          income: any(named: 'income'),
        ),
      );
    });

    test('missing from/to returns accounts-required, no transfer', () async {
      final result = await handler.handle(
        userId: userId,
        meta: const {'amount': 100, 'from': '', 'to': 'XP Invest'},
        locale: locale,
      );

      expect(
        result,
        locale.translations.chat.handlers.transferAccountsRequired,
      );
      verifyNever(
        () => mockCreateTransfer(
          expense: any(named: 'expense'),
          income: any(named: 'income'),
        ),
      );
    });

    test('fewer than two accounts returns min-two-accounts, no transfer',
        () async {
      stubAccounts([source]);

      final result = await handler.handle(
        userId: userId,
        meta: const {'amount': 100, 'from': 'Nubank Gui', 'to': 'XP Invest'},
        locale: locale,
      );

      expect(
        result,
        locale.translations.chat.handlers.transferMinTwoAccounts,
      );
      verifyNever(
        () => mockCreateTransfer(
          expense: any(named: 'expense'),
          income: any(named: 'income'),
        ),
      );
    });

    test('unresolved source account returns resolver error, no transfer',
        () async {
      stubAccounts([source, destination]);

      final result = await handler.handle(
        userId: userId,
        meta: const {
          'amount': 100,
          'from': 'Nonexistent',
          'to': 'XP Invest',
        },
        locale: locale,
      );

      // Resolver surfaces a not-found message naming the unknown query.
      expect(result, contains('Nonexistent'));
      verifyNever(
        () => mockCreateTransfer(
          expense: any(named: 'expense'),
          income: any(named: 'income'),
        ),
      );
    });

    test('unresolved destination account returns resolver error, no transfer',
        () async {
      stubAccounts([source, destination]);

      final result = await handler.handle(
        userId: userId,
        meta: const {
          'amount': 100,
          'from': 'Nubank Gui',
          'to': 'Nonexistent',
        },
        locale: locale,
      );

      expect(result, contains('Nonexistent'));
      verifyNever(
        () => mockCreateTransfer(
          expense: any(named: 'expense'),
          income: any(named: 'income'),
        ),
      );
    });

    test('same source and destination returns source-dest-same, no transfer',
        () async {
      stubAccounts([source, destination]);

      final result = await handler.handle(
        userId: userId,
        meta: const {
          'amount': 100,
          'from': 'Nubank Gui',
          'to': 'Nubank Gui',
        },
        locale: locale,
      );

      expect(
        result,
        locale.translations.chat.handlers.transferSourceDestSame,
      );
      verifyNever(
        () => mockCreateTransfer(
          expense: any(named: 'expense'),
          income: any(named: 'income'),
        ),
      );
    });

    test('getAccounts failure returns load-accounts-failed, no transfer',
        () async {
      when(
        () => mockGetAccounts(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, List<AccountEntity>>(ServerFailure('boom')),
      );

      final result = await handler.handle(
        userId: userId,
        meta: const {'amount': 100, 'from': 'Nubank Gui', 'to': 'XP Invest'},
        locale: locale,
      );

      expect(
        result,
        locale.translations.chat.handlers.transactionLoadAccountsFailed,
      );
      verifyNever(
        () => mockCreateTransfer(
          expense: any(named: 'expense'),
          income: any(named: 'income'),
        ),
      );
    });
  });

  group('handle — happy path', () {
    test(
        'creates transfer with expense leg on source and income leg on '
        'destination, matching amounts', () async {
      stubAccounts([source, destination]);
      when(
        () => mockCreateTransfer(
          expense: any(named: 'expense'),
          income: any(named: 'income'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, List<TransactionEntity>>([]),
      );

      final result = await handler.handle(
        userId: userId,
        meta: const {
          'amount': 250.5,
          'from': 'Nubank Gui',
          'to': 'XP Invest',
          'description': 'Monthly savings',
        },
        locale: locale,
      );

      final captured = verify(
        () => mockCreateTransfer(
          expense: captureAny(named: 'expense'),
          income: captureAny(named: 'income'),
        ),
      ).captured;
      final expense = captured[0] as TransactionEntity;
      final income = captured[1] as TransactionEntity;

      expect(expense.type, TransactionType.expense);
      expect(expense.accountId, source.id);
      expect(expense.amount, 250.5);
      expect(expense.userId, userId);

      expect(income.type, TransactionType.income);
      expect(income.accountId, destination.id);
      expect(income.amount, 250.5);
      expect(income.userId, userId);

      // Both legs move the same amount — a transfer must net to zero.
      expect(expense.amount, income.amount);

      expect(result, contains('"Nubank Gui"'));
      expect(result, contains('"XP Invest"'));
    });

    test('createTransfer failure surfaces the failure message', () async {
      stubAccounts([source, destination]);
      when(
        () => mockCreateTransfer(
          expense: any(named: 'expense'),
          income: any(named: 'income'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, List<TransactionEntity>>(
          ServerFailure('write denied'),
        ),
      );

      final result = await handler.handle(
        userId: userId,
        meta: const {'amount': 100, 'from': 'Nubank Gui', 'to': 'XP Invest'},
        locale: locale,
      );

      expect(result, contains('write denied'));
    });
  });

  group('preflight — pre-submit validation', () {
    test('amount <= 0 returns invalid-amount without loading accounts',
        () async {
      final result = await handler.preflight(
        userId: userId,
        meta: const {'amount': 0, 'from': 'Nubank Gui', 'to': 'XP Invest'},
        locale: locale,
      );

      expect(result, locale.translations.chat.handlers.invalidAmount);
      verifyNever(() => mockGetAccounts(
            userId: any(named: 'userId'),
            forceRefresh: any(named: 'forceRefresh'),
          ));
    });

    test('valid resolvable transfer passes preflight (null)', () async {
      stubAccounts([source, destination]);

      final result = await handler.preflight(
        userId: userId,
        meta: const {'amount': 100, 'from': 'Nubank Gui', 'to': 'XP Invest'},
        locale: locale,
      );

      expect(result, isNull);
    });

    test('same source and destination fails preflight', () async {
      stubAccounts([source, destination]);

      final result = await handler.preflight(
        userId: userId,
        meta: const {
          'amount': 100,
          'from': 'Nubank Gui',
          'to': 'Nubank Gui',
        },
        locale: locale,
      );

      expect(
        result,
        locale.translations.chat.handlers.transferSourceDestSame,
      );
    });
  });
}
