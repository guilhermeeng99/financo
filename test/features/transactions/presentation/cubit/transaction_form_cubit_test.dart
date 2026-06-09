import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/app/state/form_status.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockCreateTransactionUseCase mockCreate;
  late MockUpdateTransactionUseCase mockUpdate;
  late MockCreateTransferUseCase mockTransfer;
  late MockGetTransactionUseCase mockGet;

  const userId = 'user-1';

  setUpAll(registerTransactionFallbackValues);

  setUp(() {
    mockCreate = MockCreateTransactionUseCase();
    mockUpdate = MockUpdateTransactionUseCase();
    mockTransfer = MockCreateTransferUseCase();
    mockGet = MockGetTransactionUseCase();
    // Default counterpart-leg fetch (used when editing a transfer). The
    // income leg is the typical counterpart; individual tests override.
    when(() => mockGet(any())).thenAnswer(
      (_) async => Right(
        TransactionFactory.transfer().income,
      ),
    );
  });

  TransactionFormCubit buildCubit({TransactionEntity? existing}) =>
      TransactionFormCubit(
        createTransaction: mockCreate,
        updateTransaction: mockUpdate,
        createTransfer: mockTransfer,
        getTransaction: mockGet,
        userId: userId,
        existingTransaction: existing,
      );

  group('TransactionFormCubit', () {
    test('initial state defaults for new transaction', () {
      final cubit = buildCubit();
      final state = cubit.state;

      expect(state.userId, userId);
      expect(state.type, TransactionType.expense);
      expect(state.amount, 0);
      expect(state.description, '');
      expect(state.accountId, '');
      expect(state.categoryId, '');
      expect(state.notes, '');
      expect(state.status, FormStatus.initial);
      expect(state.isEditing, false);
      expect(state.existingId, isNull);
      expect(state.isTransfer, false);
      expect(state.destinationAccountId, '');

      addTearDown(cubit.close);
    });

    test('initial state populated from existing transaction', () {
      final existing = TransactionFactory.expense(
        id: 'tx-edit',
        description: 'Existing',
        amount: 99,
        notes: 'some note',
      );
      final cubit = buildCubit(existing: existing);
      final state = cubit.state;

      expect(state.existingId, 'tx-edit');
      expect(state.isEditing, true);
      expect(state.description, 'Existing');
      expect(state.amount, 99);
      expect(state.type, TransactionType.expense);
      expect(state.notes, 'some note');
      expect(state.accountId, 'acc-1');
      expect(state.categoryId, 'cat-1');

      addTearDown(cubit.close);
    });

    test('initial state detects transfer from existing transaction', () {
      final pair = TransactionFactory.transfer();
      final cubit = buildCubit(existing: pair.expense);
      final state = cubit.state;

      expect(state.isTransfer, true);
      expect(state.linkedTransactionId, pair.income.id);

      addTearDown(cubit.close);
    });

    group('transfer edit — counterpart resolution', () {
      test('tapping the expense leg keeps source, fills destination', () async {
        final pair = TransactionFactory.transfer(
          sourceAccountId: 'acc-src',
          destinationAccountId: 'acc-dst',
        );
        when(
          () => mockGet('tx-transfer-inc'),
        ).thenAnswer((_) async => Right(pair.income));

        final cubit = buildCubit(existing: pair.expense);

        // Synchronously the tapped (expense) leg is the source; the income
        // leg's account isn't known yet.
        expect(cubit.state.isTransfer, true);
        expect(cubit.state.accountId, 'acc-src');
        expect(cubit.state.destinationAccountId, '');
        expect(cubit.state.existingId, 'tx-transfer-exp');
        expect(cubit.state.linkedTransactionId, 'tx-transfer-inc');

        // The async counterpart fetch fills the destination account.
        await pumpEventQueue();
        expect(cubit.state.destinationAccountId, 'acc-dst');
        addTearDown(cubit.close);
      });

      test('tapping the income leg fills source, keeps destination', () async {
        final pair = TransactionFactory.transfer(
          sourceAccountId: 'acc-src',
          destinationAccountId: 'acc-dst',
        );
        when(
          () => mockGet('tx-transfer-exp'),
        ).thenAnswer((_) async => Right(pair.expense));

        final cubit = buildCubit(existing: pair.income);

        // Tapping the income leg: destination is known up front, the
        // source (expense leg) account is pending. `existingId` is still
        // normalized to the expense leg so submit updates the right rows.
        expect(cubit.state.isTransfer, true);
        expect(cubit.state.destinationAccountId, 'acc-dst');
        expect(cubit.state.accountId, '');
        expect(cubit.state.existingId, 'tx-transfer-exp');
        expect(cubit.state.linkedTransactionId, 'tx-transfer-inc');

        await pumpEventQueue();
        expect(cubit.state.accountId, 'acc-src');
        addTearDown(cubit.close);
      });

      test(
        'counterpart fetch failure leaves the unknown account empty',
        () async {
          final pair = TransactionFactory.transfer();
          when(
            () => mockGet(any()),
          ).thenAnswer((_) async => const Left(ServerFailure('offline')));

          final cubit = buildCubit(existing: pair.income);
          await pumpEventQueue();

          // Source stays empty so the form is invalid rather than guessing.
          expect(cubit.state.accountId, '');
          expect(cubit.state.isValid, false);
          addTearDown(cubit.close);
        },
      );
    });

    group('field updates', () {
      blocTest<TransactionFormCubit, TransactionFormState>(
        'updateType changes type',
        build: buildCubit,
        act: (cubit) => cubit.updateType(TransactionType.income),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.type,
            'type',
            TransactionType.income,
          ),
        ],
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'updateAmount parses string to double',
        build: buildCubit,
        act: (cubit) => cubit.updateAmount('42.5'),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.amount,
            'amount',
            42.5,
          ),
        ],
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'updateAmount defaults to 0 for invalid string',
        build: buildCubit,
        act: (cubit) => cubit.updateAmount('abc'),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.amount,
            'amount',
            0,
          ),
        ],
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'updateDescription changes description',
        build: buildCubit,
        act: (cubit) => cubit.updateDescription('Coffee'),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.description,
            'description',
            'Coffee',
          ),
        ],
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'updateDate changes date',
        build: buildCubit,
        act: (cubit) => cubit.updateDate(DateTime(2024, 6, 15)),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.date,
            'date',
            DateTime(2024, 6, 15),
          ),
        ],
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'updateAccountId changes accountId',
        build: buildCubit,
        act: (cubit) => cubit.updateAccountId('acc-2'),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.accountId,
            'accountId',
            'acc-2',
          ),
        ],
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'updateCategoryId changes categoryId',
        build: buildCubit,
        act: (cubit) => cubit.updateCategoryId('cat-3'),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.categoryId,
            'categoryId',
            'cat-3',
          ),
        ],
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'updateDestinationAccountId changes destinationAccountId',
        build: buildCubit,
        act: (cubit) => cubit.updateDestinationAccountId('acc-3'),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.destinationAccountId,
            'destinationAccountId',
            'acc-3',
          ),
        ],
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'updateNotes changes notes',
        build: buildCubit,
        act: (cubit) => cubit.updateNotes('Weekly groceries'),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.notes,
            'notes',
            'Weekly groceries',
          ),
        ],
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'setTransferMode enables transfer mode',
        build: buildCubit,
        act: (cubit) => cubit.setTransferMode(enabled: true),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.isTransfer,
            'isTransfer',
            true,
          ),
        ],
      );
    });

    group('validation', () {
      test('isValid returns true with empty description (not required)', () {
        final cubit = buildCubit()
          ..updateAmount('100')
          ..updateAccountId('acc-1')
          ..updateCategoryId('cat-1')
          ..updateDate(DateTime(2024, 3, 15));

        expect(cubit.state.isValid, true);
        addTearDown(cubit.close);
      });

      test('isValid returns false when amount is 0', () {
        final cubit = buildCubit()
          ..updateAccountId('acc-1')
          ..updateCategoryId('cat-1')
          ..updateDate(DateTime(2024, 3, 15));

        expect(cubit.state.isValid, false);
        addTearDown(cubit.close);
      });

      test('isValid returns false when accountId is empty', () {
        final cubit = buildCubit()
          ..updateAmount('100')
          ..updateCategoryId('cat-1')
          ..updateDate(DateTime(2024, 3, 15));

        expect(cubit.state.isValid, false);
        addTearDown(cubit.close);
      });

      test('isValid returns false when categoryId is empty (non-transfer)', () {
        final cubit = buildCubit()
          ..updateAmount('100')
          ..updateAccountId('acc-1')
          ..updateDate(DateTime(2024, 3, 15));

        expect(cubit.state.isValid, false);
        addTearDown(cubit.close);
      });

      test('future date switches to pending and remains valid', () {
        final futureDate = DateTime.now().add(const Duration(days: 30));
        final cubit = buildCubit()
          ..updateAmount('100')
          ..updateAccountId('acc-1')
          ..updateCategoryId('cat-1')
          ..updateDate(futureDate);

        expect(
          cubit.state.settlementStatus,
          TransactionSettlementStatus.pending,
        );
        expect(cubit.state.isValid, true);
        addTearDown(cubit.close);
      });
    });

    group('transfer validation', () {
      test('isValid for transfer: true when all transfer fields set', () {
        final cubit = buildCubit()
          ..setTransferMode(enabled: true)
          ..updateAmount('500')
          ..updateAccountId('acc-1')
          ..updateDestinationAccountId('acc-2')
          ..updateDate(DateTime(2024, 3, 15));

        expect(cubit.state.isValid, true);
        addTearDown(cubit.close);
      });

      test('isValid for transfer: false when destination is empty', () {
        final cubit = buildCubit()
          ..setTransferMode(enabled: true)
          ..updateAmount('500')
          ..updateAccountId('acc-1')
          ..updateDate(DateTime(2024, 3, 15));

        expect(cubit.state.isValid, false);
        addTearDown(cubit.close);
      });

      test('isValid for transfer: false when source == destination', () {
        final cubit = buildCubit()
          ..setTransferMode(enabled: true)
          ..updateAmount('500')
          ..updateAccountId('acc-1')
          ..updateDestinationAccountId('acc-1')
          ..updateDate(DateTime(2024, 3, 15));

        expect(cubit.state.isValid, false);
        addTearDown(cubit.close);
      });

      test(
        'isValid for transfer: does not require categoryId',
        () {
          final cubit = buildCubit()
            ..setTransferMode(enabled: true)
            ..updateAmount('500')
            ..updateAccountId('acc-1')
            ..updateDestinationAccountId('acc-2')
            ..updateDate(DateTime(2024, 3, 15));

          // categoryId is empty, but transfer doesn't require it.
          expect(cubit.state.categoryId, '');
          expect(cubit.state.isValid, true);
          addTearDown(cubit.close);
        },
      );
    });

    group('submit', () {
      blocTest<TransactionFormCubit, TransactionFormState>(
        'does nothing when form is invalid',
        build: buildCubit,
        act: (cubit) async => cubit.submit(),
        expect: () => <TransactionFormState>[],
        verify: (_) {
          verifyNever(() => mockCreate(any()));
          verifyNever(() => mockUpdate(any()));
        },
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'creates transaction and emits submitting then success',
        setUp: () {
          when(
            () => mockCreate(any()),
          ).thenAnswer(
            (_) async => Right(TransactionFactory.expense(id: 'tx-saved')),
          );
        },
        build: buildCubit,
        seed: () => TransactionFormState(
          userId: userId,
          type: TransactionType.expense,
          amount: 100,
          description: 'Coffee',
          date: DateTime(2024, 3, 15),
          accountId: 'acc-1',
          categoryId: 'cat-1',
          notes: '',
          status: FormStatus.initial,
          isTransfer: false,
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          // The saved id is surfaced on success so callers can chain
          // follow-up work (e.g. linking a settled bill to the new tx).
          isA<TransactionFormState>()
              .having((s) => s.status, 'status', FormStatus.success)
              .having(
                (s) => s.savedTransactionId,
                'savedTransactionId',
                'tx-saved',
              ),
        ],
        verify: (_) {
          verify(() => mockCreate(any())).called(1);
          verifyNever(() => mockUpdate(any()));
        },
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'updates transaction when editing',
        setUp: () {
          when(
            () => mockUpdate(any()),
          ).thenAnswer(
            (_) async => Right(
              TransactionFactory.expense(description: 'Updated'),
            ),
          );
        },
        build: () => buildCubit(
          existing: TransactionFactory.expense(id: 'tx-edit'),
        ),
        seed: () => TransactionFormState(
          userId: userId,
          type: TransactionType.expense,
          amount: 100,
          description: 'Updated',
          date: DateTime(2024, 3, 15),
          accountId: 'acc-1',
          categoryId: 'cat-1',
          notes: '',
          status: FormStatus.initial,
          isTransfer: false,
          existingId: 'tx-edit',
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<TransactionFormState>().having(
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

      blocTest<TransactionFormCubit, TransactionFormState>(
        'creates transfer when isTransfer and not editing',
        setUp: () {
          when(
            () => mockTransfer(
              expense: any(named: 'expense'),
              income: any(named: 'income'),
            ),
          ).thenAnswer(
            (_) async {
              final pair = TransactionFactory.transfer();
              return Right([pair.expense, pair.income]);
            },
          );
        },
        build: buildCubit,
        seed: () => TransactionFormState(
          userId: userId,
          type: TransactionType.expense,
          amount: 500,
          description: 'Transfer',
          date: DateTime(2024, 3, 20),
          accountId: 'acc-1',
          categoryId: '',
          destinationAccountId: 'acc-2',
          notes: '',
          status: FormStatus.initial,
          isTransfer: true,
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<TransactionFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.success,
          ),
        ],
        verify: (_) {
          verify(
            () => mockTransfer(
              expense: any(named: 'expense'),
              income: any(named: 'income'),
            ),
          ).called(1);
          verifyNever(() => mockCreate(any()));
        },
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'emits failure status when create fails',
        setUp: () {
          when(
            () => mockCreate(any()),
          ).thenAnswer(
            (_) async => const Left(ServerFailure('Create failed')),
          );
        },
        build: buildCubit,
        seed: () => TransactionFormState(
          userId: userId,
          type: TransactionType.expense,
          amount: 100,
          description: 'Coffee',
          date: DateTime(2024, 3, 15),
          accountId: 'acc-1',
          categoryId: 'cat-1',
          notes: '',
          status: FormStatus.initial,
          isTransfer: false,
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<TransactionFormState>()
              .having((s) => s.status, 'status', FormStatus.failure)
              .having((s) => s.failure, 'failure', isA<ServerFailure>()),
        ],
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'emits failure status when transfer fails',
        setUp: () {
          when(
            () => mockTransfer(
              expense: any(named: 'expense'),
              income: any(named: 'income'),
            ),
          ).thenAnswer(
            (_) async => const Left(ServerFailure('Transfer failed')),
          );
        },
        build: buildCubit,
        seed: () => TransactionFormState(
          userId: userId,
          type: TransactionType.expense,
          amount: 500,
          description: 'Transfer',
          date: DateTime(2024, 3, 20),
          accountId: 'acc-1',
          categoryId: '',
          destinationAccountId: 'acc-2',
          notes: '',
          status: FormStatus.initial,
          isTransfer: true,
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<TransactionFormState>()
              .having((s) => s.status, 'status', FormStatus.failure)
              .having((s) => s.failure, 'failure', isA<ServerFailure>()),
        ],
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'editing a transfer updates both legs (expense + income)',
        setUp: () {
          when(
            () => mockUpdate(any()),
          ).thenAnswer(
            (_) async => Right(TransactionFactory.expense()),
          );
        },
        // No `existing` passed: the seeded state already carries the
        // normalized transfer, and we don't want the constructor's async
        // counterpart fetch emitting into this submit-focused test.
        build: buildCubit,
        seed: () => TransactionFormState(
          userId: userId,
          type: TransactionType.expense,
          amount: 500,
          description: 'Transfer',
          date: DateTime(2024, 3, 20),
          accountId: 'acc-1',
          categoryId: '',
          destinationAccountId: 'acc-2',
          notes: '',
          status: FormStatus.initial,
          isTransfer: true,
          existingId: 'tx-transfer-exp',
          linkedTransactionId: 'tx-transfer-inc',
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<TransactionFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.success,
          ),
        ],
        verify: (_) {
          // Both legs (source/expense + destination/income) are written.
          final updated = verify(
            () => mockUpdate(captureAny()),
          ).captured.cast<TransactionEntity>();
          expect(updated, hasLength(2));
          final expenseLeg = updated.firstWhere(
            (t) => t.type == TransactionType.expense,
          );
          final incomeLeg = updated.firstWhere(
            (t) => t.type == TransactionType.income,
          );
          expect(expenseLeg.id, 'tx-transfer-exp');
          expect(expenseLeg.accountId, 'acc-1');
          expect(expenseLeg.linkedTransactionId, 'tx-transfer-inc');
          expect(incomeLeg.id, 'tx-transfer-inc');
          expect(incomeLeg.accountId, 'acc-2');
          expect(incomeLeg.linkedTransactionId, 'tx-transfer-exp');
          verifyNever(
            () => mockTransfer(
              expense: any(named: 'expense'),
              income: any(named: 'income'),
            ),
          );
        },
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'editing a transfer fails fast when the expense leg update fails',
        setUp: () {
          when(() => mockUpdate(any())).thenAnswer(
            (_) async => const Left(ServerFailure('Update failed')),
          );
        },
        build: buildCubit,
        seed: () => TransactionFormState(
          userId: userId,
          type: TransactionType.expense,
          amount: 500,
          description: 'Transfer',
          date: DateTime(2024, 3, 20),
          accountId: 'acc-1',
          categoryId: '',
          destinationAccountId: 'acc-2',
          notes: '',
          status: FormStatus.initial,
          isTransfer: true,
          existingId: 'tx-transfer-exp',
          linkedTransactionId: 'tx-transfer-inc',
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<TransactionFormState>()
              .having((s) => s.status, 'status', FormStatus.failure)
              .having((s) => s.failure, 'failure', isA<ServerFailure>()),
        ],
        verify: (_) {
          // Income leg is never touched once the expense leg write fails.
          verify(() => mockUpdate(any())).called(1);
        },
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'submit(continueAfterSave: true) carries the flag into success',
        setUp: () {
          when(
            () => mockCreate(any()),
          ).thenAnswer(
            (_) async => Right(TransactionFactory.expense(id: 'tx-saved')),
          );
        },
        build: buildCubit,
        seed: () => TransactionFormState(
          userId: userId,
          type: TransactionType.expense,
          amount: 100,
          description: 'Coffee',
          date: DateTime(2024, 3, 15),
          accountId: 'acc-1',
          categoryId: 'cat-1',
          notes: '',
          status: FormStatus.initial,
          isTransfer: false,
        ),
        act: (cubit) async => cubit.submit(continueAfterSave: true),
        expect: () => [
          isA<TransactionFormState>()
              .having((s) => s.status, 'status', FormStatus.submitting)
              .having((s) => s.continueAfterSave, 'continueAfterSave', true),
          isA<TransactionFormState>()
              .having((s) => s.status, 'status', FormStatus.success)
              .having((s) => s.continueAfterSave, 'continueAfterSave', true)
              .having(
                (s) => s.savedTransactionId,
                'savedTransactionId',
                'tx-saved',
              ),
        ],
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'prepareForNext clears transient flags but keeps user input',
        build: buildCubit,
        seed: () => TransactionFormState(
          userId: userId,
          type: TransactionType.income,
          amount: 250,
          description: 'Salary',
          date: DateTime(2024, 4, 10),
          accountId: 'acc-1',
          categoryId: 'cat-1',
          notes: 'Recurring',
          status: FormStatus.success,
          isTransfer: false,
          savedTransactionId: 'tx-saved',
          continueAfterSave: true,
        ),
        act: (cubit) => cubit.prepareForNext(),
        expect: () => [
          isA<TransactionFormState>()
              // Input is preserved so the user can quickly edit the
              // delta for the next entry.
              .having((s) => s.amount, 'amount', 250)
              .having((s) => s.description, 'description', 'Salary')
              .having((s) => s.accountId, 'accountId', 'acc-1')
              .having((s) => s.categoryId, 'categoryId', 'cat-1')
              .having((s) => s.notes, 'notes', 'Recurring')
              .having((s) => s.type, 'type', TransactionType.income)
              // Transient post-submit flags reset so the next submit
              // can transition state and re-trigger the page listener.
              .having((s) => s.status, 'status', FormStatus.initial)
              .having(
                (s) => s.continueAfterSave,
                'continueAfterSave',
                false,
              )
              .having(
                (s) => s.savedTransactionId,
                'savedTransactionId',
                isNull,
              ),
        ],
      );

      blocTest<TransactionFormCubit, TransactionFormState>(
        'emits failure status when update fails',
        setUp: () {
          when(
            () => mockUpdate(any()),
          ).thenAnswer(
            (_) async => const Left(ServerFailure('Update failed')),
          );
        },
        build: () => buildCubit(
          existing: TransactionFactory.expense(id: 'tx-edit'),
        ),
        seed: () => TransactionFormState(
          userId: userId,
          type: TransactionType.expense,
          amount: 100,
          description: 'Updated',
          date: DateTime(2024, 3, 15),
          accountId: 'acc-1',
          categoryId: 'cat-1',
          notes: '',
          status: FormStatus.initial,
          isTransfer: false,
          existingId: 'tx-edit',
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<TransactionFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<TransactionFormState>()
              .having((s) => s.status, 'status', FormStatus.failure)
              .having((s) => s.failure, 'failure', isA<ServerFailure>()),
        ],
      );
    });

    group('date validation', () {
      test('future date becomes a valid pending transaction', () {
        final cubit = buildCubit()
          ..updateAmount('100')
          ..updateAccountId('acc-1')
          ..updateCategoryId('cat-1')
          ..updateDate(DateTime.now().add(const Duration(days: 2)));
        expect(
          cubit.state.settlementStatus,
          TransactionSettlementStatus.pending,
        );
        expect(cubit.state.isValid, isTrue);
        addTearDown(cubit.close);
      });

      test('paid transaction with future date is invalid', () {
        final futureDate = DateTime.now().add(const Duration(days: 2));
        final state = TransactionFormState(
          userId: userId,
          type: TransactionType.expense,
          amount: 100,
          description: '',
          date: futureDate,
          accountId: 'acc-1',
          categoryId: 'cat-1',
          notes: '',
          status: FormStatus.initial,
          isTransfer: false,
        );

        expect(state.isValid, isFalse);
      });

      test('today date is valid', () {
        final cubit = buildCubit()
          ..updateAmount('100')
          ..updateAccountId('acc-1')
          ..updateCategoryId('cat-1')
          ..updateDate(DateTime.now());
        expect(cubit.state.isValid, isTrue);
        addTearDown(cubit.close);
      });

      test('past date is valid', () {
        final cubit = buildCubit()
          ..updateAmount('100')
          ..updateAccountId('acc-1')
          ..updateCategoryId('cat-1')
          ..updateDate(DateTime(2024, 3, 15));
        expect(cubit.state.isValid, isTrue);
        addTearDown(cubit.close);
      });
    });

    group('amount validation', () {
      test('zero amount makes form invalid', () {
        final cubit = buildCubit()
          ..updateAmount('0')
          ..updateAccountId('acc-1')
          ..updateCategoryId('cat-1');
        expect(cubit.state.isValid, isFalse);
        addTearDown(cubit.close);
      });

      test('negative amount makes form invalid', () {
        final cubit = buildCubit()
          ..updateAmount('-10')
          ..updateAccountId('acc-1')
          ..updateCategoryId('cat-1');
        expect(cubit.state.isValid, isFalse);
        addTearDown(cubit.close);
      });
    });

    group('transfer-specific validation', () {
      test('same source and destination is invalid', () {
        final cubit = buildCubit()
          ..updateAmount('100')
          ..updateAccountId('acc-1')
          ..setTransferMode(enabled: true)
          ..updateDestinationAccountId('acc-1');
        expect(cubit.state.isValid, isFalse);
        addTearDown(cubit.close);
      });

      test('empty destination is invalid for transfer', () {
        final cubit = buildCubit()
          ..updateAmount('100')
          ..updateAccountId('acc-1')
          ..setTransferMode(enabled: true);
        expect(cubit.state.isValid, isFalse);
        addTearDown(cubit.close);
      });

      test('transfer does not require categoryId', () {
        final cubit = buildCubit()
          ..updateAmount('100')
          ..updateAccountId('acc-1')
          ..setTransferMode(enabled: true)
          ..updateDestinationAccountId('acc-2');
        expect(cubit.state.isValid, isTrue);
        addTearDown(cubit.close);
      });
    });
  });
}
