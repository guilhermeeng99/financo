import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetAccountsUseCase mockGetAccounts;

  setUp(() {
    mockGetAccounts = MockGetAccountsUseCase();
  });

  const userId = 'user-1';

  AccountsCubit buildCubit() => AccountsCubit(
    getAccounts: mockGetAccounts,
    userId: userId,
  );

  group('AccountsCubit', () {
    test('initial state is AccountsInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, isA<AccountsInitial>());
      addTearDown(cubit.close);
    });

    blocTest<AccountsCubit, AccountsState>(
      'emits [Loading, Loaded] when loadAccounts succeeds',
      setUp: () {
        when(
          () => mockGetAccounts(userId: userId),
        ).thenAnswer((_) async => Right(AccountFactory.list()));
      },
      build: buildCubit,
      act: (cubit) async => cubit.loadAccounts(),
      expect: () => [
        isA<AccountsLoading>(),
        isA<AccountsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockGetAccounts(userId: userId)).called(1);
      },
    );

    blocTest<AccountsCubit, AccountsState>(
      'emits [Loading, Error] when loadAccounts fails',
      setUp: () {
        when(
          () => mockGetAccounts(userId: userId),
        ).thenAnswer((_) async => const Left(ServerFailure()));
      },
      build: buildCubit,
      act: (cubit) async => cubit.loadAccounts(),
      expect: () => [
        isA<AccountsLoading>(),
        isA<AccountsError>(),
      ],
    );

    blocTest<AccountsCubit, AccountsState>(
      'does not reload when already loaded and forceRefresh is false',
      setUp: () {
        when(
          () => mockGetAccounts(userId: userId),
        ).thenAnswer((_) async => Right(AccountFactory.list()));
      },
      build: buildCubit,
      seed: () => AccountsLoaded(AccountFactory.list()),
      act: (cubit) async => cubit.loadAccounts(),
      expect: () => <AccountsState>[],
      verify: (_) {
        verifyNever(
          () => mockGetAccounts(userId: any(named: 'userId')),
        );
      },
    );

    blocTest<AccountsCubit, AccountsState>(
      'reloads when already loaded and forceRefresh is true',
      setUp: () {
        when(
          () => mockGetAccounts(userId: userId, forceRefresh: true),
        ).thenAnswer((_) async => Right(AccountFactory.list()));
      },
      build: buildCubit,
      seed: () => AccountsLoaded(AccountFactory.list()),
      act: (cubit) async => cubit.loadAccounts(forceRefresh: true),
      expect: () => [
        isA<AccountsLoading>(),
        isA<AccountsLoaded>(),
      ],
    );

    blocTest<AccountsCubit, AccountsState>(
      'emits Loaded with empty list when no accounts exist',
      setUp: () {
        when(
          () => mockGetAccounts(userId: userId),
        ).thenAnswer((_) async => const Right([]));
      },
      build: buildCubit,
      act: (cubit) async => cubit.loadAccounts(),
      expect: () => [
        isA<AccountsLoading>(),
        isA<AccountsLoaded>().having(
          (s) => s.accounts,
          'accounts',
          isEmpty,
        ),
      ],
    );
  });
}
