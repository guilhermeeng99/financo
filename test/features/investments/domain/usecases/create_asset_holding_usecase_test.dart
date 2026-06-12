import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';
import 'package:financo/features/investments/domain/usecases/create_asset_holding_usecase.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/factories/asset_class_factory.dart';
import '../../../../harness/factories/asset_holding_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockAssetHoldingRepository holdingRepository;
  late MockAccountRepository accountRepository;
  late MockAssetClassRepository classRepository;
  late MockTransactionRepository transactionRepository;
  late CreateAssetHoldingUseCase useCase;

  setUpAll(() {
    registerInvestmentFallbackValues();
    registerAccountFallbackValues();
  });

  final stocks = AssetClassFactory.stocks();
  final apple = AssetClassFactory.subclass(
    id: 'sub-apple',
    name: 'Apple',
    parent: stocks,
  );

  setUp(() {
    holdingRepository = MockAssetHoldingRepository();
    accountRepository = MockAccountRepository();
    classRepository = MockAssetClassRepository();
    transactionRepository = MockTransactionRepository();
    useCase = CreateAssetHoldingUseCase(
      holdingRepository: holdingRepository,
      accountRepository: accountRepository,
      assetClassRepository: classRepository,
      transactionRepository: transactionRepository,
    );
    // Default class list: a root + a subclass under it. Tests that
    // need the root-only edge override this.
    when(
      () => classRepository.getAssetClasses(userId: any(named: 'userId')),
    ).thenAnswer(
      (_) async => Right<Failure, List<AssetClassEntity>>([stocks, apple]),
    );
    // No transactions by default — `effectiveBalance` falls back to
    // `currentBalance` (or `initialBalance` when the factory left it
    // null).
    when(
      () => transactionRepository.getTransactions(
        userId: any(named: 'userId'),
        accountId: any(named: 'accountId'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, List<TransactionEntity>>(
        <TransactionEntity>[],
      ),
    );
  });

  group('CreateAssetHoldingUseCase', () {
    test('rejects holdings tied to non-investment accounts', () async {
      final checking = AccountFactory.checking();
      when(() => accountRepository.getAccount(checking.id)).thenAnswer(
        (_) async => Right<Failure, AccountEntity>(checking),
      );

      final holding = AssetHoldingFactory.holding(
        accountId: checking.id,
        assetClassId: apple.id,
        amount: 100,
      );
      final result = await useCase(holding);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) =>
            expect(failure, isA<HoldingAccountNotInvestmentFailure>()),
        (_) => fail('Expected HoldingAccountNotInvestmentFailure'),
      );
      verifyNever(() => holdingRepository.createAssetHolding(any()));
    });

    test('rejects negative amounts before touching the repositories', () async {
      final holding = AssetHoldingFactory.holding(amount: -1);

      final result = await useCase(holding);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NegativeAmountFailure>()),
        (_) => fail('Expected NegativeAmountFailure'),
      );
      verifyNever(() => accountRepository.getAccount(any()));
    });

    test('rejects holdings pointed at a root class', () async {
      final investment = AccountFactory.investment(currentBalance: 10000);
      final holding = AssetHoldingFactory.holding(
        accountId: investment.id,
        assetClassId: stocks.id,
        amount: 100,
      );

      final result = await useCase(holding);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<HoldingRequiresSubclassFailure>()),
        (_) => fail('Expected HoldingRequiresSubclassFailure'),
      );
      // Account repo never queried — class guard short-circuits first.
      verifyNever(() => accountRepository.getAccount(any()));
      verifyNever(() => holdingRepository.createAssetHolding(any()));
    });

    test('rejects allocations exceeding the account balance', () async {
      final investment = AccountFactory.investment(
        initialBalance: 1000,
        currentBalance: 1000,
      );
      when(() => accountRepository.getAccount(investment.id)).thenAnswer(
        (_) async => Right<Failure, AccountEntity>(investment),
      );
      when(
        () => holdingRepository.getAssetHoldings(userId: any(named: 'userId')),
      ).thenAnswer(
        (_) async => const Right<Failure, List<AssetHoldingEntity>>(
          <AssetHoldingEntity>[],
        ),
      );

      final holding = AssetHoldingFactory.holding(
        accountId: investment.id,
        assetClassId: apple.id,
        amount: 5000,
      );

      final result = await useCase(holding);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AllocationExceedsBalanceFailure>());
          expect(
            (failure as AllocationExceedsBalanceFailure).available,
            1000,
          );
        },
        (_) => fail('Expected AllocationExceedsBalanceFailure'),
      );
      verifyNever(() => holdingRepository.createAssetHolding(any()));
    });

    test('creates the holding when invariants hold', () async {
      final investment = AccountFactory.investment(currentBalance: 10000);
      when(() => accountRepository.getAccount(investment.id)).thenAnswer(
        (_) async => Right<Failure, AccountEntity>(investment),
      );
      when(
        () => holdingRepository.getAssetHoldings(userId: any(named: 'userId')),
      ).thenAnswer(
        (_) async => const Right<Failure, List<AssetHoldingEntity>>(
          <AssetHoldingEntity>[],
        ),
      );
      when(() => holdingRepository.createAssetHolding(any())).thenAnswer(
        (invocation) async => Right<Failure, AssetHoldingEntity>(
          invocation.positionalArguments.first as AssetHoldingEntity,
        ),
      );

      final holding = AssetHoldingFactory.holding(
        accountId: investment.id,
        assetClassId: apple.id,
        amount: 5000,
      );

      final result = await useCase(holding);

      expect(result.isRight(), isTrue);
      verify(() => holdingRepository.createAssetHolding(holding)).called(1);
    });
  });
}
