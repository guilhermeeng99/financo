import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/data/models/account_model.dart';
import 'package:financo/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late AccountRepositoryImpl repository;
  late MockAccountRemoteDataSource mockRemote;
  late MockAccountsDao mockDao;

  setUpAll(registerAccountFallbackValues);

  setUp(() {
    mockRemote = MockAccountRemoteDataSource();
    mockDao = MockAccountsDao();
    repository = AccountRepositoryImpl(
      remoteDataSource: mockRemote,
      accountsDao: mockDao,
    );
  });

  const userId = 'user-1';

  group('getAccounts', () {
    test('should return local cache when forceRefresh is false', () async {
      final accounts = AccountFactory.list();
      when(() => mockDao.getAccounts(userId)).thenAnswer((_) async => accounts);

      final result = await repository.getAccounts(userId: userId);

      expect(result, Right<Failure, List<AccountEntity>>(accounts));
      verify(() => mockDao.getAccounts(userId)).called(1);
      verifyNever(
        () => mockRemote.getAccounts(userId: any(named: 'userId')),
      );
    });

    test(
      'should fetch from remote and replace cache when forceRefresh',
      () async {
        final remoteAccounts = [
          AccountModel.fromEntity(AccountFactory.checking()),
        ];
        final localAccounts = [AccountFactory.checking()];

        when(
          () => mockRemote.getAccounts(userId: userId),
        ).thenAnswer((_) async => remoteAccounts);
        when(() => mockDao.deleteAllAccounts()).thenAnswer((_) async {});
        when(() => mockDao.insertAllAccounts(any())).thenAnswer((_) async {});
        when(
          () => mockDao.getAccounts(userId),
        ).thenAnswer((_) async => localAccounts);

        final result = await repository.getAccounts(
          userId: userId,
          forceRefresh: true,
        );

        expect(result, Right<Failure, List<AccountEntity>>(localAccounts));
        verify(() => mockRemote.getAccounts(userId: userId)).called(1);
        verify(() => mockDao.deleteAllAccounts()).called(1);
        verify(() => mockDao.insertAllAccounts(remoteAccounts)).called(1);
      },
    );

    test(
      'should clear cache and not insert when remote returns empty',
      () async {
        when(
          () => mockRemote.getAccounts(userId: userId),
        ).thenAnswer((_) async => []);
        when(() => mockDao.deleteAllAccounts()).thenAnswer((_) async {});
        when(() => mockDao.getAccounts(userId)).thenAnswer((_) async => []);

        final result = await repository.getAccounts(
          userId: userId,
          forceRefresh: true,
        );

        expect(result.isRight(), isTrue);
        result.fold((_) {}, (accounts) => expect(accounts, isEmpty));
        verify(() => mockDao.deleteAllAccounts()).called(1);
        verifyNever(() => mockDao.insertAllAccounts(any()));
      },
    );

    test('should return ServerFailure when remote throws', () async {
      when(
        () => mockRemote.getAccounts(userId: userId),
      ).thenThrow(const ServerException());
      when(() => mockDao.getAccounts(userId)).thenAnswer((_) async => []);

      final result = await repository.getAccounts(
        userId: userId,
        forceRefresh: true,
      );

      expect(result, isA<Left<Failure, List<AccountEntity>>>());
    });
  });

  group('getAccount', () {
    const accountId = 'acc-1';

    test('should return from local cache if found', () async {
      final account = AccountFactory.checking(id: accountId);
      when(
        () => mockDao.getAccountById(accountId),
      ).thenAnswer((_) async => account);

      final result = await repository.getAccount(accountId);

      expect(result, Right<Failure, AccountEntity>(account));
      verifyNever(() => mockRemote.getAccount(any()));
    });

    test('should fetch from remote when not in local cache', () async {
      final model = AccountModel.fromEntity(
        AccountFactory.checking(id: accountId),
      );
      when(
        () => mockDao.getAccountById(accountId),
      ).thenAnswer((_) async => null);
      when(
        () => mockRemote.getAccount(accountId),
      ).thenAnswer((_) async => model);
      when(() => mockDao.upsertAccount(any())).thenAnswer((_) async {});

      final result = await repository.getAccount(accountId);

      expect(result.isRight(), isTrue);
      verify(() => mockRemote.getAccount(accountId)).called(1);
      verify(() => mockDao.upsertAccount(model)).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(
        () => mockDao.getAccountById(accountId),
      ).thenAnswer((_) async => null);
      when(
        () => mockRemote.getAccount(accountId),
      ).thenThrow(const ServerException());

      final result = await repository.getAccount(accountId);

      expect(result, isA<Left<Failure, AccountEntity>>());
    });
  });

  group('createAccount', () {
    test('should create remotely and upsert locally', () async {
      final account = AccountFactory.checking();
      final model = AccountModel.fromEntity(account);

      when(
        () => mockRemote.createAccount(any()),
      ).thenAnswer((_) async => model);
      when(() => mockDao.upsertAccount(any())).thenAnswer((_) async {});

      final result = await repository.createAccount(account);

      expect(result.isRight(), isTrue);
      verify(() => mockRemote.createAccount(any())).called(1);
      verify(() => mockDao.upsertAccount(model)).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(
        () => mockRemote.createAccount(any()),
      ).thenThrow(const ServerException('Failed to create account.'));

      final result = await repository.createAccount(AccountFactory.checking());

      expect(result, isA<Left<Failure, AccountEntity>>());
      verifyNever(() => mockDao.upsertAccount(any()));
    });
  });

  group('updateAccount', () {
    test('should update remotely and upsert locally', () async {
      final account = AccountFactory.checking(name: 'Updated');
      final model = AccountModel.fromEntity(account);

      when(
        () => mockRemote.updateAccount(any()),
      ).thenAnswer((_) async => model);
      when(() => mockDao.upsertAccount(any())).thenAnswer((_) async {});

      final result = await repository.updateAccount(account);

      expect(result.isRight(), isTrue);
      verify(() => mockRemote.updateAccount(any())).called(1);
      verify(() => mockDao.upsertAccount(model)).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(
        () => mockRemote.updateAccount(any()),
      ).thenThrow(const ServerException('Failed to update account.'));

      final result = await repository.updateAccount(AccountFactory.checking());

      expect(result, isA<Left<Failure, AccountEntity>>());
      verifyNever(() => mockDao.upsertAccount(any()));
    });
  });

  group('deleteAccount', () {
    const accountId = 'acc-1';

    test('should delete remotely and locally', () async {
      when(() => mockRemote.deleteAccount(any())).thenAnswer((_) async {});
      when(() => mockDao.deleteAccount(any())).thenAnswer((_) async {});

      final result = await repository.deleteAccount(accountId);

      expect(result, const Right<Failure, void>(null));
      verify(() => mockRemote.deleteAccount(accountId)).called(1);
      verify(() => mockDao.deleteAccount(accountId)).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(
        () => mockRemote.deleteAccount(any()),
      ).thenThrow(const ServerException('Failed to delete account.'));

      final result = await repository.deleteAccount(accountId);

      expect(result, isA<Left<Failure, void>>());
      verifyNever(() => mockDao.deleteAccount(any()));
    });
  });
}
