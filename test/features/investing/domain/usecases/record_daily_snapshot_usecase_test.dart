import 'package:dartz/dartz.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/portfolio_valuation.dart';
import 'package:financo/features/investing/domain/entities/snapshot.dart';
import 'package:financo/features/investing/domain/usecases/record_daily_snapshot_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(SnapshotFactory.day());
  });

  late MockSnapshotRepository repo;
  late RecordDailySnapshotUseCase usecase;

  setUp(() {
    repo = MockSnapshotRepository();
    usecase = RecordDailySnapshotUseCase(repo);
    when(
      () => repo.recordSnapshot(any()),
    ).thenAnswer((_) async => const Right(unit));
  });

  test('records the day at local midnight from the priced portfolio', () async {
    const withValue = PortfolioValuation(
      totalValueBase: Money(100000, Currency.brl),
      totalInvestedBase: Money(80000, Currency.brl),
      totalUnrealizedPL: Money(20000, Currency.brl),
      totalDayChangeBase: Money.zero(Currency.brl),
      totalReturnPct: 0.25,
      byClass: {},
      byInstitution: {},
      byCurrency: {},
      holdings: [],
    );

    await usecase(
      userId: 'user-1',
      portfolio: withValue,
      today: DateTime(2024, 5, 20, 14, 30),
    );

    final captured =
        verify(() => repo.recordSnapshot(captureAny())).captured.single
            as Snapshot;
    expect(captured.date, DateTime(2024, 5, 20));
    expect(captured.totalValue, Money.fromMajor(1000, Currency.brl));
    expect(captured.dayKey, '2024-05-20');
  });

  test('skips recording when the portfolio is empty', () async {
    await usecase(
      userId: 'user-1',
      portfolio: PortfolioValuation.empty(),
      today: DateTime(2024, 5, 20),
    );

    verifyNever(() => repo.recordSnapshot(any()));
  });
}
