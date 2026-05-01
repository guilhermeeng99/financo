import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/import_accounts_csv_usecase.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetAccountsUseCase mockGetAccounts;
  late MockImportAccountsCsvUseCase mockImportAccountsCsv;

  setUp(() {
    mockGetAccounts = MockGetAccountsUseCase();
    mockImportAccountsCsv = MockImportAccountsCsvUseCase();
  });

  const userId = 'user-1';

  AccountsCubit buildCubit() => AccountsCubit(
    getAccounts: mockGetAccounts,
    importAccountsCsv: mockImportAccountsCsv,
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
      'silently re-reads cache when already loaded and forceRefresh is false',
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
        verify(() => mockGetAccounts(userId: userId)).called(1);
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

    blocTest<AccountsCubit, AccountsState>(
      'emits [Loading, AccountsImported] when confirmImport succeeds',
      setUp: () {
        when(
          () => mockImportAccountsCsv.importItems(
            items: any(named: 'items'),
            userId: userId,
            duplicateCount: any(named: 'duplicateCount'),
          ),
        ).thenAnswer(
          (_) async => const Right(
            AccountImportResult(importedCount: 2, duplicateCount: 1),
          ),
        );
        when(
          () => mockGetAccounts(userId: userId, forceRefresh: true),
        ).thenAnswer((_) async => Right(AccountFactory.list()));
      },
      build: buildCubit,
      act: (cubit) async => cubit.confirmImport(
        items: const [
          AccountImportPreviewItem(
            name: 'Nubank Gui',
            type: AccountType.checking,
            bank: BankType.nubank,
            initialBalance: 0,
          ),
        ],
        duplicateCount: 1,
      ),
      expect: () => [
        isA<AccountsLoading>(),
        isA<AccountsImported>()
            .having((s) => s.importedCount, 'importedCount', 2)
            .having((s) => s.duplicateCount, 'duplicateCount', 1),
      ],
    );
  });
}
