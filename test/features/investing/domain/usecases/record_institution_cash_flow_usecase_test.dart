import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/usecases/record_institution_cash_flow_usecase.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockAssetRepository assetRepo;
  late MockAssetTransactionRepository assetTxRepo;
  late MockSaveAssetTransactionUseCase saveAssetTx;
  late MockTransactionRepository txRepo;
  late RecordInstitutionCashFlowUseCase usecase;

  const userId = 'user-1';
  const institutionId = 'inst-wise';
  const checkingId = 'acc-chk';

  Asset cashAsset({String id = 'cash-1'}) => Asset(
    id: id,
    userId: userId,
    ticker: 'CASH-BRL-$institutionId',
    name: 'BRL cash',
    kind: AssetKind.cash,
    market: Market.global,
    currency: Currency.brl,
    institutionId: institutionId,
    createdAt: DateTime(2024),
  );

  setUpAll(() {
    registerFallbackValue(AssetTransactionFactory.buy());
    registerFallbackValue(cashAsset());
    registerFallbackValue(TransactionFactory.expense());
  });

  setUp(() {
    assetRepo = MockAssetRepository();
    assetTxRepo = MockAssetTransactionRepository();
    saveAssetTx = MockSaveAssetTransactionUseCase();
    txRepo = MockTransactionRepository();
    usecase = RecordInstitutionCashFlowUseCase(
      assetRepository: assetRepo,
      assetTransactionRepository: assetTxRepo,
      saveAssetTransaction: saveAssetTx,
      transactionRepository: txRepo,
    );

    when(
      () => saveAssetTx(any()),
    ).thenAnswer(
      (_) async => Right(
        AssetTransactionFactory.buy(
          id: 'inv-1',
          institutionId: institutionId,
          assetId: 'cash-1',
          currency: Currency.brl,
        ),
      ),
    );
    when(
      () => txRepo.createTransaction(any()),
    ).thenAnswer(
      (_) async => Right(TransactionFactory.expense(id: 'cash-tx-1')),
    );
  });

  void stubExistingAssets(List<Asset> assets) {
    when(
      () => assetRepo.getAssets(userId: any(named: 'userId')),
    ).thenAnswer((_) async => Right(assets));
  }

  group('deposit', () {
    test(
      'creates the cash asset on first deposit and writes both legs',
      () async {
        stubExistingAssets(const []);
        when(
          () => assetRepo.createAsset(any()),
        ).thenAnswer((_) async => Right(cashAsset()));

        final result = await usecase.call(
          userId: userId,
          institutionId: institutionId,
          checkingAccountId: checkingId,
          amount: 7000,
          direction: InstitutionCashDirection.deposit,
        );

        expect(result.isRight(), isTrue);

        final createdAsset =
            verify(() => assetRepo.createAsset(captureAny())).captured.single
                as Asset;
        expect(createdAsset.kind, AssetKind.cash);
        expect(createdAsset.institutionId, institutionId);
        expect(createdAsset.currency, Currency.brl);

        final inv =
            verify(() => saveAssetTx(captureAny())).captured.single
                as AssetTransaction;
        expect(inv.kind, TransactionKind.buy);
        expect(inv.quantity, 7000);
        expect(inv.assetId, 'cash-1');
        expect(inv.institutionId, institutionId);
        expect(inv.fundingAccountId, checkingId);
        expect(inv.cashAmount, Money.fromMajor(7000, Currency.brl));

        final cash =
            verify(
                  () => txRepo.createTransaction(captureAny()),
                ).captured.single
                as TransactionEntity;
        expect(cash.type, TransactionType.expense);
        expect(cash.amount, 7000);
        expect(cash.accountId, checkingId);
        expect(cash.institutionId, institutionId);
        expect(cash.linkedInvestmentTransactionId, 'inv-1');
      },
    );

    test('reuses an existing cash holding instead of creating one', () async {
      stubExistingAssets([cashAsset(id: 'cash-existing')]);

      final result = await usecase.call(
        userId: userId,
        institutionId: institutionId,
        checkingAccountId: checkingId,
        amount: 500,
        direction: InstitutionCashDirection.deposit,
      );

      expect(result.isRight(), isTrue);
      verifyNever(() => assetRepo.createAsset(any()));
      final inv =
          verify(() => saveAssetTx(captureAny())).captured.single
              as AssetTransaction;
      expect(inv.assetId, 'cash-existing');
    });
  });

  group('withdraw', () {
    test('records a sell and a checking income', () async {
      stubExistingAssets([cashAsset(id: 'cash-existing')]);

      await usecase.call(
        userId: userId,
        institutionId: institutionId,
        checkingAccountId: checkingId,
        amount: 300,
        direction: InstitutionCashDirection.withdraw,
      );

      final inv =
          verify(() => saveAssetTx(captureAny())).captured.single
              as AssetTransaction;
      expect(inv.kind, TransactionKind.sell);
      final cash =
          verify(
                () => txRepo.createTransaction(captureAny()),
              ).captured.single
              as TransactionEntity;
      expect(cash.type, TransactionType.income);
    });
  });

  group('guards', () {
    test('rejects a non-positive amount without writing', () async {
      final result = await usecase.call(
        userId: userId,
        institutionId: institutionId,
        checkingAccountId: checkingId,
        amount: 0,
        direction: InstitutionCashDirection.deposit,
      );

      expect(result, isA<Left<Failure, TransactionEntity>>());
      verifyNever(() => saveAssetTx(any()));
      verifyNever(() => txRepo.createTransaction(any()));
    });

    test('rolls back the investing leg when the cash write fails', () async {
      stubExistingAssets([cashAsset(id: 'cash-existing')]);
      when(
        () => txRepo.createTransaction(any()),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      when(
        () => assetTxRepo.deleteTransaction(any()),
      ).thenAnswer((_) async => const Right(null));

      final result = await usecase.call(
        userId: userId,
        institutionId: institutionId,
        checkingAccountId: checkingId,
        amount: 7000,
        direction: InstitutionCashDirection.deposit,
      );

      expect(result, isA<Left<Failure, TransactionEntity>>());
      verify(() => assetTxRepo.deleteTransaction('inv-1')).called(1);
    });
  });
}
