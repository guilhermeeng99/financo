import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/data/models/transaction_model.dart';
import 'package:financo/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late TransactionRepositoryImpl repository;
  late MockTransactionRemoteDataSource mockRemote;
  late MockTransactionsDao mockDao;

  setUpAll(registerTransactionFallbackValues);

  setUp(() {
    mockRemote = MockTransactionRemoteDataSource();
    mockDao = MockTransactionsDao();
    repository = TransactionRepositoryImpl(
      remoteDataSource: mockRemote,
      transactionsDao: mockDao,
    );
  });

  const userId = 'user-1';

  group('getTransactions', () {
    test('should return local cache when forceRefresh is false', () async {
      final transactions = TransactionFactory.list();
      when(
        () => mockDao.getTransactions(
          userId: userId,
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          accountId: any(named: 'accountId'),
          categoryId: any(named: 'categoryId'),
        ),
      ).thenAnswer((_) async => transactions);

      final result = await repository.getTransactions(userId: userId);

      expect(
        result,
        Right<Failure, List<TransactionEntity>>(transactions),
      );
      verifyNever(
        () => mockRemote.getTransactions(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          categoryId: any(named: 'categoryId'),
          accountId: any(named: 'accountId'),
        ),
      );
    });

    test(
      'should fetch remote and upsert cache when forceRefresh',
      () async {
        final remoteModels = [
          TransactionModel.fromEntity(TransactionFactory.expense()),
        ];
        final localEntities = [TransactionFactory.expense()];

        when(
          () => mockRemote.getTransactions(
            userId: userId,
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryId: any(named: 'categoryId'),
            accountId: any(named: 'accountId'),
          ),
        ).thenAnswer((_) async => remoteModels);
        when(
          () => mockDao.insertAllTransactions(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockDao.getTransactions(
            userId: userId,
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            accountId: any(named: 'accountId'),
            categoryId: any(named: 'categoryId'),
          ),
        ).thenAnswer((_) async => localEntities);

        final result = await repository.getTransactions(
          userId: userId,
          forceRefresh: true,
        );

        expect(
          result,
          Right<Failure, List<TransactionEntity>>(localEntities),
        );
        verify(() => mockDao.insertAllTransactions(remoteModels)).called(1);
      },
    );

    test('should return ServerFailure when remote throws', () async {
      when(
        () => mockRemote.getTransactions(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          categoryId: any(named: 'categoryId'),
          accountId: any(named: 'accountId'),
        ),
      ).thenThrow(const ServerException());
      when(
        () => mockDao.getTransactions(
          userId: userId,
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          accountId: any(named: 'accountId'),
          categoryId: any(named: 'categoryId'),
        ),
      ).thenAnswer((_) async => []);

      final result = await repository.getTransactions(
        userId: userId,
        forceRefresh: true,
      );

      expect(result, isA<Left<Failure, List<TransactionEntity>>>());
    });
  });

  group('getTransaction', () {
    const txId = 'tx-1';

    test('should return from local cache if found', () async {
      final transaction = TransactionFactory.expense(id: txId);
      when(
        () => mockDao.getTransactionById(txId),
      ).thenAnswer((_) async => transaction);

      final result = await repository.getTransaction(txId);

      expect(result, Right<Failure, TransactionEntity>(transaction));
      verifyNever(() => mockRemote.getTransaction(any()));
    });

    test('should fetch from remote when not in local cache', () async {
      final model = TransactionModel.fromEntity(
        TransactionFactory.expense(id: txId),
      );
      when(
        () => mockDao.getTransactionById(txId),
      ).thenAnswer((_) async => null);
      when(
        () => mockRemote.getTransaction(txId),
      ).thenAnswer((_) async => model);
      when(() => mockDao.upsertTransaction(any())).thenAnswer((_) async {});

      final result = await repository.getTransaction(txId);

      expect(result.isRight(), isTrue);
      verify(() => mockRemote.getTransaction(txId)).called(1);
      verify(() => mockDao.upsertTransaction(model)).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(
        () => mockDao.getTransactionById(txId),
      ).thenAnswer((_) async => null);
      when(
        () => mockRemote.getTransaction(txId),
      ).thenThrow(const ServerException());

      final result = await repository.getTransaction(txId);

      expect(result, isA<Left<Failure, TransactionEntity>>());
    });
  });

  group('createTransaction', () {
    test('should create remotely and upsert locally', () async {
      final transaction = TransactionFactory.expense();
      final model = TransactionModel.fromEntity(transaction);

      when(
        () => mockRemote.createTransaction(any()),
      ).thenAnswer((_) async => model);
      when(() => mockDao.upsertTransaction(any())).thenAnswer((_) async {});

      final result = await repository.createTransaction(transaction);

      expect(result.isRight(), isTrue);
      verify(() => mockRemote.createTransaction(any())).called(1);
      verify(() => mockDao.upsertTransaction(model)).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(
        () => mockRemote.createTransaction(any()),
      ).thenThrow(const ServerException('Failed to create transaction.'));

      final result = await repository.createTransaction(
        TransactionFactory.expense(),
      );

      expect(result, isA<Left<Failure, TransactionEntity>>());
      verifyNever(() => mockDao.upsertTransaction(any()));
    });
  });

  group('updateTransaction', () {
    test('should update remotely and upsert locally', () async {
      final transaction = TransactionFactory.expense(description: 'Updated');
      final model = TransactionModel.fromEntity(transaction);

      when(
        () => mockRemote.updateTransaction(any()),
      ).thenAnswer((_) async => model);
      when(() => mockDao.upsertTransaction(any())).thenAnswer((_) async {});

      final result = await repository.updateTransaction(transaction);

      expect(result.isRight(), isTrue);
      verify(() => mockRemote.updateTransaction(any())).called(1);
      verify(() => mockDao.upsertTransaction(model)).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(
        () => mockRemote.updateTransaction(any()),
      ).thenThrow(const ServerException('Failed to update transaction.'));

      final result = await repository.updateTransaction(
        TransactionFactory.expense(),
      );

      expect(result, isA<Left<Failure, TransactionEntity>>());
      verifyNever(() => mockDao.upsertTransaction(any()));
    });
  });

  group('deleteTransaction', () {
    const txId = 'tx-1';

    test('should delete remotely and locally for normal transaction', () async {
      when(
        () => mockDao.getTransactionById(txId),
      ).thenAnswer((_) async => TransactionFactory.expense(id: txId));
      when(() => mockRemote.deleteTransaction(any())).thenAnswer((_) async {});
      when(() => mockDao.deleteTransaction(any())).thenAnswer((_) async {});

      final result = await repository.deleteTransaction(txId);

      expect(result, const Right<Failure, void>(null));
      verify(() => mockRemote.deleteTransaction(txId)).called(1);
      verify(() => mockDao.deleteTransaction(txId)).called(1);
    });

    test('should cascade delete both sides of a transfer atomically',
        () async {
      final pair = TransactionFactory.transfer();
      when(
        () => mockDao.getTransactionById(pair.expense.id),
      ).thenAnswer((_) async => pair.expense);
      when(
        () => mockRemote.deleteTransfer(any(), any()),
      ).thenAnswer((_) async {});
      when(() => mockDao.deleteTransaction(any())).thenAnswer((_) async {});

      final result = await repository.deleteTransaction(pair.expense.id);

      expect(result, const Right<Failure, void>(null));
      // Both remote legs go in a single atomic deleteTransfer call — never
      // two separate deleteTransaction round-trips that could half-fail.
      verify(
        () => mockRemote.deleteTransfer(pair.expense.id, pair.income.id),
      ).called(1);
      verifyNever(() => mockRemote.deleteTransaction(any()));
      verify(
        () => mockDao.deleteTransaction(pair.income.id),
      ).called(1);
      verify(
        () => mockDao.deleteTransaction(pair.expense.id),
      ).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(
        () => mockDao.getTransactionById(txId),
      ).thenAnswer((_) async => TransactionFactory.expense(id: txId));
      when(
        () => mockRemote.deleteTransaction(any()),
      ).thenThrow(const ServerException('Failed to delete transaction.'));

      final result = await repository.deleteTransaction(txId);

      expect(result, isA<Left<Failure, void>>());
    });
  });

  group('createTransfer', () {
    test('should create both transactions and upsert locally', () async {
      final pair = TransactionFactory.transfer();
      final expenseModel = TransactionModel.fromEntity(pair.expense);
      final incomeModel = TransactionModel.fromEntity(pair.income);

      when(
        () => mockRemote.createTransfer(
          expense: any(named: 'expense'),
          income: any(named: 'income'),
        ),
      ).thenAnswer((_) async => [expenseModel, incomeModel]);
      when(() => mockDao.upsertTransaction(any())).thenAnswer((_) async {});

      final result = await repository.createTransfer(
        expense: pair.expense,
        income: pair.income,
      );

      expect(result.isRight(), isTrue);
      result.fold((_) {}, (txs) => expect(txs.length, 2));
      verify(
        () => mockRemote.createTransfer(
          expense: any(named: 'expense'),
          income: any(named: 'income'),
        ),
      ).called(1);
      verify(() => mockDao.upsertTransaction(any())).called(2);
    });

    test('should return ServerFailure when remote throws', () async {
      final pair = TransactionFactory.transfer();
      when(
        () => mockRemote.createTransfer(
          expense: any(named: 'expense'),
          income: any(named: 'income'),
        ),
      ).thenThrow(const ServerException('Failed to create transfer.'));

      final result = await repository.createTransfer(
        expense: pair.expense,
        income: pair.income,
      );

      expect(result, isA<Left<Failure, List<TransactionEntity>>>());
      verifyNever(() => mockDao.upsertTransaction(any()));
    });
  });

  group('reassignTransactions', () {
    test('should delegate to remote datasource', () async {
      when(
        () => mockRemote.reassignTransactions(
          fromCategoryId: any(named: 'fromCategoryId'),
          toCategoryId: any(named: 'toCategoryId'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.reassignTransactions(
        fromCategoryId: 'cat-old',
        toCategoryId: 'cat-new',
      );

      expect(result, const Right<Failure, void>(null));
      verify(
        () => mockRemote.reassignTransactions(
          fromCategoryId: 'cat-old',
          toCategoryId: 'cat-new',
        ),
      ).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(
        () => mockRemote.reassignTransactions(
          fromCategoryId: any(named: 'fromCategoryId'),
          toCategoryId: any(named: 'toCategoryId'),
        ),
      ).thenThrow(const ServerException());

      final result = await repository.reassignTransactions(
        fromCategoryId: 'cat-old',
        toCategoryId: 'cat-new',
      );

      expect(result, isA<Left<Failure, void>>());
    });
  });
}
