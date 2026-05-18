import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/cubit/account_form_cubit.dart';
import 'package:financo/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockCreateAccountUseCase mockCreate;
  late MockUpdateAccountUseCase mockUpdate;

  const userId = 'user-1';

  setUpAll(registerAccountFallbackValues);

  setUp(() {
    mockCreate = MockCreateAccountUseCase();
    mockUpdate = MockUpdateAccountUseCase();
  });

  AccountFormCubit buildCubit({AccountEntity? existing}) => AccountFormCubit(
    createAccount: mockCreate,
    updateAccount: mockUpdate,
    userId: userId,
    existingAccount: existing,
  );

  group('AccountFormCubit', () {
    group('initial state', () {
      test('creates with default values for new checking account', () {
        final cubit = buildCubit();
        final state = cubit.state;

        expect(state.userId, userId);
        expect(state.name, '');
        expect(state.type, AccountType.checking);
        expect(state.bank, BankType.nubank);
        expect(state.balance, 0);
        expect(state.status, FormStatus.initial);
        expect(state.isEditing, isFalse);
        expect(state.isValid, isFalse);

        addTearDown(cubit.close);
      });

      test('populates from existing account in edit mode', () {
        final existing = AccountFactory.checking(id: 'existing-1');
        final cubit = buildCubit(existing: existing);
        final state = cubit.state;

        expect(state.name, 'Nubank Checking');
        expect(state.type, AccountType.checking);
        expect(state.existingId, 'existing-1');
        expect(state.isEditing, isTrue);
        expect(state.isValid, isTrue);

        addTearDown(cubit.close);
      });

      test('populates credit card fields from existing', () {
        final existing = AccountFactory.creditCard(id: 'cc-1');
        final cubit = buildCubit(existing: existing);
        final state = cubit.state;

        expect(state.type, AccountType.creditCard);
        expect(state.creditLimit, 5000);
        expect(state.closingDay, 3);
        expect(state.dueDay, 10);
        expect(state.linkedAccountId, 'acc-checking-1');
        expect(state.isValid, isTrue);

        addTearDown(cubit.close);
      });
    });

    group('field updates', () {
      blocTest<AccountFormCubit, AccountFormState>(
        'updateName emits state with new name',
        build: buildCubit,
        act: (cubit) => cubit.updateName('Savings'),
        expect: () => [
          isA<AccountFormState>()
              .having((s) => s.name, 'name', 'Savings')
              .having((s) => s.isValid, 'isValid', isTrue),
        ],
      );

      blocTest<AccountFormCubit, AccountFormState>(
        'updateType emits state with new type',
        build: buildCubit,
        act: (cubit) => cubit.updateType(AccountType.creditCard),
        expect: () => [
          isA<AccountFormState>().having(
            (s) => s.type,
            'type',
            AccountType.creditCard,
          ),
        ],
      );

      test('canChangeType is true on create', () {
        final cubit = buildCubit();
        expect(cubit.state.canChangeType, isTrue);
        addTearDown(cubit.close);
      });

      test('canChangeType is true when editing a checking account', () {
        final cubit = buildCubit(existing: AccountFactory.checking());
        expect(cubit.state.canChangeType, isTrue);
        expect(cubit.state.originalType, AccountType.checking);
        addTearDown(cubit.close);
      });

      test('canChangeType is false when editing a credit card', () {
        final cubit = buildCubit(existing: AccountFactory.creditCard());
        expect(cubit.state.canChangeType, isFalse);
        expect(cubit.state.originalType, AccountType.creditCard);
        addTearDown(cubit.close);
      });

      blocTest<AccountFormCubit, AccountFormState>(
        'updateType allows checking → investment on edit',
        build: () => buildCubit(existing: AccountFactory.checking()),
        act: (cubit) => cubit.updateType(AccountType.investment),
        expect: () => [
          isA<AccountFormState>().having(
            (s) => s.type,
            'type',
            AccountType.investment,
          ),
        ],
      );

      blocTest<AccountFormCubit, AccountFormState>(
        'updateBalance parses string to double',
        build: buildCubit,
        act: (cubit) => cubit.updateBalance('1500.50'),
        expect: () => [
          isA<AccountFormState>().having((s) => s.balance, 'balance', 1500.50),
        ],
      );

      blocTest<AccountFormCubit, AccountFormState>(
        'updateBalance defaults to 0 for invalid input',
        build: buildCubit,
        act: (cubit) => cubit.updateBalance('abc'),
        expect: () => [
          isA<AccountFormState>().having((s) => s.balance, 'balance', 0),
        ],
      );

      blocTest<AccountFormCubit, AccountFormState>(
        'updateBalance accepts Brazilian negative decimal',
        // Regression: typing "-431,72" used to parse as null and silently
        // reset the balance to 0 — overdraft accounts couldn't be edited.
        build: buildCubit,
        act: (cubit) => cubit.updateBalance('-431,72'),
        expect: () => [
          isA<AccountFormState>().having(
            (s) => s.balance,
            'balance',
            closeTo(-431.72, 0.001),
          ),
        ],
      );

      blocTest<AccountFormCubit, AccountFormState>(
        'updateBank emits state with new bank',
        build: buildCubit,
        act: (cubit) => cubit.updateBank(BankType.others),
        expect: () => [
          isA<AccountFormState>().having(
            (s) => s.bank,
            'bank',
            BankType.others,
          ),
        ],
      );

      blocTest<AccountFormCubit, AccountFormState>(
        'updateCreditLimit parses string to double',
        build: buildCubit,
        act: (cubit) => cubit.updateCreditLimit('3000'),
        expect: () => [
          isA<AccountFormState>().having(
            (s) => s.creditLimit,
            'creditLimit',
            3000,
          ),
        ],
      );

      blocTest<AccountFormCubit, AccountFormState>(
        'updateClosingDay emits state with new day',
        build: buildCubit,
        act: (cubit) => cubit.updateClosingDay(15),
        expect: () => [
          isA<AccountFormState>().having((s) => s.closingDay, 'closingDay', 15),
        ],
      );

      blocTest<AccountFormCubit, AccountFormState>(
        'updateDueDay emits state with new day',
        build: buildCubit,
        act: (cubit) => cubit.updateDueDay(20),
        expect: () => [
          isA<AccountFormState>().having((s) => s.dueDay, 'dueDay', 20),
        ],
      );

      blocTest<AccountFormCubit, AccountFormState>(
        'updateLinkedAccountId emits state with new id',
        build: buildCubit,
        act: (cubit) => cubit.updateLinkedAccountId('acc-linked'),
        expect: () => [
          isA<AccountFormState>().having(
            (s) => s.linkedAccountId,
            'linkedAccountId',
            'acc-linked',
          ),
        ],
      );
    });

    group('validation', () {
      test('checking account is valid with name only', () {
        final cubit = buildCubit()..updateName('Test');
        expect(cubit.state.isValid, isTrue);
        addTearDown(cubit.close);
      });

      test('credit card is invalid without linkedAccountId', () {
        final cubit = buildCubit()
          ..updateName('CC')
          ..updateType(AccountType.creditCard);
        expect(cubit.state.isValid, isFalse);
        addTearDown(cubit.close);
      });

      test('credit card is valid with name and linkedAccountId', () {
        final cubit = buildCubit()
          ..updateName('CC')
          ..updateType(AccountType.creditCard)
          ..updateLinkedAccountId('acc-1');
        expect(cubit.state.isValid, isTrue);
        addTearDown(cubit.close);
      });
    });

    group('submit', () {
      blocTest<AccountFormCubit, AccountFormState>(
        'does nothing when name is empty (invalid)',
        build: buildCubit,
        act: (cubit) async => cubit.submit(),
        expect: () => <AccountFormState>[],
        verify: (_) {
          verifyNever(() => mockCreate(any()));
          verifyNever(() => mockUpdate(any()));
        },
      );

      blocTest<AccountFormCubit, AccountFormState>(
        'creates account when valid and not editing',
        setUp: () {
          when(
            () => mockCreate(any()),
          ).thenAnswer((_) async => Right(AccountFactory.checking()));
        },
        build: buildCubit,
        seed: () => AccountFormState.initial(userId: userId).copyWith(
          name: 'New Account',
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<AccountFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<AccountFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.success,
          ),
        ],
        verify: (_) {
          verify(() => mockCreate(any())).called(1);
          verifyNever(() => mockUpdate(any()));
        },
      );

      blocTest<AccountFormCubit, AccountFormState>(
        'updates account when valid and editing',
        setUp: () {
          when(
            () => mockUpdate(any()),
          ).thenAnswer((_) async => Right(AccountFactory.checking()));
        },
        build: () => buildCubit(
          existing: AccountFactory.checking(id: 'existing-1'),
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<AccountFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<AccountFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.success,
          ),
        ],
        verify: (_) {
          verify(() => mockUpdate(any())).called(1);
          verifyNever(() => mockCreate(any()));
        },
      );

      blocTest<AccountFormCubit, AccountFormState>(
        'emits failure status when create fails',
        setUp: () {
          when(() => mockCreate(any())).thenAnswer(
            (_) async => const Left(ServerFailure('Create failed')),
          );
        },
        build: buildCubit,
        seed: () => AccountFormState.initial(userId: userId).copyWith(
          name: 'New Account',
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<AccountFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<AccountFormState>()
              .having((s) => s.status, 'status', FormStatus.failure)
              .having((s) => s.failure, 'failure', isA<ServerFailure>()),
        ],
      );

      blocTest<AccountFormCubit, AccountFormState>(
        'strips credit card fields when submitting checking account',
        setUp: () {
          when(() => mockCreate(any())).thenAnswer(
            (_) async => Right(AccountFactory.checking()),
          );
        },
        build: buildCubit,
        seed: () => AccountFormState.initial(userId: userId).copyWith(
          name: 'Checking',
          type: AccountType.checking,
          creditLimit: 5000,
          closingDay: 5,
          dueDay: 15,
          linkedAccountId: 'acc-linked',
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<AccountFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<AccountFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.success,
          ),
        ],
        verify: (_) {
          final captured = verify(() => mockCreate(captureAny())).captured;
          final account = captured.first as AccountEntity;
          expect(account.creditLimit, isNull);
          expect(account.closingDay, isNull);
          expect(account.dueDay, isNull);
          expect(account.linkedAccountId, isNull);
        },
      );

      blocTest<AccountFormCubit, AccountFormState>(
        'includes credit card fields when submitting credit card account',
        setUp: () {
          when(() => mockCreate(any())).thenAnswer(
            (_) async => Right(AccountFactory.creditCard()),
          );
        },
        build: buildCubit,
        seed: () => AccountFormState.initial(userId: userId).copyWith(
          name: 'CC',
          type: AccountType.creditCard,
          creditLimit: 5000,
          closingDay: 5,
          dueDay: 15,
          linkedAccountId: 'acc-linked',
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<AccountFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<AccountFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.success,
          ),
        ],
        verify: (_) {
          final captured = verify(() => mockCreate(captureAny())).captured;
          final account = captured.first as AccountEntity;
          expect(account.creditLimit, 5000);
          expect(account.closingDay, 5);
          expect(account.dueDay, 15);
          expect(account.linkedAccountId, 'acc-linked');
        },
      );

      blocTest<AccountFormCubit, AccountFormState>(
        'emits failure status when update fails',
        setUp: () {
          when(() => mockUpdate(any())).thenAnswer(
            (_) async => const Left(ServerFailure('Update failed')),
          );
        },
        build: () => buildCubit(
          existing: AccountFactory.checking(id: 'existing-1'),
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<AccountFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<AccountFormState>()
              .having((s) => s.status, 'status', FormStatus.failure)
              .having((s) => s.failure, 'failure', isA<ServerFailure>()),
        ],
      );
    });

    group('defaults', () {
      test('closingDay defaults to 1', () {
        final cubit = buildCubit();
        expect(cubit.state.closingDay, 1);
        addTearDown(cubit.close);
      });

      test('dueDay defaults to 10', () {
        final cubit = buildCubit();
        expect(cubit.state.dueDay, 10);
        addTearDown(cubit.close);
      });

      test('bank defaults to nubank', () {
        final cubit = buildCubit();
        expect(cubit.state.bank, BankType.nubank);
        addTearDown(cubit.close);
      });

      test('balance defaults to 0', () {
        final cubit = buildCubit();
        expect(cubit.state.balance, 0);
        addTearDown(cubit.close);
      });
    });
  });
}
