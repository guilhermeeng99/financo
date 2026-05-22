import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';
import 'package:financo/features/investments/domain/usecases/get_investment_overview_usecase.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockAccountRepository accountRepository;
  late MockAssetClassRepository classRepository;
  late MockAssetHoldingRepository holdingRepository;
  late MockTransactionRepository transactionRepository;
  late GetInvestmentOverviewUseCase useCase;

  const userId = 'user-1';

  setUpAll(() {
    registerInvestmentFallbackValues();
    registerAccountFallbackValues();
    registerTransactionFallbackValues();
  });

  setUp(() {
    accountRepository = MockAccountRepository();
    classRepository = MockAssetClassRepository();
    holdingRepository = MockAssetHoldingRepository();
    transactionRepository = MockTransactionRepository();
    useCase = GetInvestmentOverviewUseCase(
      accountRepository: accountRepository,
      assetClassRepository: classRepository,
      assetHoldingRepository: holdingRepository,
      transactionRepository: transactionRepository,
    );
  });

  // Stubs every read to succeed with the supplied (default empty) lists.
  void stubAllSuccess({
    List<AccountEntity> accounts = const [],
    List<AssetClassEntity> classes = const [],
    List<AssetHoldingEntity> holdings = const [],
    List<TransactionEntity> transactions = const [],
  }) {
    when(
      () => accountRepository.getAccounts(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Right<Failure, List<AccountEntity>>(accounts));
    when(
      () => classRepository.getAssetClasses(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, List<AssetClassEntity>>(classes),
    );
    when(
      () => holdingRepository.getAssetHoldings(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, List<AssetHoldingEntity>>(holdings),
    );
    when(
      () => transactionRepository.getTransactions(userId: any(named: 'userId')),
    ).thenAnswer(
      (_) async => Right<Failure, List<TransactionEntity>>(transactions),
    );
  }

  group('GetInvestmentOverviewUseCase — happy path', () {
    test('returns a snapshot bundling the four reads', () async {
      stubAllSuccess();

      final result = await useCase(userId: userId);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected a snapshot'),
        (snapshot) {
          expect(snapshot.accounts, isEmpty);
          expect(snapshot.classes, isEmpty);
          expect(snapshot.holdings, isEmpty);
          expect(snapshot.overview.totalInvested, 0);
        },
      );
    });

    test('computes totals from investment accounts and holdings', () async {
      final investment = AccountFactory.investment(currentBalance: 10000);
      stubAllSuccess(accounts: [investment]);

      final result = await useCase(userId: userId);

      result.fold(
        (_) => fail('Expected a snapshot'),
        (snapshot) {
          expect(snapshot.overview.totalInvested, 10000);
          expect(snapshot.overview.totalAllocated, 0);
          expect(snapshot.overview.totalPending, 10000);
          expect(snapshot.accounts, hasLength(1));
        },
      );
    });

    test('forwards forceRefresh to every read', () async {
      stubAllSuccess();

      await useCase(userId: userId, forceRefresh: true);

      verify(
        () => accountRepository.getAccounts(
          userId: userId,
          forceRefresh: true,
        ),
      ).called(1);
      verify(
        () => classRepository.getAssetClasses(
          userId: userId,
          forceRefresh: true,
        ),
      ).called(1);
      verify(
        () => holdingRepository.getAssetHoldings(
          userId: userId,
          forceRefresh: true,
        ),
      ).called(1);
    });
  });

  group('GetInvestmentOverviewUseCase — failure propagation', () {
    test('returns Left when the accounts read fails', () async {
      stubAllSuccess();
      when(
        () => accountRepository.getAccounts(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, List<AccountEntity>>(ServerFailure()),
      );

      final result = await useCase(userId: userId);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected ServerFailure'),
      );
    });

    test('returns Left when the classes read fails', () async {
      stubAllSuccess();
      when(
        () => classRepository.getAssetClasses(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, List<AssetClassEntity>>(ServerFailure()),
      );

      final result = await useCase(userId: userId);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected ServerFailure'),
      );
    });

    test('returns Left when the holdings read fails', () async {
      stubAllSuccess();
      when(
        () => holdingRepository.getAssetHoldings(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, List<AssetHoldingEntity>>(ServerFailure()),
      );

      final result = await useCase(userId: userId);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected ServerFailure'),
      );
    });

    test('degrades to seed balances when only transactions fail', () async {
      final investment = AccountFactory.investment(
        initialBalance: 7000,
        currentBalance: 9000,
      );
      stubAllSuccess(accounts: [investment]);
      // Transactions fail — the snapshot must still succeed, falling back
      // to the raw account list (currentBalance, then initialBalance).
      when(
        () =>
            transactionRepository.getTransactions(userId: any(named: 'userId')),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, List<TransactionEntity>>(ServerFailure()),
      );

      final result = await useCase(userId: userId);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected a snapshot despite the transaction failure'),
        (snapshot) {
          expect(snapshot.accounts, hasLength(1));
          // currentBalance (9000) is preserved — calculator not applied.
          expect(snapshot.overview.totalInvested, 9000);
        },
      );
    });

    test('applies transactions to investment balances when they load',
        () async {
      // Seed 5000 + a 1000 income deposit → effectiveBalance 6000.
      final investment = AccountFactory.investment(
        initialBalance: 5000,
      );
      final deposit = TransactionFactory.income(
        accountId: investment.id,
        amount: 1000,
      );
      stubAllSuccess(accounts: [investment], transactions: [deposit]);

      final result = await useCase(userId: userId);

      result.fold(
        (_) => fail('Expected a snapshot'),
        (snapshot) => expect(snapshot.overview.totalInvested, 6000),
      );
    });
  });
}
