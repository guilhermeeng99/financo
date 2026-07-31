import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/usecases/delete_asset_transaction_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockAssetTransactionRepository transactions;
  late MockSyncInvestmentCashFlowUseCase syncCashFlow;
  late DeleteAssetTransactionUseCase useCase;

  setUpAll(() {
    registerFallbackValue(AssetTransactionFactory.buy());
  });

  setUp(() {
    transactions = MockAssetTransactionRepository();
    syncCashFlow = MockSyncInvestmentCashFlowUseCase();
    useCase = DeleteAssetTransactionUseCase(transactions, syncCashFlow);
    when(
      () => transactions.deleteTransaction(any()),
    ).thenAnswer((_) async => const Right(null));
  });

  test('removes the paired cash row before the investing row', () async {
    when(
      () => syncCashFlow(
        any(),
        investingDeleted: any(named: 'investingDeleted'),
      ),
    ).thenAnswer((_) async => const Right(null));

    final result = await useCase(
      AssetTransactionFactory.buy(id: 'tx-1', fundingAccountId: 'acc-1'),
    );

    expect(result.isRight(), isTrue);
    verify(() => syncCashFlow(any(), investingDeleted: true)).called(1);
    verify(() => transactions.deleteTransaction('tx-1')).called(1);
  });

  test('keeps the investing row when the cascade fails', () async {
    when(
      () => syncCashFlow(
        any(),
        investingDeleted: any(named: 'investingDeleted'),
      ),
    ).thenAnswer((_) async => const Left(ServerFailure()));

    final result = await useCase(AssetTransactionFactory.buy(id: 'tx-1'));

    expect(result.isLeft(), isTrue);
    verifyNever(() => transactions.deleteTransaction(any()));
  });
}
