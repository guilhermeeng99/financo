import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/usecases/save_asset_transaction_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(AssetTransactionFactory.buy());
  });

  late MockAssetTransactionRepository transactions;
  late MockAssetRepository assets;
  late MockSyncInvestmentCashFlowUseCase syncCashFlow;
  late SaveAssetTransactionUseCase useCase;

  setUp(() {
    transactions = MockAssetTransactionRepository();
    assets = MockAssetRepository();
    syncCashFlow = MockSyncInvestmentCashFlowUseCase();
    useCase = SaveAssetTransactionUseCase(
      transactionRepository: transactions,
      assetRepository: assets,
      syncCashFlow: syncCashFlow,
    );
    when(
      () =>
          syncCashFlow(any(), investingDeleted: any(named: 'investingDeleted')),
    ).thenAnswer((_) async => const Right(null));
  });

  void stubAsset({String? institutionId = 'inst-avenue'}) {
    when(() => assets.getAssets(userId: 'user-1')).thenAnswer(
      (_) async => Right([AssetFactory.stockUs(institutionId: institutionId)]),
    );
  }

  void stubSaveable() {
    when(
      () => transactions.getTransactions(userId: 'user-1'),
    ).thenAnswer((_) async => const Right([]));
    when(() => transactions.saveTransaction(any())).thenAnswer(
      (invocation) async =>
          Right(invocation.positionalArguments.first as AssetTransaction),
    );
  }

  test('rejects a future date before touching the repositories', () async {
    final result = await useCase(
      AssetTransactionFactory.buy(date: DateTime(2999)),
    );
    result.leftMap((f) => expect(f, isA<FutureTransactionDateFailure>()));
    expect(result.isLeft(), isTrue);
    verifyNever(() => assets.getAssets(userId: any(named: 'userId')));
  });

  test('rejects when the asset has no institution', () async {
    stubAsset(institutionId: null);
    final result = await useCase(AssetTransactionFactory.buy());
    result.leftMap((f) => expect(f, isA<AssetInstitutionRequiredFailure>()));
    expect(result.isLeft(), isTrue);
  });

  test('rejects an institution that does not match the asset', () async {
    stubAsset(institutionId: 'inst-nubank');
    final result = await useCase(AssetTransactionFactory.buy());
    result.leftMap(
      (f) => expect(f, isA<TransactionInstitutionMismatchFailure>()),
    );
    expect(result.isLeft(), isTrue);
  });

  test('rejects a non-positive quantity on a buy', () async {
    stubAsset();
    final result = await useCase(AssetTransactionFactory.buy(quantity: 0));
    result.leftMap((f) => expect(f, isA<NonPositiveQuantityFailure>()));
    expect(result.isLeft(), isTrue);
  });

  test('blocks an oversell against the position timeline', () async {
    stubAsset();
    when(
      () => transactions.getTransactions(userId: 'user-1'),
    ).thenAnswer((_) async => const Right([]));
    final result = await useCase(AssetTransactionFactory.sell(quantity: 5));
    result.leftMap((f) => expect(f, isA<OversellFailure>()));
    expect(result.isLeft(), isTrue);
    verifyNever(() => transactions.saveTransaction(any()));
  });

  test('saves a valid buy', () async {
    stubAsset();
    stubSaveable();

    final result = await useCase(AssetTransactionFactory.buy());
    expect(result.isRight(), isTrue);
    verify(() => transactions.saveTransaction(any())).called(1);
  });

  group('cash-flow pairing (F8.4)', () {
    test('reconciles the cash row with the saved transaction', () async {
      stubAsset();
      stubSaveable();

      await useCase(
        AssetTransactionFactory.buy(fundingAccountId: 'acc-nubank-gui'),
      );

      final synced =
          verify(
                () => syncCashFlow(
                  captureAny(),
                  investingDeleted: any(named: 'investingDeleted'),
                ),
              ).captured.single
              as AssetTransaction;
      expect(synced.fundingAccountId, 'acc-nubank-gui');
    });

    test('rolls the new investing row back when the cash row fails', () async {
      stubAsset();
      stubSaveable();
      when(
        () => transactions.deleteTransaction(any()),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => syncCashFlow(
          any(),
          investingDeleted: any(named: 'investingDeleted'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure()));

      final result = await useCase(
        AssetTransactionFactory.buy(id: '', fundingAccountId: 'acc-1'),
      );

      expect(result.isLeft(), isTrue);
      verify(() => transactions.deleteTransaction(any())).called(1);
    });

    test('keeps an edited row when the cash row fails', () async {
      stubAsset();
      stubSaveable();
      when(
        () => syncCashFlow(
          any(),
          investingDeleted: any(named: 'investingDeleted'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure()));

      final result = await useCase(
        AssetTransactionFactory.buy(id: 'tx-1', fundingAccountId: 'acc-1'),
      );

      expect(result.isLeft(), isTrue);
      verifyNever(() => transactions.deleteTransaction(any()));
    });
  });
}
