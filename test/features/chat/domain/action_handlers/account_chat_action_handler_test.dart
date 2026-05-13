import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/chat/domain/action_handlers/account_chat_action_handler.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockCreateAccountUseCase mockCreateAccount;
  late MockGetAccountsUseCase mockGetAccounts;
  late MockDeleteAccountUseCase mockDeleteAccount;
  late AccountChatActionHandler handler;
  late AppLocale locale;

  const userId = 'user-1';

  setUpAll(registerAccountFallbackValues);

  setUp(() {
    mockCreateAccount = MockCreateAccountUseCase();
    mockGetAccounts = MockGetAccountsUseCase();
    mockDeleteAccount = MockDeleteAccountUseCase();
    handler = AccountChatActionHandler(
      createAccount: mockCreateAccount,
      getAccounts: mockGetAccounts,
      deleteAccount: mockDeleteAccount,
    );
    locale = AppLocale.en;
  });

  test('create returns success message', () async {
    when(() => mockCreateAccount(any())).thenAnswer(
      (_) async => Right<Failure, AccountEntity>(
        AccountFactory.checking(name: 'Nubank Gui'),
      ),
    );
    final result = await handler.handle(
      userId: userId,
      meta: const {
        'action': 'create',
        'name': 'Nubank Gui',
        'type': 'checking',
        'bank': 'nubank',
        'balance': 1000,
      },
      locale: locale,
    );
    expect(result, contains('Nubank Gui'));
  });

  test('create credit card resolves linked account by name', () async {
    when(
      () => mockGetAccounts(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, List<AccountEntity>>(
        [AccountFactory.checking(name: 'Nubank Gui')],
      ),
    );
    when(() => mockCreateAccount(any())).thenAnswer(
      (_) async => Right<Failure, AccountEntity>(
        AccountFactory.creditCard(name: 'Nubank CC'),
      ),
    );

    await handler.handle(
      userId: userId,
      meta: const {
        'action': 'create',
        'name': 'Nubank CC',
        'type': 'creditCard',
        'bank': 'nubank',
        'balance': 0,
        'creditLimit': 5000.0,
        'closingDay': 5,
        'dueDay': 15,
        'linkedAccountName': 'Nubank Gui',
      },
      locale: locale,
    );

    final captured = verify(() => mockCreateAccount(captureAny())).captured;
    final account = captured.first as AccountEntity;
    expect(account.type, AccountType.creditCard);
    expect(account.creditLimit, 5000.0);
    expect(account.closingDay, 5);
    expect(account.dueDay, 15);
    expect(account.linkedAccountId, 'acc-checking-1');
  });

  test('delete returns success when account exists', () async {
    when(
      () => mockGetAccounts(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, List<AccountEntity>>(
        [AccountFactory.checking(name: 'Nubank Gui')],
      ),
    );
    when(() => mockDeleteAccount(any())).thenAnswer(
      (_) async => const Right<Failure, void>(null),
    );
    final result = await handler.handle(
      userId: userId,
      meta: const {'action': 'delete', 'name': 'Nubank Gui'},
      locale: locale,
    );
    expect(result, contains('Nubank Gui'));
  });

  test('delete returns not-found when no match', () async {
    when(
      () => mockGetAccounts(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, List<AccountEntity>>(
        [AccountFactory.checking(name: 'Other')],
      ),
    );
    final result = await handler.handle(
      userId: userId,
      meta: const {'action': 'delete', 'name': 'Nonexistent'},
      locale: locale,
    );
    expect(result, contains('Nonexistent'));
  });

  test('unknown action returns dedicated message', () async {
    final result = await handler.handle(
      userId: userId,
      meta: const {'action': 'update'},
      locale: locale,
    );
    expect(result, isNotEmpty);
  });

  test('createAccount failure surfaces error string', () async {
    when(() => mockCreateAccount(any())).thenAnswer(
      (_) async =>
          const Left<Failure, AccountEntity>(ServerFailure('DB error')),
    );
    final result = await handler.handle(
      userId: userId,
      meta: const {
        'action': 'create',
        'name': 'Test',
        'type': 'checking',
      },
      locale: locale,
    );
    expect(result, contains('DB error'));
  });
}
