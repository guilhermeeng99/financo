import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/presentation/cubit/account_statement_cubit.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetTransactionsUseCase mockGetTransactions;
  late MockGetTransactionUseCase mockGetTransaction;

  setUp(() {
    mockGetTransactions = MockGetTransactionsUseCase();
    mockGetTransaction = MockGetTransactionUseCase();
  });

  const accountId = 'acc-1';
  final account = AccountFactory.checking(id: accountId);

  AccountStatementCubit buildCubit() => AccountStatementCubit(
    getTransactions: mockGetTransactions,
    getTransaction: mockGetTransaction,
    accountId: accountId,
  );

  TransactionEntity makeTx({
    required TransactionType type,
    required double amount,
    DateTime? date,
    String? id,
    String? txAccountId,
    String? linkedTransactionId,
    String? categoryId,
  }) {
    return TransactionEntity(
      id: id ?? 'tx-${amount.toInt()}',
      userId: 'user-1',
      accountId: txAccountId ?? accountId,
      categoryId: categoryId ?? 'cat-1',
      type: type,
      amount: amount,
      description: 'Test',
      date: date ?? DateTime(2024, 3, 15),
      linkedTransactionId: linkedTransactionId,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
  }

  group('AccountStatementCubit', () {
    test('initial state is AccountStatementInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, isA<AccountStatementInitial>());
      addTearDown(cubit.close);
    });

    blocTest<AccountStatementCubit, AccountStatementState>(
      'emits [Loading, Loaded] with correct calculations',
      setUp: () {
        // All-time transactions
        when(
          () => mockGetTransactions(
            userId: 'user-1',
            accountId: accountId,
            forceRefresh: true,
          ),
        ).thenAnswer(
          (_) async => Right([
            makeTx(type: TransactionType.income, amount: 500),
            makeTx(type: TransactionType.expense, amount: 200),
          ]),
        );
        // Period transactions (March 2024)
        when(
          () => mockGetTransactions(
            userId: 'user-1',
            accountId: accountId,
            startDate: DateTime(2024, 3),
            endDate: DateTime(2024, 4),
            forceRefresh: true,
          ),
        ).thenAnswer(
          (_) async => Right([
            makeTx(
              type: TransactionType.income,
              amount: 300,
              date: DateTime(2024, 3, 10),
            ),
            makeTx(
              type: TransactionType.expense,
              amount: 100,
              date: DateTime(2024, 3, 20),
            ),
          ]),
        );
      },
      build: buildCubit,
      act: (cubit) async => cubit.load(account, 2024, 3),
      expect: () => [
        isA<AccountStatementLoading>(),
        isA<AccountStatementLoaded>()
            .having(
              (s) => s.runningBalance,
              'runningBalance',
              1300, // 1000 + 500 - 200
            )
            .having((s) => s.totalIncome, 'totalIncome', 300)
            .having((s) => s.totalExpenses, 'totalExpenses', 100)
            .having(
              (s) => s.result,
              'result',
              200, // 300 - 100
            )
            .having((s) => s.year, 'year', 2024)
            .having((s) => s.month, 'month', 3)
            .having(
              (s) => s.transactions.length,
              'transactions.length',
              2,
            ),
      ],
    );

    blocTest<AccountStatementCubit, AccountStatementState>(
      'transactions are sorted by date descending',
      setUp: () {
        when(
          () => mockGetTransactions(
            userId: 'user-1',
            accountId: accountId,
            forceRefresh: true,
          ),
        ).thenAnswer((_) async => const Right([]));
        when(
          () => mockGetTransactions(
            userId: 'user-1',
            accountId: accountId,
            startDate: DateTime(2024, 3),
            endDate: DateTime(2024, 4),
            forceRefresh: true,
          ),
        ).thenAnswer(
          (_) async => Right([
            makeTx(
              type: TransactionType.expense,
              amount: 50,
              date: DateTime(2024, 3, 5),
            ),
            makeTx(
              type: TransactionType.expense,
              amount: 100,
              date: DateTime(2024, 3, 25),
            ),
          ]),
        );
      },
      build: buildCubit,
      act: (cubit) async => cubit.load(account, 2024, 3),
      expect: () => [
        isA<AccountStatementLoading>(),
        isA<AccountStatementLoaded>().having(
          (s) => s.transactions.first.date.isAfter(s.transactions.last.date),
          'sorted desc',
          isTrue,
        ),
      ],
    );

    blocTest<AccountStatementCubit, AccountStatementState>(
      'emits Loaded with zero totals when no transactions',
      setUp: () {
        when(
          () => mockGetTransactions(
            userId: 'user-1',
            accountId: accountId,
            forceRefresh: true,
          ),
        ).thenAnswer((_) async => const Right([]));
        when(
          () => mockGetTransactions(
            userId: 'user-1',
            accountId: accountId,
            startDate: DateTime(2024, 3),
            endDate: DateTime(2024, 4),
            forceRefresh: true,
          ),
        ).thenAnswer((_) async => const Right([]));
      },
      build: buildCubit,
      act: (cubit) async => cubit.load(account, 2024, 3),
      expect: () => [
        isA<AccountStatementLoading>(),
        isA<AccountStatementLoaded>()
            .having((s) => s.runningBalance, 'runningBalance', 1000)
            .having((s) => s.totalIncome, 'totalIncome', 0)
            .having((s) => s.totalExpenses, 'totalExpenses', 0)
            .having((s) => s.transactions, 'transactions', isEmpty),
      ],
    );

    blocTest<AccountStatementCubit, AccountStatementState>(
      'emits Error when all-time fetch fails',
      setUp: () {
        when(
          () => mockGetTransactions(
            userId: 'user-1',
            accountId: accountId,
            forceRefresh: true,
          ),
        ).thenAnswer(
          (_) async => const Left(ServerFailure('Failed')),
        );
        when(
          () => mockGetTransactions(
            userId: 'user-1',
            accountId: accountId,
            startDate: DateTime(2024, 3),
            endDate: DateTime(2024, 4),
            forceRefresh: true,
          ),
        ).thenAnswer((_) async => const Right([]));
      },
      build: buildCubit,
      act: (cubit) async => cubit.load(account, 2024, 3),
      expect: () => [
        isA<AccountStatementLoading>(),
        isA<AccountStatementError>(),
      ],
    );

    blocTest<AccountStatementCubit, AccountStatementState>(
      'resolves transferCounterpartAccountIds for transfer transactions',
      setUp: () {
        when(
          () => mockGetTransactions(
            userId: 'user-1',
            accountId: accountId,
            forceRefresh: true,
          ),
        ).thenAnswer((_) async => const Right([]));
        when(
          () => mockGetTransactions(
            userId: 'user-1',
            accountId: accountId,
            startDate: DateTime(2024, 3),
            endDate: DateTime(2024, 4),
            forceRefresh: true,
          ),
        ).thenAnswer(
          (_) async => Right([
            // Transfer: this account sent 100 to acc-2.
            makeTx(
              id: 'tx-out',
              type: TransactionType.expense,
              amount: 100,
              categoryId: '',
              linkedTransactionId: 'tx-in',
            ),
            // Non-transfer expense — should not trigger any lookup.
            makeTx(
              id: 'tx-reg',
              type: TransactionType.expense,
              amount: 50,
            ),
          ]),
        );
        when(() => mockGetTransaction('tx-in')).thenAnswer(
          (_) async => Right(
            makeTx(
              id: 'tx-in',
              type: TransactionType.income,
              amount: 100,
              txAccountId: 'acc-2',
              categoryId: '',
              linkedTransactionId: 'tx-out',
            ),
          ),
        );
      },
      build: buildCubit,
      act: (cubit) async => cubit.load(account, 2024, 3),
      expect: () => [
        isA<AccountStatementLoading>(),
        isA<AccountStatementLoaded>().having(
          (s) => s.transferCounterpartAccountIds,
          'transferCounterpartAccountIds',
          {'tx-out': 'acc-2'},
        ),
      ],
      verify: (_) {
        verify(() => mockGetTransaction('tx-in')).called(1);
        verifyNoMoreInteractions(mockGetTransaction);
      },
    );

    blocTest<AccountStatementCubit, AccountStatementState>(
      'omits transferCounterpartAccountIds entry when linked fetch fails',
      setUp: () {
        when(
          () => mockGetTransactions(
            userId: 'user-1',
            accountId: accountId,
            forceRefresh: true,
          ),
        ).thenAnswer((_) async => const Right([]));
        when(
          () => mockGetTransactions(
            userId: 'user-1',
            accountId: accountId,
            startDate: DateTime(2024, 3),
            endDate: DateTime(2024, 4),
            forceRefresh: true,
          ),
        ).thenAnswer(
          (_) async => Right([
            makeTx(
              id: 'tx-out',
              type: TransactionType.expense,
              amount: 100,
              categoryId: '',
              linkedTransactionId: 'tx-in',
            ),
          ]),
        );
        when(() => mockGetTransaction('tx-in')).thenAnswer(
          (_) async => const Left(ServerFailure('not found')),
        );
      },
      build: buildCubit,
      act: (cubit) async => cubit.load(account, 2024, 3),
      expect: () => [
        isA<AccountStatementLoading>(),
        isA<AccountStatementLoaded>().having(
          (s) => s.transferCounterpartAccountIds,
          'transferCounterpartAccountIds',
          isEmpty,
        ),
      ],
    );

    blocTest<AccountStatementCubit, AccountStatementState>(
      'emits Error when period fetch fails',
      setUp: () {
        when(
          () => mockGetTransactions(
            userId: 'user-1',
            accountId: accountId,
            forceRefresh: true,
          ),
        ).thenAnswer((_) async => const Right([]));
        when(
          () => mockGetTransactions(
            userId: 'user-1',
            accountId: accountId,
            startDate: DateTime(2024, 3),
            endDate: DateTime(2024, 4),
            forceRefresh: true,
          ),
        ).thenAnswer(
          (_) async => const Left(ServerFailure('Failed')),
        );
      },
      build: buildCubit,
      act: (cubit) async => cubit.load(account, 2024, 3),
      expect: () => [
        isA<AccountStatementLoading>(),
        isA<AccountStatementError>(),
      ],
    );
  });
}
