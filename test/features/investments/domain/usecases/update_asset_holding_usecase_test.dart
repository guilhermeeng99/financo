import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';
import 'package:financo/features/investments/domain/usecases/update_asset_holding_usecase.dart';
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
  late UpdateAssetHoldingUseCase useCase;

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
    useCase = UpdateAssetHoldingUseCase(
      holdingRepository: holdingRepository,
      accountRepository: accountRepository,
      assetClassRepository: classRepository,
      transactionRepository: transactionRepository,
    );
    // Default class list: a root + a subclass under it. Tests needing a
    // root-only or empty list override this.
    when(
      () => classRepository.getAssetClasses(userId: any(named: 'userId')),
    ).thenAnswer(
      (_) async => Right<Failure, List<AssetClassEntity>>([stocks, apple]),
    );
    // No transactions by default — `effectiveBalance` falls back to
    // `currentBalance`.
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

  group('UpdateAssetHoldingUseCase — validation', () {
    test('rejects negative amounts before touching any repository', () async {
      final holding = AssetHoldingFactory.holding(amount: -1);

      final result = await useCase(holding);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NegativeAmountFailure>()),
        (_) => fail('Expected NegativeAmountFailure'),
      );
      verifyNever(() => accountRepository.getAccount(any()));
      verifyNever(() => holdingRepository.updateAssetHolding(any()));
    });

    test('rejects holdings pointed at a root class', () async {
      final holding = AssetHoldingFactory.holding(
        assetClassId: stocks.id,
        amount: 100,
      );

      final result = await useCase(holding);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<HoldingRequiresSubclassFailure>()),
        (_) => fail('Expected HoldingRequiresSubclassFailure'),
      );
      // Class guard short-circuits before the account lookup.
      verifyNever(() => accountRepository.getAccount(any()));
      verifyNever(() => holdingRepository.updateAssetHolding(any()));
    });

    test('rejects holdings whose class is missing', () async {
      when(
        () => classRepository.getAssetClasses(userId: any(named: 'userId')),
      ).thenAnswer(
        (_) async => const Right<Failure, List<AssetClassEntity>>(
          <AssetClassEntity>[],
        ),
      );
      final holding = AssetHoldingFactory.holding(
        assetClassId: apple.id,
        amount: 100,
      );

      final result = await useCase(holding);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<AssetClassNotFoundFailure>()),
        (_) => fail('Expected AssetClassNotFoundFailure'),
      );
      verifyNever(() => accountRepository.getAccount(any()));
    });

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
      verifyNever(() => holdingRepository.updateAssetHolding(any()));
    });
  });

  group('UpdateAssetHoldingUseCase — allocation overflow', () {
    test(
      'returns AllocationExceedsBalanceFailure when amount exceeds available',
      () async {
        final investment = AccountFactory.investment(
          initialBalance: 1000,
          currentBalance: 1000,
        );
        when(() => accountRepository.getAccount(investment.id)).thenAnswer(
          (_) async => Right<Failure, AccountEntity>(investment),
        );
        when(
          () => holdingRepository.getAssetHoldings(
            userId: any(named: 'userId'),
          ),
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
        verifyNever(() => holdingRepository.updateAssetHolding(any()));
      },
    );

    test('excludes the edited holding from the available calculation',
        () async {
      // Account balance 2000, fully consumed by holding-1 at 2000. Re-saving
      // holding-1 at 2000 must succeed because its own current amount is
      // excluded from `available` (otherwise it would read as overflow).
      final investment = AccountFactory.investment(
        initialBalance: 2000,
        currentBalance: 2000,
      );
      when(() => accountRepository.getAccount(investment.id)).thenAnswer(
        (_) async => Right<Failure, AccountEntity>(investment),
      );
      final existing = AssetHoldingFactory.holding(
        accountId: investment.id,
        assetClassId: apple.id,
        amount: 2000,
      );
      when(
        () => holdingRepository.getAssetHoldings(userId: any(named: 'userId')),
      ).thenAnswer(
        (_) async => Right<Failure, List<AssetHoldingEntity>>([existing]),
      );
      final edited = existing.copyWith(notes: 'rebalanced');
      when(() => holdingRepository.updateAssetHolding(any())).thenAnswer(
        (_) async => Right<Failure, AssetHoldingEntity>(edited),
      );

      final result = await useCase(edited);

      expect(result.isRight(), isTrue);
      verify(() => holdingRepository.updateAssetHolding(edited)).called(1);
    });
  });

  group('UpdateAssetHoldingUseCase — delegation', () {
    test('updates the holding when every invariant holds', () async {
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
      final holding = AssetHoldingFactory.holding(
        accountId: investment.id,
        assetClassId: apple.id,
        amount: 5000,
      );
      when(() => holdingRepository.updateAssetHolding(any())).thenAnswer(
        (_) async => Right<Failure, AssetHoldingEntity>(holding),
      );

      final result = await useCase(holding);

      expect(result.isRight(), isTrue);
      verify(() => holdingRepository.updateAssetHolding(holding)).called(1);
    });

    test('forwards a failure raised while loading the class list', () async {
      when(
        () => classRepository.getAssetClasses(userId: any(named: 'userId')),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, List<AssetClassEntity>>(ServerFailure()),
      );
      final holding = AssetHoldingFactory.holding(
        assetClassId: apple.id,
        amount: 100,
      );

      final result = await useCase(holding);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected ServerFailure'),
      );
      verifyNever(() => holdingRepository.updateAssetHolding(any()));
    });
  });
}
