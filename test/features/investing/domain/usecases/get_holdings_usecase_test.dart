import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/usecases/get_holdings_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockAssetTransactionRepository transactions;
  late GetHoldingsUseCase useCase;

  setUp(() {
    transactions = MockAssetTransactionRepository();
    useCase = GetHoldingsUseCase(transactions);
  });

  test('derives holdings from the transaction list', () async {
    when(() => transactions.getTransactions(userId: 'user-1')).thenAnswer(
      (_) async => Right([
        AssetTransactionFactory.buy(),
        AssetTransactionFactory.sell(),
      ]),
    );

    final result = await useCase(userId: 'user-1');

    expect(result.isRight(), isTrue);
    final holdings = result.getOrElse(() => []);
    expect(holdings, hasLength(1));
    expect(holdings.single.quantity, 6);
    expect(holdings.single.avgCost, Money.fromMajor(100, Currency.usd));
  });

  test('propagates a repository failure', () async {
    when(
      () => transactions.getTransactions(userId: 'user-1'),
    ).thenAnswer((_) async => const Left(ServerFailure()));

    final result = await useCase(userId: 'user-1');
    expect(result.isLeft(), isTrue);
  });
}
